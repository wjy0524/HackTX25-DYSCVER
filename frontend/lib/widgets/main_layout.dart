import 'package:flutter/material.dart';
import 'custom_navbar.dart';

/// ✅ 모든 페이지에 공통으로 적용되는 웹사이트형 Layout
/// - 상단에 NavBar (테스트 중일 때는 hideNavBar로 숨김)
/// - 하단에 페이지 내용 (child)
class MainLayout extends StatelessWidget {
  final Widget child;
  final bool hideNavBar; // ✅ 이름 통일

  const MainLayout({
    Key? key,
    required this.child,
    this.hideNavBar = false, // ✅ 기본값 false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFF9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hideNavBar) const CustomNavBar(), // ✅ 이름 통일
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

