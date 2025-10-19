import 'package:flutter/material.dart';

class PublicNavBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onFeaturesTap;
  final VoidCallback onResearchTap;
  final VoidCallback onAboutTap;
  final VoidCallback onContactTap;
  final VoidCallback onLoginTap;

  const PublicNavBar({
    super.key,
    required this.onHomeTap,
    required this.onFeaturesTap,
    required this.onResearchTap,
    required this.onAboutTap,
    required this.onContactTap,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onHomeTap,
            child: Row(
              children: [
                Image.asset('assets/images/dyslexia_logo.png', height: 34),
                const SizedBox(width: 10),
                const Text(
                  "DysTrace",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _navItem("Home", onHomeTap),
              _navItem("Features", onFeaturesTap),
              _navItem("Research", onResearchTap),
              _navItem("About", onAboutTap),
              _navItem("Contact", onContactTap),
              const SizedBox(width: 32),
              OutlinedButton(
                onPressed: onLoginTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primary),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text(
                  "Log In",
                  style: TextStyle(
                    fontSize: 15,
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title, VoidCallback onTap) {
    const Color textColor = Color(0xFF333333);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15.5,
              color: textColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
