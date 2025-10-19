import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnim;
  late Animation<double> _textAnim;
  late Animation<double> _buttonAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _textAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _buttonAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2E7D32);
    const Color lightBg = Color(0xFFF1F8E9);
    const Color pageBg = Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: pageBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ─────────────── Hero Section ───────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _logoAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Image.asset(
                        'assets/images/dyslexia_logo.png',
                        width: 300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _textAnim,
                    child: const Text(
                      "AI-powered platform for early dyslexia detection through\n"
                      "reading, voice, and comprehension analysis.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black54,
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _buttonAnim,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/auth_home_page'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.black26,
                        elevation: 6,
                      ),
                      child: const Text(
                        "Log In or Sign Up",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─────────────── Features Section ───────────────
            Container(
              color: lightBg,
              padding:
                  const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
              child: Column(
                children: [
                  const Text(
                    "What DysTrace Offers",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 40,
                    runSpacing: 32,
                    children: const [
                      _FeatureCard(
                        icon: Icons.visibility,
                        title: "Eye Tracking",
                        desc:
                            "Track users’ visual patterns and reading focus in real time to understand dyslexic reading behaviors.",
                      ),
                      _FeatureCard(
                        icon: Icons.mic,
                        title: "Voice Accuracy",
                        desc:
                            "Analyze how accurately users read words aloud using AI-based speech recognition models.",
                      ),
                      _FeatureCard(
                        icon: Icons.timer,
                        title: "Reading Speed",
                        desc:
                            "Measure fluency and timing during reading sessions to evaluate reading efficiency.",
                      ),
                      _FeatureCard(
                        icon: Icons.question_answer,
                        title: "Comprehension",
                        desc:
                            "Assess understanding and memory through adaptive comprehension questions.",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─────────────── About Section ───────────────
            Container(
              constraints: const BoxConstraints(maxWidth: 950),
              padding:
                  const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
              child: const Text(
                "DysTrace is a supporting platform for collecting data to assist in dyslexia assessment. "
                "Dyslexia manifests in diverse ways, and there are no universal diagnostic criteria. "
                "Therefore, a single test cannot easily determine whether a person has dyslexia.\n\n"
                "DysTrace gathers a wide range of signals — including reading accuracy, spoken content, "
                "comprehension ability, and eye-tracking behavior — to help specialists make more reliable assessments.\n\n"
                "Upon login, users provide basic information such as gender, education level, and age. "
                "Then, they read age-appropriate passages aloud while their voice is recorded and analyzed for accuracy compared to the reference text.\n\n"
                "After reading, users answer comprehension questions to measure understanding, "
                "and eye-tracking data is collected to capture reading patterns.\n\n"
                "While DysTrace does not directly diagnose dyslexia, it builds a comprehensive dataset "
                "that supports researchers and professionals in making data-driven evaluations.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17.5, height: 1.8, color: Colors.black87),
              ),
            ),

            // ─────────────── Footer Section ───────────────
            Container(
              color: primaryColor,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: const Text(
                "© 2025 DysTrace | Built with Flutter & Firebase",
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Feature Card Widget ───────────────
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2E7D32);

    return Container(
      width: 260,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: primaryColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

