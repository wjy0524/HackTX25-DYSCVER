import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main_page.dart';

class DyslexiaInfoPage extends StatelessWidget {
  const DyslexiaInfoPage({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('참고 자료')), 
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '난독증 증상 및 치료 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('난독증 지원센터'),
            subtitle: const Text('난독증 검사 및 개선방법 제공'),
            onTap: () => _launchUrl('https://nandok.com/'),
          ),
          ListTile(
            title: const Text('MSD 메뉴얼 – 난독증'),
            subtitle: const Text('난독증 증상과 치료 가이드'),
            onTap: () => _launchUrl('https://www.msdmanuals.com/ko/home/%EC%95%84%EB%8F%99%EC%9D%98-%EA%B1%B4%EA%B0%95-%EB%AC%B8%EC%A0%9C/%ED%95%99%EC%8A%B5%EA%B3%BC-%EB%B0%9C%EB%8B%AC-%EC%9E%A5%EC%95%A0/%EB%82%9C%EB%8F%85%EC%A6%9D'),
          ),
          ListTile(
            title: const Text('서울대어린이병원 – 난독증'),
            subtitle: const Text('언어 치료 및 시지각 훈련 정보'),
            onTap: () => _launchUrl('https://child.snuh.org/health/nMedInfo/nView.do?category=DIS&medid=AA000594'),
          ),
          ListTile(
            title: const Text('SKY두뇌세움클리닉'),
            subtitle: const Text('난독증 교정 프로그램 제공'),
            onTap: () => _launchUrl('https://www.skybrain.co.kr/'),
          ),
          ListTile(
            title: const Text('북구미래아동병원 – 난독클리닉'),
            subtitle: const Text('시지각·청지각 훈련 프로그램'),
            onTap: () => _launchUrl('https://www.bmiraehosp.com/?page_id=894'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MainPage()),
              );
            },
            child: const Text('메인으로 돌아가기'),
          ),
        ],
      ),
    );
  }
}
