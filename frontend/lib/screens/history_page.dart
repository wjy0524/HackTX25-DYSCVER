// lib/screens/history_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/accuracy_chart.dart'; // 읽기용
import '../widgets/accuracy_chart.dart'  // 이해도용도 동일 차트 컴포넌트 재사용
     as comp_chart;

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 1) 읽기 결과 스트림
    final readingStream = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('reading_results')
      .orderBy('timestamp', descending: true)
      .snapshots();

    // 2) 이해도 결과 스트림
    final compStream = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('comprehension_results')
      .orderBy('timestamp', descending: true)
      .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('히스토리')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text('📖 읽기 테스트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // ── 읽기 테스트 차트 & 테이블 ──
            StreamBuilder<QuerySnapshot>(
              stream: readingStream,
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Text('읽기 기록이 없습니다.');

                // FlSpot 리스트 생성 (x=index, y=accuracy)
                final spots = docs.asMap().entries.map((e) => FlSpot(
                  e.key.toDouble(),
                  (e.value['accuracy'] as num).toDouble(),
                )).toList();

                return Column(
                  children: [
                    SizedBox(height: 200, child: AccuracyChart(spots: spots)),
                    const SizedBox(height: 16),

                    // DataTable
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
                        columns: const [
                          DataColumn(label: Text('날짜')),
                          DataColumn(label: Text('정확도')),
                          DataColumn(label: Text('단어수')),
                          DataColumn(label: Text('소요시간')),
                        ],
                        rows: docs.map((d) {
                          final ts = (d['timestamp'] as Timestamp).toDate();
                          final date = '${ts.month}/${ts.day} ${ts.hour}:${ts.minute.toString().padLeft(2,'0')}';
                          final acc   = (d['accuracy'] as num).toDouble();
                          final words = (d['words_read'] as num).toInt();
                          final secs  = (d['duration_seconds'] as num).toInt();
                          return DataRow(cells: [
                            DataCell(Text(date)),
                            DataCell(Text('${acc.toStringAsFixed(1)}%')),
                            DataCell(Text('$words')),
                            DataCell(Text('${secs}초')),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),
            const Text('🧠 이해도 테스트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // ── 이해도 테스트 차트 & 테이블 ──
            StreamBuilder<QuerySnapshot>(
              stream: compStream,
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Text('이해도 기록이 없습니다.');

                // FlSpot: x=index, y=correct/total * 100
                final spots = docs.asMap().entries.map((e) {
                  final data = e.value.data() as Map<String, dynamic>;
                  final total = (data['total_questions'] as num).toDouble();
                  final correct = (data['correct_answers'] as num).toDouble();
                  final pct = total > 0 ? correct/total * 100 : 0.0;
                  return FlSpot(e.key.toDouble(), pct);
                }).toList();

                return Column(
                  children: [
                    SizedBox(height: 200, child: comp_chart.AccuracyChart(spots: spots)),
                    const SizedBox(height: 16),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
                        columns: const [
                          DataColumn(label: Text('날짜')),
                          DataColumn(label: Text('문제수')),
                          DataColumn(label: Text('정답수')),
                          DataColumn(label: Text('정답률')),
                        ],
                        rows: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final ts = (data['timestamp'] as Timestamp).toDate();
                          final date = '${ts.month}/${ts.day} ${ts.hour}:${ts.minute.toString().padLeft(2,'0')}';
                          final total = data['total_questions'] as int;
                          final correct = data['correct_answers'] as int;
                          final pct = total>0 ? (correct/total*100).toStringAsFixed(1) : '0';
                          return DataRow(cells: [
                            DataCell(Text(date)),
                            DataCell(Text('$total')),
                            DataCell(Text('$correct')),
                            DataCell(Text('$pct%')),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}