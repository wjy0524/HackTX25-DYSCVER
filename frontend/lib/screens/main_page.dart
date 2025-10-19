import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
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

                // DysTrace Title (with letterSpacing)
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

                // Short Description
                Text(
                  "DysTrace analyzes users’ reading accuracy and builds a dataset "
                  "to help detect potential dyslexia at an early stage.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 40),

                // Login Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/auth_home_page');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Log In or Sign Up",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 48),
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 920),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                      "DysTrace is a supporting platform for collecting data to assist in dyslexia assessment.\n\n"
                      "Dyslexia manifests in diverse ways, and there are no universal diagnostic criteria. "
                      "Therefore, a single test cannot easily determine whether a person has dyslexia.\n\n"
                      "DysTrace gathers a wide range of signals — including reading accuracy, spoken content, "
                      "comprehension ability, and eye-tracking behavior — to help specialists make more reliable assessments.\n\n"
                      "Upon login, users provide basic information such as gender, education level, and age. "
                      "Then, they read age-appropriate passages aloud while their voice is recorded and analyzed "
                      "for accuracy compared to the reference text.\n\n"
                      "After reading, users answer comprehension questions to measure understanding, "
                      "and eye-tracking data is collected to capture reading patterns.\n\n"
                      "While DysTrace does not directly diagnose dyslexia, it builds a comprehensive dataset "
                      "that supports researchers and professionals in making data-driven evaluations.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.5,
                        height: 1.8,
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
  }
}
