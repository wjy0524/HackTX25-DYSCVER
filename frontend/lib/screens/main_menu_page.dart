import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'participant_info_page.dart';
import 'reading_speed_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
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
                    // Logo
                    Image.asset('assets/images/dyslexia_logo.png', width: 160),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      "DysTrace",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.green[800],
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 0,
                            color: Colors.green[800]!,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    Text(
                      "DysTrace is a tool that measures reading speed and accuracy,\n"
                      "and evaluates comprehension performance.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 40),

                    // Buttons (horizontal layout)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Start Test Button
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
                              "Start Test",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Edit Profile Button
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ParticipantInfoPage(isEditing: true),
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
                              "Edit Profile",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Instruction Box
                    Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 920),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8E9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          "1. Screen Calibration\n"
                          "Tap the white dots with blue outlines in the order they appear "
                          "to calibrate your eye position.\n"
                          "Small red dots will track your gaze — when they align with the white dots, "
                          "tap the white dots for more accurate results.\n\n"
                          "2. Reading Test\n"
                          "The 'Reading Test' is conducted three times.\n"
                          "Press 'Start' to begin reading aloud. The timer runs during reading, "
                          "and you can stop anytime by pressing 'Stop'.\n\n"
                          "3. Comprehension Test\n"
                          "After completing the reading tests, the 'Comprehension Test' will begin.\n"
                          "This is a simple multiple-choice quiz to check your understanding of each passage.\n"
                          "There are three passages, each with two comprehension questions.\n\n"
                          "4. View Results\n"
                          "After completing all stages, you can check your previous results "
                          "with charts and tables on the 'History' page.\n\n"
                          "If you need help, tap the '?' icon in the top-right corner.",
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