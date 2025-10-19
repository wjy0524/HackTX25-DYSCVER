import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/main_menu_page.dart';
import '../screens/reading_speed_page.dart';
import '../screens/history_page.dart';
import '../screens/statistics_page.dart';
import '../screens/dyslexia_info_page.dart';
import '../screens/participant_info_page.dart';
import '../screens/main_page.dart';

class CustomNavBar extends StatelessWidget {
  final bool hideNav;
  const CustomNavBar({super.key, this.hideNav = false});

  @override
  Widget build(BuildContext context) {
    if (hideNav) return const SizedBox.shrink(); // 👈 테스트 중엔 숨김

    final user = FirebaseAuth.instance.currentUser;
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Container(
      height: 70,
      color: const Color(0xFF81C784),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ───── Logo & Title ─────
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainMenuPage()),
            ),
            child: Row(
              children: [
                Image.asset('assets/images/dyslexia_logo.png', height: 38),
                const SizedBox(width: 10),
                const Text(
                  "DysTrace",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // ───── Center Menu ─────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navItem(context, "Home", const MainMenuPage(), currentRoute.contains("MainMenuPage")),
              _navItem(context, "Test", const ReadingSpeedPage(
                participantName: "",
                participantAge: 0,
                participantGender: "",
              ), currentRoute.contains("ReadingSpeedPage")),
              _navItem(context, "Results", const HistoryPage(), currentRoute.contains("HistoryPage")),
              _navItem(context, "Statistics", const StatisticsPage(), currentRoute.contains("StatisticsPage")),
              _navItem(context, "Info", const DyslexiaInfoPage(), currentRoute.contains("DyslexiaInfoPage")),
            ],
          ),

          // ───── Profile / Logout ─────
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ParticipantInfoPage(isEditing: true),
                  ),
                );
              } else if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainPage()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.account_circle, color: Colors.white, size: 32),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Edit Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Log Out'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String label, Widget page, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
