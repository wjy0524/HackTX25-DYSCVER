// lib/screens/comprehension_page.dart

import 'package:flutter/material.dart';
import '../model/comprehension.dart';
import '../services/comprehension_service.dart';
import 'history_page.dart'; // ← 추가
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

  void _showResult(List<ComprehensionItem> items) async{
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
    // 쓰기 에러만 잡아서 사용자에게 알림
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('결과 저장에 실패했습니다: $e')),
    );
    return;  // 여기서 함수 종료!
  }

  showDialog(
    context: context,
    barrierDismissible: false, // 사용자가 배경 탭으로 닫지 못하게
    builder: (ctx) => AlertDialog(
      title: const Text('이해도 테스트 결과'),
      content: Text('총 $total문제 중 $correct문제 정답'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop(); // 다이얼로그 닫고
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            );
          },
          child: const Text('결과 보기'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ComprehensionItem>>(
      future: _futureItems,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || snap.data == null) {
          return Scaffold(body: Center(child: Text('오류: ${snap.error}')));
        }

        final items = snap.data!;
        // 첫 로딩 뒤에 _selected 초기화
        if (_selected.isEmpty) {
          for (var item in items) {
            _selected.add(List<int?>.filled(item.questions.length, null));
          }
        }

        final item = items[_current];
        return Scaffold(
          appBar: AppBar(
            title: Text('이해도 지문 ${_current + 1}/${items.length}'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(child: SingleChildScrollView(child: Text(item.passage))),
                const SizedBox(height: 16),
                // 질문별 RadioListTile
                ...List.generate(item.questions.length, (qi) {
                  final q = item.questions[qi];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${qi + 1}. ${q.question}'),
                      ...List.generate(q.options.length, (oi) {
                        return RadioListTile<int>(
                          value: oi,
                          groupValue: _selected[_current][qi],
                          title: Text(q.options[oi]),
                          onChanged: (v) {
                            setState(() => _selected[_current][qi] = v);
                          },
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                  );
                }),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _selected[_current].contains(null)
                      ? null
                      : () => _next(items),
                  child: Text(
                    _current + 1 < items.length ? '다음' : '제출',
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