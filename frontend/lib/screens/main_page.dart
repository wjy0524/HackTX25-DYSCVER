import 'package:flutter/material.dart';
import '../widgets/public_navbar.dart';
import 'sections/features_section.dart';
import 'sections/research_section.dart';
import 'sections/about_section.dart';
import 'sections/contact_section.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _researchKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    const Color bg = Color(0xFFF9FFF9);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          PublicNavBar(
            onHomeTap: () => _scrollController.animateTo(0,
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut),
            onFeaturesTap: () => _scrollTo(_featuresKey),
            onResearchTap: () => _scrollTo(_researchKey),
            onAboutTap: () => _scrollTo(_aboutKey),
            onContactTap: () => _scrollTo(_contactKey),
            onLoginTap: () => Navigator.pushNamed(context, '/auth_home_page'),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildHeroSection(context),
                  FeaturesSection(key: _featuresKey),
                  ResearchSection(key: _researchKey),
                  AboutSection(key: _aboutKey),
                  ContactSection(key: _contactKey),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Image.asset('assets/images/dyslexia_logo.png', width: 300),
          const SizedBox(height: 28),
          const SizedBox(height: 18),
          const Text(
            "AI-powered dyslexia screening platform that analyzes reading accuracy, speech, comprehension, and eye-tracking.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black54, height: 1.6),
          ),
          const SizedBox(height: 36),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/auth_home_page'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    const Color primary = Color(0xFF2E7D32);
    return Container(
      width: double.infinity,
      color: primary,
      padding: const EdgeInsets.all(24),
      child: const Text(
        "© 2025 DysTrace | Built with Flutter & Firebase",
        style: TextStyle(color: Colors.white70, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}


