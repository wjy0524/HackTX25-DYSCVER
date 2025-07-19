// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';      // flutterfire cli 로 생성된 파일
import 'screens/auth_home_page.dart';
import 'screens/participant_info_page.dart';
import 'screens/reading_speed_page.dart';
import 'screens/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/main_menu_page.dart';   // ← 추가



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
      routes: {
        '/auth_home_page': (context) => const AuthHomePage(),
      }, 

    );
  }
}

/// 로그인 상태에 따라 진입 페이지를 달리 보여줍니다.
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snap.data;
        if (user == null) {
          // 아직 로그인 안 한 상태
          return const MainPage();  
        }
        // 로그인 한 상태 → 프로필 유무 확인
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (ctx, profSnap) {
            if (profSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (!profSnap.hasData || !profSnap.data!.exists) {
              // 프로필이 아직 없으면 작성 페이지로
              return ParticipantInfoPage();
            }
            // 프로필이 있으면 메인 메뉴로
            return MainMenuPage();
          },
        );
      },
    );
  }
}