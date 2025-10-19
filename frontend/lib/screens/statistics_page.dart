import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/bar_chart.dart';
import 'main_menu_page.dart';
import 'dyslexia_info_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  /// Legend dot + label widget
  Widget _dotLabel(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  /// Legend row
  Widget legend(Color myColor, Color avgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _dotLabel(myColor, 'My Latest Result'),
          const SizedBox(width: 16),
          _dotLabel(avgColor, 'Average of Other Participants'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final myColor = const Color.fromARGB(255, 219, 125, 3);
    final avgColor = const Color(0xFFC8E6C9);
    final backGroundColor = const Color(0xFF81C784);

    final readingStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reading_results')
        .orderBy('timestamp')
        .snapshots();

    final compStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('comprehension_results')
        .orderBy('timestamp')
        .snapshots();

    final allReadingStream =
        FirebaseFirestore.instance.collectionGroup('reading_results').snapshots();

    final allCompStream =
        FirebaseFirestore.instance.collectionGroup('comprehension_results').snapshots();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: backGroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Reading Statistics ─────────────────────────────
          Text(
            '📊 Reading Statistics',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          legend(myColor, avgColor),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: allReadingStream,
                builder: (ctx, allSnap) {
                  if (!allSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docsAll = allSnap.data!.docs;
                  final Map<String, List<double>> buf = {};
                  for (final d in docsAll) {
                    final parent = d.reference.parent.parent;
                    if (parent == null || parent.id == uid) continue;
                    buf.putIfAbsent(parent.id, () => <double>[])
                        .add((d['accuracy'] as num).toDouble());
                  }
                  final otherAvgs = buf.values
                      .map((lst) => lst.reduce((a, b) => a + b) / lst.length)
                      .toList()
                    ..sort();

                  return StreamBuilder<QuerySnapshot>(
                    stream: readingStream,
                    builder: (ctx, meSnap) {
                      if (!meSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final myDocs = meSnap.data!.docs;
                      if (myDocs.isEmpty) {
                        return const Text('No reading record found.');
                      }
                      final lastAcc = (myDocs.last['accuracy'] as num).toDouble();
                      final mid = (otherAvgs.length / 2).floor();
                      final values = [...otherAvgs]..insert(mid, lastAcc);
                      final colors = List<Color>.filled(values.length, avgColor)
                        ..[mid] = myColor;
                      return BarChartWithColors(
                        values: values,
                        colors: colors,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Comprehension Statistics ───────────────────────────
          Text(
            '📈 Comprehension Statistics',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          legend(myColor, avgColor),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: allCompStream,
                builder: (ctx, allSnap) {
                  if (!allSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docsAll = allSnap.data!.docs;
                  final Map<String, List<double>> buf = {};
                  for (final d in docsAll) {
                    final parent = d.reference.parent.parent;
                    if (parent == null || parent.id == uid) continue;
                    final data = d.data()! as Map<String, dynamic>;
                    final tot = (data['total_questions'] as num).toDouble();
                    final corr = (data['correct_answers'] as num).toDouble();
                    final pct = tot > 0 ? corr / tot * 100 : 0.0;
                    buf.putIfAbsent(parent.id, () => <double>[]).add(pct);
                  }
                  final otherAvgs = buf.values
                      .map((lst) => lst.reduce((a, b) => a + b) / lst.length)
                      .toList()
                    ..sort();

                  return StreamBuilder<QuerySnapshot>(
                    stream: compStream,
                    builder: (ctx, meSnap) {
                      if (!meSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final myDocs = meSnap.data!.docs;
                      if (myDocs.isEmpty) {
                        return const Text('No comprehension record found.');
                      }
                      final data = myDocs.last.data()! as Map<String, dynamic>;
                      final tot = (data['total_questions'] as num).toDouble();
                      final corr = (data['correct_answers'] as num).toDouble();
                      final lastPct = tot > 0 ? corr / tot * 100 : 0.0;
                      final mid = (otherAvgs.length / 2).floor();
                      final values = [...otherAvgs]..insert(mid, lastPct);
                      final colors = List<Color>.filled(values.length, avgColor)
                        ..[mid] = myColor;
                      return BarChartWithColors(
                        values: values,
                        colors: colors,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ─── Bottom Buttons ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainMenuPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backGroundColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(400, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Back to Main Menu'),
                ),
                const SizedBox(width: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DyslexiaInfoPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backGroundColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(400, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Learn About Dyslexia'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// done
