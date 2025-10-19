import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/main_layout.dart';

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
        'title': 'Dyslexia Center of Austin',
        'subtitle': 'Comprehensive dyslexia evaluation & intervention programs',
        'url': 'https://dyslexiacenterofaustin.org/',
        'icon': Icons.school,
        'location': LatLng(30.2978, -97.8110),
      },
      {
        'title': 'Rawson Saunders School',
        'subtitle': 'Independent school for students with dyslexia (grades 1–8)',
        'url': 'https://www.rawsonsaunders.org/',
        'icon': Icons.menu_book,
        'location': LatLng(30.2764, -97.7649),
      },
      {
        'title': 'Academic Therapy Center – Austin',
        'subtitle': 'Assessment & therapy for dyslexia and learning disorders',
        'url': 'https://academictherapycenter.com/',
        'icon': Icons.healing,
        'location': LatLng(30.3070, -97.7478),
      },
      {
        'title': 'Austin Learning Solutions',
        'subtitle': 'Reading intervention & cognitive training programs',
        'url': 'https://austinlearningsolutions.com/',
        'icon': Icons.psychology,
        'location': LatLng(30.2900, -97.8000),
      },
    ];

    final infoResources = <Map<String, String>>[
      {
        'title': 'International Dyslexia Association (IDA)',
        'subtitle': 'Official research, education & advocacy organization',
        'url': 'https://dyslexiaida.org/',
      },
      {
        'title': 'Texas Education Agency – Dyslexia Services',
        'subtitle': 'Guidelines and state policy for dyslexia intervention',
        'url':
            'https://tea.texas.gov/academics/special-student-populations/dyslexia-and-related-disorders',
      },
      {
        'title': 'Austin Area Branch – IDA',
        'subtitle': 'Local community branch supporting Central Texas families',
        'url': 'https://austinareabranch.org/',
      },
    ];

    return MainLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Map Section ─────────────────────────────
          Text(
            'Dyslexia Clinics in Austin, TX',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: titleColor, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            width: 800,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  center: clinicResources.first['location'] as LatLng,
                  zoom: 11,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.dystrace.app',
                  ),
                  MarkerLayer(
                    markers: clinicResources.map((res) {
                      final pos = res['location'] as LatLng;
                      return Marker(
                        width: 40,
                        height: 40,
                        point: pos,
                        builder: (ctx) => GestureDetector(
                          onTap: () => _launchUrl(res['url'] as String),
                          child: const Icon(
                            Icons.location_on,
                            size: 32,
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Clinic List ─────────────────────────────
          Text(
            'Local Dyslexia Centers',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold, color: titleColor),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 800,
            child: Column(
              children: clinicResources.map((res) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: bgColor,
                        child:
                            Icon(res['icon'] as IconData, color: primaryColor),
                      ),
                      title: Text(res['title'] as String,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(res['subtitle'] as String),
                      trailing:
                          const Icon(Icons.launch, color: primaryColor),
                      onTap: () => _launchUrl(res['url'] as String),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(thickness: 1.2, height: 40),

          // ─── Info Section ─────────────────────────────
          Text(
            'Educational Resources & Organizations',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: titleColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 800,
            child: Column(
              children: infoResources.map((info) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: bgColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(info['title']!,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(info['subtitle']!),
                      trailing:
                          const Icon(Icons.open_in_new, color: primaryColor),
                      onTap: () => _launchUrl(info['url']!),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}










