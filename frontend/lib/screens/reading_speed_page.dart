import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:js/js_util.dart' as js_util;
import 'js_interop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'history_page.dart';

class ReadingSpeedPage extends StatefulWidget {
  final String participantName;
  final int participantAge;
  final String participantGender;

  const ReadingSpeedPage({
    Key? key,
    required this.participantName,
    required this.participantAge,
    required this.participantGender,
  }) : super(key: key);

  @override
  State<ReadingSpeedPage> createState() => _ReadingSpeedPageState();
}

class _ReadingSpeedPageState extends State<ReadingSpeedPage> {
  bool _isRecording = false;
  bool _isUploading = false;
  int _elapsedSeconds = 0;
  Stopwatch _stopwatch = Stopwatch();


  List<String> _passages = [];
  int _currentIndex = 0;
  bool _hasRecorded = false;

  @override
  void initState() {
    super.initState();
    _fetchPassages();
  }

  Future<void> _fetchPassages() async {
    try {
      final resp = await http.post(
        Uri.parse('http://localhost:8000/get-passages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'age': widget.participantAge,
          'gender': widget.participantGender,
          'native_language': 'korean',
        }),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['passages'];
        setState(() {
          _passages = (raw as List).map((e) => e is Map && e.containsKey('text') ? e['text'] as String : e.toString()).toList();
          _currentIndex = 0;
          _hasRecorded = false;
        });
      } else {
        _showErrorDialog('지문을 불러오지 못했습니다: ${resp.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('지문 로드 중 오류 발생: $e');
    }
  }

  Future<void> _showCalibrationDialog() async {
    final corners = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomRight,
      Alignment.bottomLeft,
    ];
    int idx = 0;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          Future.delayed(const Duration(seconds: 1), () {
            if (idx < corners.length - 1) {
              idx++;
              setSt(() {});
            } else {
              Navigator.of(ctx).pop();
            }
          });
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: SizedBox.expand(
              child: Stack(
                children: [
                  Align(
                    alignment: corners[idx],
                    child: Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      await startMicRecording();
      await startEyeTracking();
      await _showCalibrationDialog();

      _stopwatch.reset();
      _stopwatch.start();
      setState(() {
        _isRecording = true;
        _elapsedSeconds = 0;
      });

      await Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        if (!_stopwatch.isRunning) return false;
        setState(() => _elapsedSeconds++);
        return true;
      });
    } catch (e) {
      _showErrorDialog('녹음 시작 실패: $e');
    }
  }

  Future<void> _stopRecording() async {
    _stopwatch.stop();
    setState(() {
      _isRecording = false;
      _isUploading = true;
    });
    try {
      final bytes = await stopMicRecording();
      final eyeData = await stopEyeTracking();
      await _sendToBackend(bytes, eyeData);
      setState(() => _hasRecorded = true);
    } catch (e) {
      _showErrorDialog('녹음 종료 실패: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _sendToBackend(Uint8List audioBytes, List<dynamic> eyeData) async {
    final uri = Uri.parse('http://localhost:8000/reading_test');
    final request = http.MultipartRequest('POST', uri)
      ..fields['expected'] = _passages[_currentIndex]
      ..fields['eye_data'] = jsonEncode(eyeData)
      ..files.add(http.MultipartFile.fromBytes(
        'audio', audioBytes,
        filename: 'recording.webm',
        contentType: MediaType('audio', 'webm'),
      ));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final result = jsonDecode(body) as Map<String, dynamic>;
      final accuracy = (result['accuracy'] as num).toDouble();
      final wordsRead = (result['words_read'] as num).toInt();
      final durationSeconds = (result['duration_seconds'] as num).toInt();
      final fixationCount = (result['fixation_count'] as num).toInt();
      final avgFixationDuration = (result['avg_fixation_duration'] as num).toDouble();
      final regressionCount = (result['regression_count'] as num).toInt();
      final cognitiveLoad = (result['cognitive_load'] as num).toDouble();
      final fluencyScore = (result['fluency_score'] as num).toDouble();

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reading_results')
          .add({
        'accuracy': accuracy,
        'words_read': wordsRead,
        'duration_seconds': durationSeconds,
        'fixation_count': fixationCount,
        'avg_fixation_duration': avgFixationDuration,
        'regression_count': regressionCount,
        'cognitive_load': cognitiveLoad,
        'fluency_score': fluencyScore,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showEyeResultDialog(
        _currentIndex,
        accuracy: accuracy,
        wordsRead: wordsRead,
        durationSeconds: durationSeconds,
        fixationCount: fixationCount,
        avgFixationDuration: avgFixationDuration,
        regressionCount: regressionCount,
        cognitiveLoad: cognitiveLoad,
        fluencyScore: fluencyScore,
      );
    } else {
      _showErrorDialog('Upload failed: ${response.statusCode}');
    }
  }

  void _showEyeResultDialog(
    int roundIndex, {
    required double accuracy,
    required int wordsRead,
    required int durationSeconds,
    required int fixationCount,
    required double avgFixationDuration,
    required int regressionCount,
    required double cognitiveLoad,
    required double fluencyScore,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('지문 ${roundIndex + 1} 결과'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('정확도: ${accuracy.toStringAsFixed(1)}%'),
            Text('읽은 단어 수: $wordsRead개'),
            Text('소요 시간: ${durationSeconds}초'),
            const Divider(),
            Text('고정 시선 횟수: ${fixationCount}회'),
            Text('평균 고정 지속시간: ${avgFixationDuration.toStringAsFixed(0)}ms'),
            Text('역행 횟수: ${regressionCount}회'),
            Text('인지 부하 지수: ${cognitiveLoad.toStringAsFixed(1)}'),
            Text('유창성 점수: ${fluencyScore.toStringAsFixed(1)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _goToNextRound,
            child: Text(
              _currentIndex < _passages.length - 1
                  ? '다음 지문 읽기'
                  : '세션 종료',
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextRound() {
    Navigator.pop(context);
    if (_currentIndex < _passages.length - 1) {
      setState(() {
        _currentIndex++;
        _elapsedSeconds = 0;
        _hasRecorded = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HistoryPage()),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_passages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentText = _passages[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('지문 ${_currentIndex + 1}/${_passages.length}'),
        backgroundColor: const Color(0xFF81C784),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '기록 보기',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    currentText,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '경과 시간: $_elapsedSeconds초',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (_isUploading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRecording ? null : _startRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1ABC9C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Start'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRecording ? _stopRecording : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Stop'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (!_isRecording && !_isUploading && _hasRecorded)
              ElevatedButton(
                onPressed: () {
                  if (_currentIndex < _passages.length - 1) {
                    setState(() {
                      _currentIndex++;
                      _elapsedSeconds = 0;
                      _hasRecorded = false;
                    });
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text(
                  _currentIndex < _passages.length - 1
                      ? '다음 지문 (${_currentIndex + 2}/${_passages.length})'
                      : '테스트 종료',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

