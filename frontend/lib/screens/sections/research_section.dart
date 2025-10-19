import 'package:flutter/material.dart';

class ResearchSection extends StatelessWidget {
  const ResearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    const Color bg = Colors.white;

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text(
            "Research Foundation",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 40),
          const SizedBox(
            width: 850,
            child: Text(
              "DysTrace was developed through collaboration between researchers in Artificial Intelligence and Educational Psychology. "
              "It aims to collect multi-modal data — including gaze, voice, and comprehension — to train predictive models for early dyslexia detection.\n\n"
              "The project leverages open-source frameworks such as WebGazer.js for eye-tracking, Whisper for speech recognition, "
              "and a machine learning pipeline built with Python and Random Forest classifiers. All participant data is anonymized and securely stored in Firebase.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.5, height: 1.8, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Image.asset('assets/images/research_diagram.png', fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
