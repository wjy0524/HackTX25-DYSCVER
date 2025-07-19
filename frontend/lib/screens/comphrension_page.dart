// comphrension_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ComprehensionPage extends StatefulWidget {
  final int age;
  final String gender;
  final String nativeLanguage;
  const ComprehensionPage({
    Key? key,
    required this.age,
    required this.gender,
    required this.nativeLanguage,
  }) : super(key: key);

  @override
  _ComprehensionPageState createState() => _ComprehensionPageState();
}

class _ComprehensionPageState extends State<ComprehensionPage> {
  List _comprehensions = [];
  int _current = 0;
  List<int?> _selected = []; // 지문 당 선택된 옵션 인덱스

  @override
  void initState() {
    super.initState();
    _fetchComprehension();
  }

  Future<void> _fetchComprehension() async {
    final resp = await http.post(
      Uri.parse('http://localhost:8000/get-comprehension-material'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'age': widget.age,
        'gender': widget.gender,
        'native_language': widget.nativeLanguage,
      }),
    );
    final data = jsonDecode(resp.body);
    setState(() {
      _comprehensions = data['comprehensions'];
      _selected = List<int?>.filled(_comprehensions.length, null);
    });
  }

  void _next() {
    if (_current < _comprehensions.length - 1) {
      setState(() => _current++);
    } else {
      _showResult();
    }
  }

  void _showResult() {
    // 채점: answer와 비교
    int correct = 0;
    for (var i = 0; i < _comprehensions.length; i++) {
      if (_selected[i] == _comprehensions[i]['questions'][0]['answer'] ||
          _selected[i] == _comprehensions[i]['questions'][1]['answer']) {
        // 질문별로 다르게 처리해도 되고, 여기선 간단 예시
      }
      // 실제로는 각 question 체크
      for (var q in _comprehensions[i]['questions']) {
        if (_selected[i] == q['answer']) correct++;
      }
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('이해도 테스트 결과'),
        content: Text('총 ${_comprehensions.length * 2}문제 중 $correct문제 정답'),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/history')),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_comprehensions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final item = _comprehensions[_current];
    return Scaffold(
      appBar: AppBar(title: Text('이해도 지문 ${_current+1}/${_comprehensions.length}')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: Text(item['passage']))),
            ...List.generate(item['questions'].length, (qi) {
              final q = item['questions'][qi];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${qi+1}. ${q['question']}'),
                  ...List.generate(q['options'].length, (oi) {
                    return RadioListTile<int>(
                      value: oi,
                      groupValue: _selected[_current],
                      title: Text(q['options'][oi]),
                      onChanged: (v) => setState(() => _selected[_current] = v),
                    );
                  }),
                ],
              );
            }),
            ElevatedButton(onPressed: _next, child: Text(_current+1<_comprehensions.length?'다음':'제출')),
          ],
        ),
      ),
    );
  }
}