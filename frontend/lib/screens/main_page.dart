import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고
                Image.asset('assets/images/logo.png', width: 160),
                const SizedBox(height: 16),

                // DysTrace 타이틀 (letterSpacing 추가)
                Text(
                  "DysTrace",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.green[800],
                    letterSpacing: 1.5, // ✅ 글자 간격 추가
                    shadows: [
                        Shadow(
                            offset: Offset(0.5, 0.5),
                            blurRadius: 0,
                            color: Colors.green[800]!,
                        )
                    ]
                  ),
                ),
                const SizedBox(height: 10),

                // 간단 설명
                Text(
                  "DysTrace는 사용자의 음독 정확도를 분석하여, 난독증 가능성을 조기에 감지할 수 있는 데이터셋을 구축합니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 40),

                // 로그인 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/auth_home_page');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "로그인 또는 가입하기",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 48), // 버튼 아래 여백 더 줌
                Center(
                child: Container(
                    constraints: const BoxConstraints(maxWidth: 920), // 최대 너비 제한
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                    color: Color(0xFFF1F8E9), // 기존보다 살짝 연한 연두
                    borderRadius: BorderRadius.circular(16),
                    //border: Border.all(color: Color(0xFFB2DFDB), width: 1),
                    boxShadow: [
                        BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                        ),
                    ],
                    ),
                    child: const Text(
                    "DysTrace는 난독증 진단을 위한 보조적 데이터 수집 플랫폼입니다.\n\n"
                    "난독증은 그 유형이 다양하고 판단 기준이 명확하지 않아, 단순한 테스트만으로는 쉽게 판별하기 어렵습니다.\n"
                    "DysTrace는 사용자의 읽기 정확도, 발화 내용, 이해도, 시선 추적 정보를 바탕으로\n"
                    "전문가가 보다 신뢰성 있는 판단을 내릴 수 있도록 다양한 데이터를 수집합니다.\n\n"
                    "사용자는 로그인 시 성별, 최종 학력, 나이 등의 기본 정보를 입력하고,\n"
                    "나이에 맞는 수준의 지문을 읽게 됩니다.\n"
                    "읽는 과정은 음성으로 녹음되며, 실제 지문과의 정확도(accuracy)를 바탕으로 읽기 능력을 평가합니다.\n"
                    "또한 지문에 대한 독해 질문을 통해 이해도를 확인하고, 시선 추적을 통해 눈동자 움직임도 함께 기록합니다.\n\n"
                    "DysTrace는 난독증을 직접 진단하지 않지만, 다양한 신호를 바탕으로 종합적인 데이터셋을 구축해\n"
                    "전문가와 연구자들의 판단과 분석을 효과적으로 지원합니다.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15.5,
                        height: 1.8,
                        color: Colors.black87,
                    ),
                    ),
                ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
