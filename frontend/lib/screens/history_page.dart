import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/accuracy_chart.dart';           // 읽기용 차트
import '../widgets/accuracy_chart.dart' as comp_chart; // 이해도용 차트
import 'statistics_page.dart';                     // 통계 페이지

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keeps the widget state alive

  late final Stream<QuerySnapshot> _readingStream;
  late final Stream<QuerySnapshot> _compStream;
  late final ScrollController _readingScrollCtrl;
  late final ScrollController _compScrollCtrl;

  // Cache for chart data
  List<FlSpot>? _cachedReadingSpots;
  List<FlSpot>? _cachedCompSpots;
  bool _readingDataLoaded = false;
  bool _compDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Initialize scroll controllers
    _readingScrollCtrl = ScrollController();
    _compScrollCtrl = ScrollController();
    // Create the streams only once to preserve state across rebuilds
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
            return const Text('읽기 기록이 없습니다.');
          }
          
          // Only update cache when we have new data
          if (!_readingDataLoaded || _cachedReadingSpots == null) {
            _cachedReadingSpots = docs.asMap().entries.map((e) => FlSpot(
              e.key.toDouble(),
              (e.value['accuracy'] as num).toDouble(),
            )).toList();
            _readingDataLoaded = true;
          }
          
          return SizedBox(
            height: 200,
            child: AccuracyChart(spots: _cachedReadingSpots!),
          );
        }
        
        // Show cached data if available, otherwise show loading
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
            return const Text('이해도 기록이 없습니다.');
          }
          
          // Only update cache when we have new data
          if (!_compDataLoaded || _cachedCompSpots == null) {
            _cachedCompSpots = docs.asMap().entries.map((e) {
              final data = e.value.data() as Map<String, dynamic>;
              final total = (data['total_questions'] as num).toDouble();
              final correct = (data['correct_answers'] as num).toDouble();
              final pct = total > 0 ? (correct / total * 100) : 0.0;
              return FlSpot(e.key.toDouble(), pct);
            }).toList();
            _compDataLoaded = true;
          }
          
          return SizedBox(
            height: 200,
            child: comp_chart.AccuracyChart(spots: _cachedCompSpots!),
          );
        }
        
        // Show cached data if available, otherwise show loading
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
    super.build(context); // Important for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(title: const Text('히스토리')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 📖 읽기 테스트 차트
          const Text(
            '📖 읽기 테스트',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildReadingChart(),

          const SizedBox(height: 16),
          // 📖 읽기 테스트 테이블 (unchanged)
          Container(
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Scrollbar(
              controller: _readingScrollCtrl,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _readingScrollCtrl,
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _readingStream,
                    builder: (ctx, snap) {
                      if (!snap.hasData) return const SizedBox();
                      final docs = snap.data!.docs;
                      return DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
                        columns: const [
                          DataColumn(label: Text('날짜')),
                          DataColumn(label: Text('정확도')),
                          DataColumn(label: Text('단어수')),
                          DataColumn(label: Text('소요시간')),
                        ],
                        rows: docs.map((d) {
                          final ts = (d['timestamp'] as Timestamp).toDate();
                          final date = '${ts.month}/${ts.day} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}';
                          final acc = (d['accuracy'] as num).toDouble();
                          final words = (d['words_read'] as num).toInt();
                          final secs = (d['duration_seconds'] as num).toInt();
                          return DataRow(cells: [
                            DataCell(Text(date)),
                            DataCell(Text('${acc.toStringAsFixed(1)}%')),
                            DataCell(Text('$words')),
                            DataCell(Text('${secs}초')),
                          ]);
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          // 🧠 이해도 테스트 차트
          const Text(
            '🧠 이해도 테스트',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildComprehensionChart(),

          const SizedBox(height: 16),
          // 🧠 이해도 테스트 테이블 (unchanged)
          Container(
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Scrollbar(
              controller: _compScrollCtrl,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _compScrollCtrl,
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _compStream,
                    builder: (ctx, snap) {
                      if (!snap.hasData) return const SizedBox();
                      final docs = snap.data!.docs;
                      return DataTable(
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
                          final date = '${ts.month}/${ts.day} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}';
                          final total = data['total_questions'] as int;
                          final correct = data['correct_answers'] as int;
                          final pct = total > 0 ? (correct / total * 100).toStringAsFixed(1) : '0';
                          return DataRow(cells: [
                            DataCell(Text(date)),
                            DataCell(Text('$total')),
                            DataCell(Text('$correct')),
                            DataCell(Text('$pct%')),
                          ]);
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // ─── 통계 보기 버튼 ─────────────────────────────────
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsPage()),
            ),
            child: const Text('통계 보기'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}