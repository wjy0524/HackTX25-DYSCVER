import 'package:flutter/material.dart';
import '../model/comprehension.dart';
import '../services/comprehension_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComprehensionPage extends StatefulWidget {
  final int age;
  final String gender;
  final String nativeLanguage;

  const ComprehensionPage({
    Key? key,
    required this.age,
    required this.gender,
    required this.nativeLanguage,
  }) : super(key: key);

  @override
  _ComprehensionPageState createState() => _ComprehensionPageState();
}

class _ComprehensionPageState extends State<ComprehensionPage> {
  late Future<List<ComprehensionItem>> _futureItems;
  int _current = 0;
  final List<List<int?>> _selected = [];

  @override
  void initState() {
    super.initState();
    _futureItems = fetchComprehensionMaterial(
      widget.age,
      widget.gender,
      widget.nativeLanguage,
    );
  }

  void _next(List<ComprehensionItem> items) {
    if (_current < items.length - 1) {
      setState(() => _current++);
    } else {
      _showResult(items);
    }
  }

  void _showResult(List<ComprehensionItem> items) async {
    final total = items.length * items[0].questions.length;
    var correct = 0;

    for (var i = 0; i < items.length; i++) {
      for (var j = 0; j < items[i].questions.length; j++) {
        if (_selected[i][j] == items[i].questions[j].answerIndex) {
          correct++;
        }
      }
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('comprehension_results')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'total_questions': total,
        'correct_answers': correct,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save results: $e')),
      );
      return;
    }

    // ✅ DyslexiaResultPage로 이동 (예측 페이지)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Comprehension Test Completed'),
        content: Text(
          'You answered $correct out of $total questions correctly.\n\n'
          'Analyzing your reading and comprehension data...',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, '/result');
            },
            child: const Text('View Dyslexia Prediction'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xFF81C784);
    const passageBgColor = Color(0xFFE8F5E9);
    const buttonColor = Color(0xFF1ABC9C);
    const buttonTextColor = Colors.white;
    const textColor = Colors.black87;

    final tt = Theme.of(context).textTheme;

    final passageStyle = tt.bodyLarge?.copyWith(
      fontSize: 20,
      height: 1.8,
      color: textColor,
    );
    final questionStyle = tt.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textColor,
    );
    final optionStyle = tt.bodyMedium?.copyWith(
      fontSize: 15,
      color: textColor.withOpacity(0.8),
    );

    return FutureBuilder<List<ComprehensionItem>>(
      future: _futureItems,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || snap.data == null) {
          return Scaffold(
            backgroundColor: passageBgColor,
            body: Center(child: Text('Error: ${snap.error}')),
          );
        }

        final items = snap.data!;
        if (_selected.isEmpty) {
          for (var item in items) {
            _selected.add(List<int?>.filled(item.questions.length, null));
          }
        }
        final item = items[_current];

        return Scaffold(
          backgroundColor: passageBgColor,
          appBar: AppBar(
            backgroundColor: appBarColor,
            foregroundColor: buttonTextColor,
            elevation: 0,
            title: Text(
              'Comprehension ${_current + 1}/${items.length}',
              style: tt.titleLarge?.copyWith(color: buttonTextColor),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Passage Card
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(item.passage, style: passageStyle),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Questions
                Expanded(
                  child: ListView.separated(
                    itemCount: item.questions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (ctx, qi) {
                      final q = item.questions[qi];
                      return Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${qi + 1}. ${q.question}',
                                  style: questionStyle),
                              const SizedBox(height: 8),
                              ...List.generate(q.options.length, (oi) {
                                return RadioListTile<int>(
                                  value: oi,
                                  groupValue: _selected[_current][qi],
                                  title:
                                      Text(q.options[oi], style: optionStyle),
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: buttonColor,
                                  onChanged: (v) {
                                    setState(() => _selected[_current][qi] = v);
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _selected[_current].contains(null)
                        ? null
                        : () => _next(items),
                    child: Text(
                      _current + 1 < items.length ? 'Next' : 'Submit',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


