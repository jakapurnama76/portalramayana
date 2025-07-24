import 'package:flutter/material.dart';
import 'webview_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> links = [
    {"title": "Lapor", "url": "https://lapor.ramayana.co.id"},
    {"title": "Dashboard", "url": "https://ds.ramayana.co.id"},
    {"title": "Supplier Portal", "url": "https://supplier.ramayana.co.id"},
    {"title": "B2B", "url": "https://b2b.ramayana.co.id"},
    {"title": "Email Zimbra", "url": "http://zimbra.ramayana.co.id"},
    {"title": "RIS", "url": "https://ris.ramayana.co.id"},
    {"title": "SISTOKO", "url": "http://sistoko.ramayana.co.id"},
    {"title": "Orange", "url": "https://hrd.ramayana.co.id"},
    {"title": "Scanner SPM", "url": "https://scanner.ramayana.co.id"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Portal Ramayana"),
        backgroundColor: Colors.maroon,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: links.length,
        itemBuilder: (context, index) {
          final item = links[index];
          return Card(
            color: Colors.maroon.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                item['title']!,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebViewPage(
                      title: item['title']!,
                      url: item['url']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

extension CustomColor on Colors {
  static const MaterialColor maroon = MaterialColor(
    0xFF800000,
    <int, Color>{
      50: Color(0xFFFAEAEA),
      100: Color(0xFFF2C8C8),
      200: Color(0xFFE89A9A),
      300: Color(0xFFDD6B6B),
      400: Color(0xFFD44A4A),
      500: Color(0xFFCC2A2A),
      600: Color(0xFFB32424),
      700: Color(0xFF991E1E),
      800: Color(0xFF801818),
      900: Color(0xFF661212),
    },
  );
}
