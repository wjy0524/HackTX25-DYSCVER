// lib/screens/history_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/accuracy_chart.dart';                    // 읽기용 차트
import '../widgets/accuracy_chart.dart' as comp_chart;     // 이해도용 차트
import 'statistics_page.dart';                             // 통계 페이지

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final Stream<QuerySnapshot> _readingStream;
  late final Stream<QuerySnapshot> _compStream;
  late final ScrollController _readingScrollCtrl;
  late final ScrollController _compScrollCtrl;

  // 차트 데이터 캐시
  List<FlSpot>? _cachedReadingSpots;
  List<FlSpot>? _cachedCompSpots;
  bool _readingDataLoaded = false;
  bool _compDataLoaded = false;

  // 프로젝트 색상
  static const Color _mainGreen  = Color(0xFF81C784);
  static const Color _lightGreen = Color(0xFFC8E6C9);
  static const Color _darkGreen  = Color(0xFF388E3C);

  @override
  void initState() {
    super.initState();
    _readingScrollCtrl = ScrollController();
    _compScrollCtrl    = ScrollController();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _readingStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reading_results')
        .orderBy('timestamp', descending: true)
        .snapshots();
    _compStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('comprehension_results')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _readingScrollCtrl.dispose();
    _compScrollCtrl.dispose();
    super.dispose();
  }

  Widget _buildReadingChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: _readingStream,
      builder: (ctx, snap) {
        if (snap.hasData) {
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            _readingDataLoaded = true;
            return const Text('읽기 기록이 없습니다.',
                style: TextStyle(color: Colors.black));
          }
          if (!_readingDataLoaded || _cachedReadingSpots == null) {
            _cachedReadingSpots = docs.asMap().entries.map((e) =>
              FlSpot(e.key.toDouble(),
                     (e.value['accuracy'] as num).toDouble()))
              .toList();
            _readingDataLoaded = true;
          }
          return SizedBox(
            height: 200,
            child: AccuracyChart(spots: _cachedReadingSpots!),
          );
        }
        if (_cachedReadingSpots != null) {
          return SizedBox(
            height: 200,
            child: AccuracyChart(spots: _cachedReadingSpots!),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildComprehensionChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: _compStream,
      builder: (ctx, snap) {
        if (snap.hasData) {
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            _compDataLoaded = true;
            return const Text('이해도 기록이 없습니다.',
                style: TextStyle(color: Colors.black));
          }
          if (!_compDataLoaded || _cachedCompSpots == null) {
            _cachedCompSpots = docs.asMap().entries.map((e) {
              final data = e.value.data() as Map<String, dynamic>;
              final tot  = (data['total_questions']  as num).toDouble();
              final corr = (data['correct_answers'] as num).toDouble();
              final pct  = tot > 0 ? (corr / tot * 100) : 0.0;
              return FlSpot(e.key.toDouble(), pct);
            }).toList();
            _compDataLoaded = true;
          }
          return SizedBox(
            height: 200,
            child: comp_chart.AccuracyChart(spots: _cachedCompSpots!),
          );
        }
        if (_cachedCompSpots != null) {
          return SizedBox(
            height: 200,
            child: comp_chart.AccuracyChart(spots: _cachedCompSpots!),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('히스토리'),
        backgroundColor: _mainGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── 읽기 테스트 ─────────────────────────────
          Text(
            '📖 읽기 테스트',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildReadingChart(),
            ),
          ),

          // ─── 읽기 테스트 표 ─────────────────────────────
          Card(
            color: _lightGreen.withOpacity(0.3),
            elevation: 1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 32),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: _lightGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                // ★ 여기만 LayoutBuilder로 감싸서 폭 꽉 채우기
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final tableWidth = constraints.maxWidth;
                    return Scrollbar(
                      controller: _readingScrollCtrl,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _readingScrollCtrl,
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: tableWidth),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _readingStream,
                              builder: (ctx, snap) {
                                if (!snap.hasData) return const SizedBox();
                                final docs = snap.data!.docs;
                                return DataTable(
                                  headingRowColor: MaterialStateProperty.all(_lightGreen),
                                  dataRowColor: MaterialStateProperty.all(Colors.white),
                                  columns: const [
                                    DataColumn(label: Text('날짜', style: TextStyle(color: Colors.black))),
                                    DataColumn(label: Text('정확도', style: TextStyle(color: Colors.black))),
                                    DataColumn(label: Text('단어수', style: TextStyle(color: Colors.black))),
                                    DataColumn(label: Text('소요시간', style: TextStyle(color: Colors.black))),
                                  ],
                                  rows: docs.map((d) {
                                    final ts = (d['timestamp'] as Timestamp).toDate();
                                    final date = '${ts.month}/${ts.day} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}';
                                    final acc   = (d['accuracy'] as num).toDouble();
                                    final words = (d['words_read'] as num).toInt();
                                    final secs  = (d['duration_seconds'] as num).toInt();
                                    return DataRow(cells: [
                                      DataCell(Text(date,   style: const TextStyle(color: Colors.black))),
                                      DataCell(Text('${acc.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.black))),
                                      DataCell(Text('$words', style: const TextStyle(color: Colors.black))),
                                      DataCell(Text('${secs}초', style: const TextStyle(color: Colors.black))),
                                    ]);
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ─── 이해도 테스트 ─────────────────────────────
          Text(
            '🧠 이해도 테스트',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildComprehensionChart(),
            ),
          ),

          // ─── 이해도 테스트 표 ─────────────────────────────
          Card(
            color: _lightGreen.withOpacity(0.3),
            elevation: 1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 32),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: _lightGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final tableWidth = constraints.maxWidth;
                    return Scrollbar(
                      controller: _compScrollCtrl,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _compScrollCtrl,
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: tableWidth),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _compStream,
                              builder: (ctx, snap) {
                                if (!snap.hasData) return const SizedBox();
                                final docs = snap.data!.docs;
                                return DataTable(
                                  headingRowColor: MaterialStateProperty.all(_lightGreen),
                                  dataRowColor: MaterialStateProperty.all(Colors.white),
                                  columns: const [
                                    DataColumn(label: Text('날짜', style: TextStyle(color: Colors.black))),
                                    DataColumn(label: Text('문제수', style: TextStyle(color: Colors.black))),
                                    DataColumn(label: Text('정답수', style: TextStyle(color: Colors.black))),
                                    DataColumn(label: Text('정답률', style: TextStyle(color: Colors.black))),
                                  ],
                                  rows: docs.map((d) {
                                    final data = d.data()! as Map<String, dynamic>;
                                    final ts = (data['timestamp'] as Timestamp).toDate();
                                    final date = '${ts.month}/${ts.day} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}';
                                    final total  = data['total_questions'] as int;
                                    final correct= data['correct_answers'] as int;
                                    final pct    = total > 0
                                        ? (correct / total * 100).toStringAsFixed(1)
                                        : '0';
                                    return DataRow(cells: [
                                      DataCell(Text(date,   style: const TextStyle(color: Colors.black))),
                                      DataCell(Text('$total', style: const TextStyle(color: Colors.black))),
                                      DataCell(Text('$correct', style: const TextStyle(color: Colors.black))),
                                      DataCell(Text('$pct%', style: const TextStyle(color: Colors.black))),
                                    ]);
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ─── 통계 보기 버튼 ─────────────────────────────
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsPage()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _mainGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('통계 보기'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
