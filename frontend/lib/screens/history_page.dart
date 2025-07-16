// lib/screens/history_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/accuracy_chart.dart';   // 방금 만든 차트 위젯
import 'package:fl_chart/fl_chart.dart';   // FlSpot

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final resultsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reading_results')
        .orderBy('timestamp', descending: false);

    return Scaffold(
      appBar: AppBar(title: const Text('읽기 테스트 히스토리')),
      body: StreamBuilder<QuerySnapshot>(
        stream: resultsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('아직 기록이 없습니다.'));
          }

          // FlSpot 목록 생성 (x: 타임스탬프_ms, y: accuracy)
          final spots = docs.map((doc) {
            final ts = doc['timestamp'] as Timestamp;
            final acc = (doc['accuracy'] as num).toDouble();
            return FlSpot(ts.millisecondsSinceEpoch.toDouble(), acc);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1) 꺾은선 차트
                SizedBox(
                  height: 200,
                  child: AccuracyChart(spots: spots),
                ),
                const SizedBox(height: 24),
                // 2) 기존 리스트
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final d = docs[i];
                      final ts = (d['timestamp'] as Timestamp).toDate();
                      final fmt = '${ts.month}/${ts.day} ${ts.hour}:${ts.minute}';
                      return ListTile(
                        title: Text('Accuracy: ${(d['accuracy']*100).toStringAsFixed(1)}%'),
                        subtitle: Text('읽은 단어: ${d['words_read']}개\n시간: ${d['duration_seconds']}초\n$fmt'),
                      );
                    },
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
