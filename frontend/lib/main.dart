import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Firebase CLI로 생성된 파일
import 'screens/main_page.dart'; // ✅ 추가
import 'screens/auth_home_page.dart';
import 'screens/main_menu_page.dart';
import 'screens/participant_info_page.dart';
import 'screens/reading_speed_page.dart';
import 'screens/history_page.dart';
import 'screens/statistics_page.dart';
import 'screens/dyslexia_info_page.dart';
import 'screens/dyslexia_result_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DysTraceApp());
}

class DysTraceApp extends StatelessWidget {
  const DysTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DysTrace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9FFF9),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/main_page': (context) => const MainPage(),
        '/auth_home_page': (context) => const AuthHomePage(),
        '/main_menu': (context) => const MainMenuPage(),
        '/participant_info': (context) => const ParticipantInfoPage(),
        '/reading_speed': (context) => const ReadingSpeedPage(
              participantName: '',
              participantAge: 0,
              participantGender: '',
            ),
        '/history': (context) => const HistoryPage(),
        '/statistics': (context) => const StatisticsPage(),
        '/info': (context) => const DyslexiaInfoPage(),
        '/result': (context) => const DyslexiaResultPage(),
      },
    );
  }
}

/// ✅ 로그인 상태에 따라 자동 분기
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ 로그인된 경우 → 메인 메뉴
        if (snapshot.hasData) {
          return const MainMenuPage();
        }

        // 🚪 로그인 안된 경우 → DysTrace 소개(MainPage)
        return const MainPage();
      },
    );
  }
}


