// lib/screens/dyslexia_info_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
    const primaryColor = Color(0xFF81C784);
    const bgColor = Color(0xFFC8E6C9);
    const titleColor = Color(0xFF388E3C);

    final clinicResources = <Map<String, dynamic>>[
      {
        'title': '난독증 지원센터',
        'subtitle': '난독증 검사 및 개선방법 제공',
        'url': 'https://nandok.com/',
        'icon': Icons.school,
        'location': LatLng(37.5665, 126.9780),
      },
      {
        'title': '서울대어린이병원',
        'subtitle': '언어 치료 및 시지각 훈련 정보',
        'url': 'https://child.snuh.org/health/nMedInfo/nView.do?category=DIS&medid=AA000594',
        'icon': Icons.healing,
        'location': LatLng(37.5796, 126.9994),
      },
      {
        'title': 'SKY두뇌세움클리닉',
        'subtitle': '난독증 교정 프로그램 제공',
        'url': 'https://www.skybrain.co.kr/',
        'icon': Icons.biotech,
        'location': LatLng(37.5012, 127.0396),
      },
      {
        'title': '북구미래아동병원',
        'subtitle': '시지각·청지각 훈련 프로그램',
        'url': 'https://www.bmiraehosp.com/?page_id=894',
        'icon': Icons.local_hospital,
        'location': LatLng(36.1323, 128.3442),
      },
    ];

    final infoResources = <Map<String, String>>[
      {
        'title': 'MSD 매뉴얼 – 난독증',
        'subtitle': '난독증 증상과 치료 가이드',
        'url': 'https://www.msdmanuals.com/ko/home/아동의-건강-문제/학습과-발달-장애/난독증',
      },
      {
        'title': '한국난독증협회',
        'subtitle': 'Korean Dyslexia Association',
        'url': 'http://www.kdyslexia.org/main',
      },
      {
        'title': '사단법인 대한난독증협회',
        'subtitle': '난독증 개선 사례 및 지원 사업',
        'url': 'http://www.nandoc.com/about_intro.php',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('참고 자료 & 위치 안내'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) 지도
            Text(
              '클리닉 위치 지도',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: titleColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  center: clinicResources.first['location'] as LatLng,
                  zoom: 10,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.yourcompany.yourapp',
                  ),
                  MarkerLayer(
                    markers: clinicResources.map((res) {
                      final pos = res['location'] as LatLng;
                      return Marker(
                        width: 40, height: 40, point: pos,
                        builder: (ctx) => GestureDetector(
                          onTap: () => _launchUrl(res['url'] as String),
                          child: const Icon(Icons.location_on, size: 32, color: Colors.redAccent),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2) 치료센터 리스트 (내부 스크롤 없음)
            ...clinicResources.map((res) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: bgColor,
                      child: Icon(res['icon'] as IconData, color: primaryColor),
                    ),
                    title: Text(res['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(res['subtitle'] as String),
                    trailing: const Icon(Icons.launch, color: primaryColor),
                    onTap: () => _launchUrl(res['url'] as String),
                  ),
                ),
              );
            }).toList(),

            const Divider(thickness: 1.2),
            const SizedBox(height: 12),

            // 3) 난독증 정보 섹션
            Text(
              '난독증 정보',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: titleColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...infoResources.map((info) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: bgColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(info['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(info['subtitle']!),
                    trailing: const Icon(Icons.open_in_new, color: primaryColor),
                    onTap: () => _launchUrl(info['url']!),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // 4) 메인으로 돌아가기 버튼
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('메인으로 돌아가기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainMenuPage()),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}








