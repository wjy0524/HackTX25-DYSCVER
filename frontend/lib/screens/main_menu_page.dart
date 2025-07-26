// lib/screens/main_menu_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'participant_info_page.dart';
import 'reading_speed_page.dart';


class MainMenuPage extends StatelessWidget {
  const MainMenuPage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadProfile(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snap.data!;
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

                    // DysTrace 타이틀
                    Text(
                      "DysTrace",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.green[800],
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            offset: Offset(0.5, 0.5),
                            blurRadius: 0,
                            color: Colors.green[800]!,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 간단 설명
                    Text(
                      "DysTrace는 읽기 속도와 정확도를 측정하고, 이해도를 확인할 수 있는 도구입니다.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 40),

                    // 두 개의 버튼을 가로 배치 (크기 고정)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 테스트하기 버튼
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReadingSpeedPage(
                                    participantName: profile['name'],
                                    participantAge: profile['age'],
                                    participantGender: profile['gender'],
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "테스트하기",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // 프로필 수정하기 버튼
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ParticipantInfoPage(isEditing: true),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "프로필 수정하기",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // 설명 박스
                    Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 920),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8E9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          "1. 화면 준비\n"
                          "화면에 나타나는 하얀색에 파란색 테두리의 점들을 나타나는 순서대로 눌러 눈 위치를 맞춰주세요.\n"
                          "작은 빨간색 점들이 눈을 따라갈텐데 빨간색 점들이 하얀색 점에 모여졌을때 하얀색 점을 눌러주셔야 보다 정확한 결과를 낼 수 있어요.\n\n"
                          "2. 지문 읽기 테스트\n"
                          "'지문 읽기 테스트'는 3번에 걸쳐서 진행됩니다.\n"
                          "‘start’ 버튼을 눌러 지문을 소리 내어 읽습니다. 읽는 동안 시간이 측정되며, 멈추려면 'stop’ 버튼을 눌러주세요.\n\n"
                          "3. 이해도 확인 테스트\n"
                          "'지문 읽기 테스트'가 끝나면 '이해도 확인 테스트'가 진행됩니다.\n"
                          "'이해도 확인 테스트'는 지문을 읽은 후 이해도를 확인하기 위한 간단한 선택형 문제입니다.\n"
                          "세 지문이 주어지며, 각 지문당 2개의 객관식 독해문제로 구성됩니다.\n\n"
                          "4. 결과 보기\n"
                          "모든 단계를 마치면 ‘기록 보기’에서 지난 결과를 차트와 표로 확인할 수 있어요.\n\n"
                          "도움이 필요할 때는 우측 상단 ‘?’ 아이콘을 눌러주세요.",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15.5,
                            height: 1.6,
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
      },
    );
  }
}