import 'dart:convert'; 
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:js/js_util.dart' as js_util;
import 'js_interop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'history_page.dart';  // HistoryPage로 이동하는 버튼을 위해



class ReadingSpeedPage extends StatefulWidget {
  final String participantName;
  final int participantAge;

  const ReadingSpeedPage({
    Key? key,
    required this.participantName,
    required this.participantAge,
  }) : super(key: key);

  @override
  State<ReadingSpeedPage> createState() => _ReadingSpeedPageState();
}

class _ReadingSpeedPageState extends State<ReadingSpeedPage> {
  bool _isRecording = false;
  bool _isUploading = false;
  int _elapsedSeconds = 0;
  Stopwatch _stopwatch = Stopwatch();

  String expectedText = 'GPT 지문을 불러오는 중입니다...';

  @override
  void initState() {
    super.initState();
    _fetchPassage();
  }

  Future<void> _fetchPassage() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/get-passages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "age": widget.participantAge,
          "gender": "unknown",
          "native_language": "korean",
        }),
      );

      if (response.statusCode == 200) {
        // Flutter Web: response.body 가 이미 Map<String,dynamic> 일 수 있음
        final dynamic rawBody = response.body;
        final Map<String, dynamic> data = rawBody is String
            ? jsonDecode(rawBody) as Map<String, dynamic>
            : Map<String, dynamic>.from(rawBody as Map);

        final passages = data['passages'] as List<dynamic>;
        setState(() {
          expectedText = passages[0] as String;
        });
      } else {
        setState(() => expectedText = 'GPT 지문을 불러오지 못했습니다.');
        print('❌ GPT fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => expectedText = 'GPT 지문을 불러오는 중 오류 발생');
      print('❌ GPT fetch error: $e');
    }
  }


  Future<void> _startRecording() async {
    try {
    // JS promise를 await
      await startMicRecording();

      _stopwatch.reset();
      _stopwatch.start();
      setState(() {
        _isRecording = true;
        _elapsedSeconds = 0;
      });
    // 기존 타이머 로직 그대로…
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
    // JS promise → Uint8List로 바로 받음
      final bytes = await stopMicRecording();
      await _sendToBackend(bytes);
    } catch (e) {
      print('❌ Error during stopRecording: $e');
      _showErrorDialog('녹음 종료 실패: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _sendToBackend(Uint8List audioBytes) async {
    final uri = Uri.parse('http://localhost:8000/reading_test');

    final request = http.MultipartRequest('POST', uri)
      ..fields['expected'] = expectedText
      ..files.add(http.MultipartFile.fromBytes(
        'audio',
        audioBytes,
        filename: 'recording.webm',
        contentType: MediaType('audio', 'webm'),
      ));

    try {
      final response = await request.send();
      final body     = await response.stream.bytesToString();
      if (response.statusCode == 200) {
      // JSON 디코딩
        final result = jsonDecode(body) as Map<String, dynamic>;

      // 1) accuracy 파싱
        final rawAcc = result['accuracy'];
        double accuracy;
        if (rawAcc is num) {
          accuracy = rawAcc * 100;    // 소수→퍼센트
        } else {
          accuracy = double.parse(rawAcc as String) * 100;
        }

      // 2) words_read 파싱
        final rawWords = result['words_read'] ?? result['words'] ?? 0;
        final wordsRead = (rawWords is num)
          ? rawWords.toInt()
          : int.parse(rawWords as String);

      // 3) duration_seconds 파싱
        final rawDur = result['duration_seconds'] ?? result['duration'] ?? 0;
        final durationSeconds = (rawDur is num)
          ? rawDur.toInt()
          : int.parse(rawDur as String);

      // 4) Firestore에 저장
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reading_results')
          .add({
            'accuracy': accuracy,
            'words_read': wordsRead,
            'duration_seconds': durationSeconds,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // 5) 사용자에게 결과 보여주기
        _showResultDialog(
          'Reading Result',
          '정확도: ${accuracy.toStringAsFixed(1)}%\n'
          '읽은 단어 수: $wordsRead개\n'
          '소요 시간: $durationSeconds초',
        );
      } else {
        _showErrorDialog('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Server error: $e');
    }
  }

  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.participantName} — Age ${widget.participantAge}'),
        backgroundColor: const Color(0xFF81C784),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '읽기 테스트 기록',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    expectedText,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Elapsed Time: $_elapsedSeconds seconds'),
            const SizedBox(height: 16),
            if (_isUploading) const CircularProgressIndicator(),
            if (!_isUploading)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRecording ? null : _startRecording,
                      child: const Text('Start'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRecording ? _stopRecording : null,
                      child: const Text('Stop'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
