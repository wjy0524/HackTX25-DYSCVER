import 'package:flutter/material.dart';
import 'reading_speed_page.dart';

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

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      final name = _nameCtrl.text.trim();
      final age = int.parse(_ageCtrl.text.trim());
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingSpeedPage(
            participantName: name,
            participantAge: age,
          ),
        ),
      );
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
      // 1) Scaffold 배경색을 연두색으로
      backgroundColor: const Color(0xFFE8F5E9),
      // 2) AppBar 색상도 맞춤
      appBar: AppBar(
        title: const Text('이용자 정보'),
        backgroundColor: const Color(0xFF81C784), // 짙은 연두
        elevation: 0, // 그림자 없애기
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
