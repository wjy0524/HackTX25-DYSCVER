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
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'comprehension_page.dart';

class WordMetrics {
  final int fixationCount;
  final double avgFixationDuration;
  final int regressionCount;

  WordMetrics({
    required this.fixationCount,
    required this.avgFixationDuration,
    required this.regressionCount,
  });

  static final zero = WordMetrics(
    fixationCount: 0, avgFixationDuration: 0.0, regressionCount: 0,
  );
}
// ② computeWordBasedMetrics 함수
WordMetrics computeWordBasedMetrics(
  List<Map<String, dynamic>> eyeData,
  List<Rect> wordRects,
) {
  if (eyeData.isEmpty || wordRects.isEmpty) return WordMetrics.zero;

  int fixationCount    = 0;
  int regressionCount  = 0;
  double totalFixDur   = 0;

  int? prevBox;
  int  prevTime = eyeData.first['t'] as int;

  for (final sample in eyeData) {
    final x = sample['x'] as double;
    final y = sample['y'] as double;
    final t = sample['t'] as int;

    final idx = wordRects.indexWhere((r) => r.contains(Offset(x, y)));

    if (idx == prevBox) {
      totalFixDur += (t - prevTime);
    } else {
      if (prevBox != null) fixationCount++;
      if (prevBox != null && idx < prevBox) regressionCount++;
      prevBox  = idx >= 0 ? idx : null;
      prevTime = t;
    }
  }

  final avgFixDur = fixationCount > 0 ? totalFixDur / fixationCount : 0.0;
  return WordMetrics(
    fixationCount: fixationCount,
    avgFixationDuration: avgFixDur,
    regressionCount: regressionCount,
  );
}

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
    /// ① 지문 텍스트를 `<span class="word">…</span>` 로 감싸 줄 HTML 생성기
  String _buildHtmlFromText(String text) {
    final tokens = text.split(RegExp(r'\s+'));
    return tokens
        .map((t) => '<span class="word">${HtmlEscape().convert(t)}</span>')
        .join(' ');
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


  Future<void> _startRecording() async {
    try {
      // ●— 여기서 단어 박스 좌표 갱신
      js_util.callMethod(js_util.globalThis, 'collectWordBoxes', []);
      // 1) 카메라·시선 추적 켜기
      await startEyeTracking();
      // 2) 캘리브레이션: 텍스트 박스 영역 위의 4×4 포인트 터치
      await _showCalibrationDialogOverTextBox();
      // 3) 녹음 시작
      await startMicRecording();

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

       // 2) 단어 박스 좌표 가져오기
      final wordRects    = await getWordBoxes();
    // 3) 단어 기반 시선 메트릭 계산
      final wordMetrics  = computeWordBasedMetrics(eyeData, wordRects);

      await _sendToBackend(
        bytes,
        eyeData,
        wordMetrics: wordMetrics,
        );
      setState(() => _hasRecorded = true);
    } catch (e) {
      _showErrorDialog('녹음 종료 실패: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _sendToBackend(
    Uint8List audioBytes,
    List<dynamic> eyeData, {
      required WordMetrics wordMetrics,
    }) async {
    final uri = Uri.parse('http://localhost:8000/reading_test');
    final request = http.MultipartRequest('POST', uri)
      ..fields['expected'] = _passages[_currentIndex]
      ..fields['eye_data'] = jsonEncode(eyeData)
      ..fields['fixation_count']      = wordMetrics.fixationCount.toString()
      ..fields['avg_fixation_dur_ms'] = wordMetrics.avgFixationDuration.toStringAsFixed(0)
      ..fields['regression_count']    = wordMetrics.regressionCount.toString()
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
      // 마지막 지문까지 다 읽었으면 → ComprehensionPage 로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ComprehensionPage(
            age: widget.participantAge,
            gender: widget.participantGender,
            nativeLanguage: 'korean', // 필요에 따라 실제 언어값 전달
          ),
        ),
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
  // ① 텍스트 컨테이너에 붙일 키
  final GlobalKey _textBoxKey = GlobalKey();
  Future<void> _showCalibrationDialogOverTextBox() async {
  // ① 텍스트 박스 위치/크기 계산
    final renderBox = _textBoxKey.currentContext!.findRenderObject() as RenderBox;
    final rect      = renderBox.localToGlobal(Offset.zero) & renderBox.size;

  // ② 5×5 포인트 계산
    const int gridSize = 5;
    final points = [
      for (int r = 0; r < gridSize; r++)
        for (int c = 0; c < gridSize; c++)
          Offset(
            rect.left   + rect.width  * c / (gridSize - 1),
            rect.top    + rect.height * r / (gridSize - 1),
          ),
    ];

    int idx = 0;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          return Stack(
            children: [
            // 반투명 배경
              GestureDetector(
                onTap: () {}, // 바깥 터치 막기
                child: Container(color: Colors.black45),
              ),

            // 캘리 포인트
              Positioned(
                left: points[idx].dx - 24,
                top:  points[idx].dy - 24,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // (버퍼 수집은 window.startEyeTracking() 내부에서 이미 실행됩니다)
                  // 다음 포인트 혹은 종료
                    if (idx < points.length - 1) {
                      setSt(() => idx++);
                    } else {
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('●', style: TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                ),
              ),

            // 안내 텍스트
              Positioned(
                left: rect.left,
                top:  rect.bottom + 8,
                width: rect.width,
                child: Text(
                  '점(●)을 보고 클릭해 주세요 (${idx+1}/${points.length})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );

// 캘리브레이션이 끝나면 stopEyeTracking() 은 녹음 종료 시점에 호출하세요.
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
                key: _textBoxKey,         // ← 여기에 키 추가
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
                  child: HtmlWidget(
                // 1) 공백(\s+)으로 토큰화 → 조사 붙은 단어 단위 확보
                  _buildHtmlFromText(currentText),
        // 2) span-word 요소에 CSS 추가 (선택)
                  customStylesBuilder: (element) {
                    if (element.classes.contains('word')) {
                      return {
                        'display': 'inline-block',
                        'padding': '0 2px',    // 단어 앞뒤 살짝 여백
                      };
                    }
                    return null;
                  },
        // 3) 기본 텍스트 스타일 조정
                  textStyle: const TextStyle(
                    fontSize: 50,
                    height: 3,
                    letterSpacing: 5,
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

