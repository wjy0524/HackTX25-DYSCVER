import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    const Color bg = Color(0xFFF1F8E9);

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text(
            "Core Features",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 50),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 40,
            runSpacing: 40,
            children: const [
              _FeatureCard(
                icon: Icons.visibility,
                title: "Eye Tracking",
                desc:
                    "Tracks gaze and reading patterns in real-time using WebGazer.js, capturing subtle visual behaviors linked to dyslexia.",
              ),
              _FeatureCard(
                icon: Icons.mic,
                title: "Speech Accuracy",
                desc:
                    "Analyzes spoken content using AI speech recognition (Whisper) to detect pronunciation accuracy and reading fluency.",
              ),
              _FeatureCard(
                icon: Icons.timer,
                title: "Reading Speed",
                desc:
                    "Measures reading pace, latency, and pauses — indicators of phonological decoding and processing speed.",
              ),
              _FeatureCard(
                icon: Icons.question_answer,
                title: "Comprehension",
                desc:
                    "Presents adaptive comprehension questions to evaluate understanding, retention, and semantic processing.",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    const Color primary = Color(0xFF2E7D32);
    return Container(
      width: 260,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 50, color: primary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
