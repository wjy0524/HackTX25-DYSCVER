import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:js/js_util.dart' as js_util;
import 'js_interop.dart';

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
    final uri = Uri.parse('http://localhost:8000/get-passages');
    final body = jsonEncode({
      "age": widget.participantAge,
      "gender": "unknown", // you can replace this with actual value
      "native_language": "korean", // you can make this dynamic too
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final passages = data['passages'] as List<dynamic>;
        setState(() {
          expectedText = passages[0];
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
      startMicRecording();
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
      final base64 = await js_util.promiseToFuture<String>(stopMicRecording());
      final bytes = base64Decode(base64);
      await _sendToBackend(bytes);
    } catch (e) {
      print('❌ Error during stopRecording: $e');
      _showErrorDialog('Recording failed. Please try again.');
    }

    setState(() => _isUploading = false);
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
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('✅ Transcription result:\n$body');
        _showResultDialog('Success', body);
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        _showErrorDialog('Upload failed. Code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception sending to backend: $e');
      _showErrorDialog('Server error. Make sure backend is running.');
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
