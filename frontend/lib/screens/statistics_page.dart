import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/bar_chart.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 개인 스트림 (오름차순: 최신이 마지막)
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

    // ■ 범례용 dot+label 위젯
    Widget _dotLabel(Color color, String text) {
      return Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(text),
        ],
      );
    }

    // ■ 범례 전체 Row
    Widget legend() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _dotLabel(Colors.red, '나의 최신 결과'),
            const SizedBox(width: 16),
            _dotLabel(Colors.blue, '다른 참가자 평균'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('통계 보기')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── 읽기 통계 ────────────────────────────────
          const Text('📊 읽기 통계', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          legend(),
          StreamBuilder<QuerySnapshot>(
            stream: allReadingStream,
            builder: (ctx, allSnap) {
              if (!allSnap.hasData) return const Center(child: CircularProgressIndicator());

              // 다른 참가자별 accuracy 모아 평균 계산
              final docsAll = allSnap.data!.docs;
              final Map<String, List<double>> buf = {};
              for (final d in docsAll) {
                final parent = d.reference.parent.parent;
                if (parent == null || parent.id == uid) continue;
                buf.putIfAbsent(parent.id, () => <double>[]).add((d['accuracy'] as num).toDouble());
              }
              final otherAvgs = buf.values
                  .map((lst) => lst.reduce((a, b) => a + b) / lst.length)
                  .toList()
                ..sort();

              return StreamBuilder<QuerySnapshot>(
                stream: readingStream,
                builder: (ctx, meSnap) {
                  if (!meSnap.hasData) return const Center(child: CircularProgressIndicator());
                  final myDocs = meSnap.data!.docs;
                  if (myDocs.isEmpty) return const Text('내 읽기 기록이 없습니다.');

                  // 나의 최신 결과 하나
                  final lastAcc = (myDocs.last['accuracy'] as num).toDouble();

                  // 파란(다른 참가자 평균) + 중앙에 빨간(내 최신)
                  final mid = (otherAvgs.length / 2).floor();
                  final values = [...otherAvgs]..insert(mid, lastAcc);
                  final colors = List<Color>.filled(values.length, Colors.blue)
                    ..[mid] = Colors.red;

                  return BarChartWithColors(values: values, colors: colors);
                },
              );
            },
          ),

          const SizedBox(height: 32),

          // ─── 이해도 통계 ───────────────────────────────
          const Text('📈 이해도 통계', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          legend(),
          StreamBuilder<QuerySnapshot>(
            stream: allCompStream,
            builder: (ctx, allSnap) {
              if (!allSnap.hasData) return const Center(child: CircularProgressIndicator());

              // 다른 참가자별 comprehension % 모아 평균 계산
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
                  if (!meSnap.hasData) return const Center(child: CircularProgressIndicator());
                  final myDocs = meSnap.data!.docs;
                  if (myDocs.isEmpty) return const Text('내 이해도 기록이 없습니다.');

                  final data = myDocs.last.data()! as Map<String, dynamic>;
                  final tot = (data['total_questions'] as num).toDouble();
                  final corr = (data['correct_answers'] as num).toDouble();
                  final lastPct = tot > 0 ? corr / tot * 100 : 0.0;

                  final mid = (otherAvgs.length / 2).floor();
                  final values = [...otherAvgs]..insert(mid, lastPct);
                  final colors = List<Color>.filled(values.length, Colors.blue)
                    ..[mid] = Colors.red;

                  return BarChartWithColors(values: values, colors: colors);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}