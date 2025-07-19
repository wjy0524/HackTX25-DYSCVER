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
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final profile = snap.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('메인 메뉴')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 테스트하기
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
                  child: const Text('테스트하기'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // 프로필 수정하기
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ParticipantInfoPage(isEditing: true)),
                    );
                  },
                  child: const Text('프로필 수정하기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}