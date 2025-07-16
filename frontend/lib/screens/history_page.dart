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

          final spots = docs.map((d) {
            final ts  = (d['timestamp'] as Timestamp).millisecondsSinceEpoch.toDouble();
            final acc = (d['accuracy'] as num).toDouble();
            return FlSpot(ts, acc);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 200, child: AccuracyChart(spots: spots)),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final d  = docs[i];
                      final dt = (d['timestamp'] as Timestamp).toDate();
                      final fmt = '${dt.month}/${dt.day} ${dt.hour}:${dt.minute}';
                      return ListTile(
                        title: Text('Accuracy: ${(d['accuracy']*100).toStringAsFixed(1)}%'),
                        subtitle: Text('Words: ${d['words_read']}, Time: ${d['duration_seconds']}s\n$fmt'),
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