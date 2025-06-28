import 'package:dyslexia_project/screens/participant_info_page.dart';
import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dyslexia App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const ParticipantInfoPage(),
    );
  }
}
