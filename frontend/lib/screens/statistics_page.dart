// lib/screens/statistics_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/bar_chart.dart';
import 'main_menu_page.dart';
import 'dyslexia_info_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  /// ■ 범례용 dot+label 위젯
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

  /// ■ 범례 전체 Row
  Widget legend(Color myColor, Color avgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _dotLabel(myColor, '나의 최신 결과'),
          const SizedBox(width: 16),
          _dotLabel(avgColor, '다른 참가자 평균'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 차트 색상: 나의 최신은 주 색상, 평균은 반투명으로
    final myColor = const Color.fromARGB(255, 219, 125, 3);    // 테마 메인 그린
    final avgColor = const Color(0xFFC8E6C9);   // 연두 라이트
    final backGroundColor = const Color(0xFF81C784);

    // 개인 결과 스트림
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

    // 전체 참가자 평균 계산용 스트림
    final allReadingStream =
        FirebaseFirestore.instance.collectionGroup('reading_results').snapshots();
    final allCompStream =
        FirebaseFirestore.instance.collectionGroup('comprehension_results').snapshots();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('통계 보기'),
        backgroundColor: backGroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── 읽기 통계 ─────────────────────────────
          Text(
            '📊 읽기 통계',
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
                        return const Text('내 읽기 기록이 없습니다.');
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

          // ─── 이해도 통계 ───────────────────────────
          Text(
            '📈 이해도 통계',
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
                        return const Text('내 이해도 기록이 없습니다.');
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

          // ─── 하단 버튼 (너비 조정, 가운데 정렬) ───────────────────────────
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
                    minimumSize: const Size(400, 48),  // 200px 너비
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('메인 페이지로 돌아가기'),
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
                    minimumSize: const Size(400, 48),  // 200px 너비
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('난독증에 대한 정보'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// .
