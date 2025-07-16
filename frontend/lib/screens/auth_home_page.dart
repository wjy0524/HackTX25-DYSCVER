// lib/screens/auth_home_page.dart

import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'google_sign_in_page.dart';

class AuthHomePage extends StatelessWidget {
  const AuthHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('로그인 또는 가입'),
        backgroundColor: const Color(0xFF81C784),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이메일 로그인
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66BB6A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('이메일로 로그인', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
          
            // 이메일 회원가입
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('이메일로 회원가입', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            // 구글 로그인
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GoogleSignInPage()),
                ),
                icon: Image.asset('assets/images/google_icon.png', width: 24, height: 24),
                label: const Text('구글 계정으로 로그인', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}