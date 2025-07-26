// lib/screens/dyslexia_info_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main_menu_page.dart';

class DyslexiaInfoPage extends StatelessWidget {
  const DyslexiaInfoPage({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resources = [
      {
        'title': '난독증 지원센터',
        'subtitle': '난독증 검사 및 개선방법 제공',
        'url': 'https://nandok.com/',
        'icon': Icons.school,
      },
      {
        'title': 'MSD 매뉴얼 – 난독증',
        'subtitle': '난독증 증상과 치료 가이드',
        'url': 'https://www.msdmanuals.com/ko/home/%EC%95%84%EB%8F%99%EC%9D%98-%EA%B1%B4%EA%B0%95-%EB%AC%B8%EC%A0%9C/%ED%95%99%EC%8A%B5%EA%B3%BC-%EB%B0%9C%EB%8B%AC-%EC%9E%A5%EC%95%A0/%EB%82%9C%EB%8F%85%EC%A6%9D',
        'icon': Icons.menu_book,
      },
      {
        'title': '서울대어린이병원',
        'subtitle': '언어 치료 및 시지각 훈련 정보',
        'url': 'https://child.snuh.org/health/nMedInfo/nView.do?category=DIS&medid=AA000594',
        'icon': Icons.healing,
      },
      {
        'title': 'SKY두뇌세움클리닉',
        'subtitle': '난독증 교정 프로그램 제공',
        'url': 'https://www.skybrain.co.kr/',
        'icon': Icons.biotech,
      },
      {
        'title': '북구미래아동병원',
        'subtitle': '시지각·청지각 훈련 프로그램',
        'url': 'https://www.bmiraehosp.com/?page_id=894',
        'icon': Icons.local_hospital,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('참고 자료'),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '난독증 정보 및 지원',
              style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(
                    color: Colors.teal[700],
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: resources.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final resource = resources[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Icon(
                          resource['icon'] as IconData,
                          color: Colors.teal[700],
                        ),
                      ),
                      title: Text(
                        resource['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(resource['subtitle'] as String),
                      trailing: const Icon(Icons.launch, color: Colors.grey),
                      onTap: () => _launchUrl(resource['url'] as String),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('메인으로 돌아가기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainMenuPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}