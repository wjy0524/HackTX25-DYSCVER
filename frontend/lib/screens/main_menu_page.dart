import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/main_layout.dart';
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
          return const Center(child: CircularProgressIndicator());
        }

        final profile = snap.data!;
        return MainLayout(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── Logo ─────────────────────────────
              Image.asset('assets/images/dyslexia_logo.png', width: 160),
              const SizedBox(height: 20),

              // ─── Title ─────────────────────────────
              Text(
                "DysTrace",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.green[800],
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),

              // ─── Subtitle ──────────────────────────
              Text(
                "A tool for measuring reading performance\n"
                "and comprehension accuracy.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),

              // ─── Buttons ────────────────────────────
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

              // ─── Instruction Box ────────────────────
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                    "Tap the white dots with blue outlines to calibrate your gaze.\n"
                    "Small red dots will track your eye position during reading.\n\n"
                    "2. Reading Test\n"
                    "You’ll complete three short reading tasks. Press 'Start' to begin,\n"
                    "and 'Stop' when finished.\n\n"
                    "3. Comprehension Test\n"
                    "After reading, answer two comprehension questions per passage.\n\n"
                    "4. View Results\n"
                    "You can review past data in 'Results' or view comparisons in 'Statistics'.",
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
        );
      },
    );
  }
}

