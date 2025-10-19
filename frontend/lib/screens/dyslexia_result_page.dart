import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dyslexia_info_page.dart';

class DyslexiaResultPage extends StatefulWidget {
  const DyslexiaResultPage({Key? key}) : super(key: key);

  @override
  State<DyslexiaResultPage> createState() => _DyslexiaResultPageState();
}

class _DyslexiaResultPageState extends State<DyslexiaResultPage> {
  double? probability;
  String riskLevel = "";
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _calculateAndPredict();
  }

  Future<void> _calculateAndPredict() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

      // Fetch reading and comprehension data
      final readingSnap = await userDoc
          .collection('reading_results')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      final compSnap = await userDoc
          .collection('comprehension_results')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      if (readingSnap.docs.isEmpty || compSnap.docs.isEmpty) {
        setState(() {
          errorMessage = "Not enough data to predict dyslexia risk.";
          isLoading = false;
        });
        return;
      }

      // Calculate averages
      double totalAccuracy = 0;
      int totalWords = 0;
      int totalDuration = 0;
      int totalCorrect = 0;
      int totalQuestions = 0;

      for (var doc in readingSnap.docs) {
        final data = doc.data();
        totalAccuracy += (data['accuracy'] as num).toDouble();
        totalWords += (data['words_read'] as num).toInt();
        totalDuration += (data['duration_seconds'] as num).toInt();
      }

      for (var doc in compSnap.docs) {
        final data = doc.data();
        totalCorrect += (data['correct_answers'] as num).toInt();
        totalQuestions += (data['total_questions'] as num).toInt();
      }

      final avgAccuracy = totalAccuracy / readingSnap.docs.length;
      final avgWpm = totalWords / (totalDuration / 60);
      final avgComprehensionRate =
          totalQuestions > 0 ? totalCorrect / totalQuestions : 0;

      // Send to backend for prediction
      final resp = await http.post(
        Uri.parse('http://localhost:8000/predict_dyslexia'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'wpm': avgWpm,
          'accuracy': avgAccuracy,
          'comprehension_rate': avgComprehensionRate,
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final prob = (data['probability'] as num).toDouble();

        String level;
        if (prob < 0.33) {
          level = "Low Risk";
        } else if (prob < 0.66) {
          level = "Moderate Risk";
        } else {
          level = "High Risk";
        }

        setState(() {
          probability = prob;
          riskLevel = level;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Server error (${resp.statusCode}).";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFE8F5E9);
    const Color mainColor = Color(0xFF81C784);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text("Dyslexia Evaluation Result"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage.isNotEmpty
                  ? Text(errorMessage, style: const TextStyle(color: Colors.red))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.analytics,
                            size: 80, color: Color(0xFF4CAF50)),
                        const SizedBox(height: 24),
                        const Text(
                          "Predicted Dyslexia Probability",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${(probability! * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: riskLevel == "High Risk"
                                ? Colors.redAccent
                                : (riskLevel == "Moderate Risk"
                                    ? Colors.orangeAccent
                                    : Colors.green),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          riskLevel,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DyslexiaInfoPage()),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text("View Dyslexia Resources"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}