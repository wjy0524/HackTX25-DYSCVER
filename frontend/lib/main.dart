// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';                // flutterfire configure 후 생성된 파일
import 'screens/auth_home_page.dart';           // 방금 만든 인증 선택 화면
import 'screens/participant_info_page.dart';    // 기존 사용자 정보 입력 화면

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dyslexia App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 초기 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // 로그인된 사용자가 있으면 ParticipantInfoPage로
          if (snapshot.hasData) {
            return const ParticipantInfoPage();
          }
          // 아니면 인증 홈(AuthHomePage)으로
          return const AuthHomePage();
        },
      ),
    );
  }
}
