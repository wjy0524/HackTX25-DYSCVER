// lib/screens/history_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/accuracy_chart.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final resultsRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('reading_results')
      .orderBy('timestamp');

    return Scaffold(
      appBar: AppBar(title: const Text('읽기 테스트 히스토리')),
      body: StreamBuilder<QuerySnapshot>(
        stream: resultsRef.snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('아직 기록이 없습니다.'));
          
          // ─────────── 차트 ───────────
          final spots = docs
            .asMap()
            .entries
            .map((e) => FlSpot(
              e.key.toDouble(), 
              (e.value['accuracy'] as num).toDouble(),
            ))
            .toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 200, child: AccuracyChart(spots: spots)),
                const SizedBox(height: 24),

                // ─────────── 테이블 ───────────
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
                        dataRowColor: MaterialStateProperty.resolveWith((states) {
                          return states.contains(MaterialState.selected)
                            ? Colors.green.shade100
                            : null;
                        }),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('날짜', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('정확도', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('단어수', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('소요시간', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: docs.map((d) {
                          final ts   = (d['timestamp'] as Timestamp).toDate();
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}