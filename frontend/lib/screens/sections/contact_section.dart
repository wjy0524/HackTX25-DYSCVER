import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  Future<void> _sendEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'dystrace.project@gmail.com',
      query: 'subject=DysTrace Inquiry',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
            "Contact Us",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Have questions, research proposals, or collaboration ideas?\nWe’d love to hear from you.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.5, color: Colors.black87, height: 1.6),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: _sendEmail,
            icon: const Icon(Icons.email_outlined, color: primary),
            label: const Text(
              "dystrace.project@gmail.com",
              style: TextStyle(color: primary, fontSize: 15),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}
