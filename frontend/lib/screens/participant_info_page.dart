import 'package:flutter/material.dart';
import 'reading_speed_page.dart';
import '../services/firestore_service.dart';
import 'history_page.dart';  // ← 이 줄을 추가하세요

class ParticipantInfoPage extends StatefulWidget {
  const ParticipantInfoPage({Key? key}) : super(key: key);

  @override
  State<ParticipantInfoPage> createState() => _ParticipantInfoPageState();
}

class _ParticipantInfoPageState extends State<ParticipantInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _onNext() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameCtrl.text.trim();
     final age = int.parse(_ageCtrl.text.trim());
    
      try {
      // 1) 파이어스토어에 유저 프로필 저장
        await FirestoreService.saveUserProfile(age, 'unknown');
      // 2) 다음 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReadingSpeedPage(
              participantName: name,
              participantAge: age,
            ),
          ),
        );
      } catch (e) {
        _showErrorDialog('프로필 저장 실패: $e');
      }
    }
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return '이름을 입력해 주세요.';
    return null;
  }

  String? _validateAge(String? v) {
    if (v == null || v.trim().isEmpty) return '나이를 입력해 주세요.';
    final age = int.tryParse(v.trim());
    if (age == null || age <= 0) return '올바른 나이를 표기해 주세요.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('이용자 정보'),
        backgroundColor: const Color(0xFF81C784),
        elevation: 0,
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name field
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white, // 입력창 배경은 흰색
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16),

              // Age field
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(
                  labelText: '나이',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: _validateAge,
              ),
              const SizedBox(height: 32),

              // Next button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A), // 버튼도 연두계열
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _onNext,
                  child: const Text(
                    '다음',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
