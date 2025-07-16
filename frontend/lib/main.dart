// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';      // flutterfire cli 로 생성된 파일
import 'screens/auth_home_page.dart';
import 'screens/participant_info_page.dart';
import 'screens/reading_speed_page.dart';

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
      home: AuthGate(),
    );
  }
}

/// 로그인 상태에 따라 진입 페이지를 달리 보여줍니다.
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snap.data;
        if (user == null) {
          // 로그인 전
          return const AuthHomePage();
        }
        // 로그인 후, 프로필 정보가 있는지 체크하고 없으면 ParticipantInfoPage
        // (여기선 단순히 바로 ParticipantInfoPage 로 보냄)
        return const ParticipantInfoPage();
      },
    );
  }
}