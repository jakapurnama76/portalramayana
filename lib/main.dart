import 'dart:convert'; // Untuk encode/decode JSON
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Import shared_preferences

void main() {
  runApp(const PortalRamayanaApp());
}

class PortalRamayanaApp extends StatelessWidget {
  const PortalRamayanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Ramayana',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ✅ Model untuk menyimpan data link
class LinkItem {
  String title;
  String url;
  IconData icon; // Menyimpan IconData sebagai int untuk persistensi

  LinkItem({required this.title, required this.url, required this.icon});

  // Konversi dari LinkItem ke Map (untuk disimpan di SharedPreferences)
  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'iconCodePoint': icon.codePoint, // Simpan codePoint dari IconData
    'iconFontFamily': icon.fontFamily, // Simpan fontFamily
    'iconFontPackage': icon.fontPackage, // Simpan fontPackage
  };

  // Konversi dari Map ke LinkItem (untuk dimuat dari SharedPreferences)
  factory LinkItem.fromJson(Map<String, dynamic> json) {
    return LinkItem(
      title: json['title'],
      url: json['url'],
      icon: IconData(
        json['iconCodePoint'],
        fontFamily: json['iconFontFamily'],
        fontPackage: json['iconFontPackage'],
      ),
    );
  }
}

// ✅ HomePage diubah menjadi StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<LinkItem> _links = []; // Daftar link yang akan dimuat/disimpan

  @override
  void initState() {
    super.initState();
    _loadLinks(); // Muat link saat inisialisasi halaman
  }

  // Fungsi untuk memuat link dari SharedPreferences
  Future<void> _loadLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? linksString = prefs.getString('custom_links');
    if (linksString != null) {
      final List<dynamic> jsonList = jsonDecode(linksString);
      setState(() {
        _links = jsonList.map((json) => LinkItem.fromJson(json)).toList();
      });
    } else {
      // Jika belum ada link tersimpan, gunakan default (hanya sekali saat aplikasi pertama kali dibuka)
      setState(() {
        _links = [
          LinkItem(title: "Portal", url: "https://portal.ramayana.co.id", icon: FontAwesomeIcons.globe),
          LinkItem(title: "Zimbra", url: "https://zimbra.ramayana.co.id", icon: FontAwesomeIcons.envelope),
          LinkItem(title: "Lapor", url: "https://lapor.ramayana.co.id", icon: FontAwesomeIcons.flag),
          LinkItem(title: "Dashboard", url: "https://ds.ramayana.co.id", icon: FontAwesomeIcons.chartLine),
          LinkItem(title: "Supplier", url: "https://supplier.ramayana.co.id", icon: FontAwesomeIcons.store),
          LinkItem(title: "B2B", url: "https://b2b.ramayana.co.id", icon: FontAwesomeIcons.handshake),
          LinkItem(title: "HRD", url: "https://hrd.ramayana.co.id:8443", icon: FontAwesomeIcons.users),
          // ✅ Link RIS yang baru dengan URL dan ikon yang sesuai
          LinkItem(title: "RIS", url: "https://ris.ramayana.co.id", icon: FontAwesomeIcons.database),
        ];
      });
      // Simpan link default ini agar tidak dimuat lagi di kemudian hari
      _saveLinks();
    }
  }

  // Fungsi untuk menyimpan link ke SharedPreferences
  Future<void> _saveLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final String linksString = jsonEncode(_links.map((link) => link.toJson()).toList());
    await prefs.setString('custom_links', linksString);
  }

  void _openAndroidVpnSettings(BuildContext context) {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.VPN_SETTINGS',
      );
      intent.launch();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fitur hanya tersedia di Android")),
      );
    }
  }

  // Fungsi untuk navigasi ke halaman manajemen link
  Future<void> _manageLinks() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageLinksPage(links: _links),
      ),
    );
    // Setelah kembali dari ManageLinksPage, muat ulang link untuk update UI
    _loadLinks();
  }

  // ✅ Fungsi untuk menampilkan dialog konfirmasi keluar aplikasi
  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Tetap di aplikasi
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Keluar dari aplikasi
            child: const Text('Ya'),
          ),
        ],
      ),
    )) ?? false; // Mengembalikan false jika dialog ditutup tanpa pilihan
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Bungkus Scaffold dengan WillPopScope
    return WillPopScope(
      onWillPop: _onWillPop, // Panggil fungsi konfirmasi saat tombol back ditekan
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Portal Ramayana"),
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.gear),
              onPressed: () => _openAndroidVpnSettings(context),
            ),
            // ✅ Tombol untuk mengelola link
            IconButton(
              icon: const Icon(FontAwesomeIcons.edit),
              onPressed: _manageLinks,
            ),
          ],
        ),
        body: _links.isEmpty
            ? const Center(child: Text("Tidak ada link tersedia. Tambahkan beberapa!"))
            : GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _links.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final link = _links[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebviewPage(title: link.title, url: link.url),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.red[700],
                elevation: 10, // ✅ Tingkatkan elevasi untuk bayangan lebih menonjol
                shadowColor: Colors.black.withOpacity(0.7), // ✅ Ubah warna bayangan untuk efek lebih gelap dan jelas
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(link.icon, size: 48, color: Colors.white), // Menggunakan link.icon
                      const SizedBox(height: 12),
                      Text(
                        link.title,
                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ✅ Halaman baru untuk mengelola link
class ManageLinksPage extends StatefulWidget {
  final List<LinkItem> links; // Daftar link saat ini

  const ManageLinksPage({super.key, required this.links});

  @override
  State<ManageLinksPage> createState() => _ManageLinksPageState();
}

class _ManageLinksPageState extends State<ManageLinksPage> {
  late List<LinkItem> _editableLinks; // Daftar link yang bisa diedit
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  IconData _selectedIcon = FontAwesomeIcons.link; // Ikon default untuk link baru

  @override
  void initState() {
    super.initState();
    // Buat salinan dari daftar link agar perubahan tidak langsung mempengaruhi HomePage
    _editableLinks = List.from(widget.links);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan perubahan link ke SharedPreferences
  Future<void> _saveLinksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String linksString = jsonEncode(_editableLinks.map((link) => link.toJson()).toList());
    await prefs.setString('custom_links', linksString);
  }

  // Fungsi untuk menambah link baru
  void _addLink() {
    if (_titleController.text.isEmpty || _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan URL tidak boleh kosong!')),
      );
      return;
    }

    final newLink = LinkItem(
      title: _titleController.text,
      url: _urlController.text,
      icon: _selectedIcon,
    );

    setState(() {
      _editableLinks.add(newLink);
    });
    _saveLinksToPrefs(); // Simpan setelah menambah
    _titleController.clear();
    _urlController.clear();
    // Kembali ke ikon default setelah menambah
    setState(() {
      _selectedIcon = FontAwesomeIcons.link;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link berhasil ditambahkan!')),
    );
  }

  // Fungsi untuk menghapus link
  void _removeLink(int index) {
    setState(() {
      _editableLinks.removeAt(index);
    });
    _saveLinksToPrefs(); // Simpan setelah menghapus
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link berhasil dihapus!')),
    );
  }

  // Fungsi untuk memilih ikon (bisa dikembangkan dengan dialog pemilihan ikon)
  void _selectIcon() async {
    // Untuk demo, kita berikan beberapa pilihan ikon Font Awesome
    final IconData? pickedIcon = await showDialog<IconData>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Ikon'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildIconChoice(FontAwesomeIcons.link),
                _buildIconChoice(FontAwesomeIcons.globe),
                _buildIconChoice(FontAwesomeIcons.envelope),
                _buildIconChoice(FontAwesomeIcons.flag),
                _buildIconChoice(FontAwesomeIcons.chartLine),
                _buildIconChoice(FontAwesomeIcons.store),
                _buildIconChoice(FontAwesomeIcons.handshake),
                _buildIconChoice(FontAwesomeIcons.users),
                _buildIconChoice(FontAwesomeIcons.database), // ✅ Tambahkan ikon database untuk RIS
                _buildIconChoice(FontAwesomeIcons.solidStar),
                _buildIconChoice(FontAwesomeIcons.solidHeart),
                _buildIconChoice(FontAwesomeIcons.solidBookmark),
                _buildIconChoice(FontAwesomeIcons.solidCircle),
                _buildIconChoice(FontAwesomeIcons.solidSquare),
                _buildIconChoice(FontAwesomeIcons.solidBell),
              ],
            ),
          ),
        );
      },
    );

    if (pickedIcon != null) {
      setState(() {
        _selectedIcon = pickedIcon;
      });
    }
  }

  Widget _buildIconChoice(IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(icon);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: _selectedIcon == icon ? Colors.red : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Link Portal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form untuk menambah link baru
            Card(
              color: Colors.red[800],
              margin: const EdgeInsets.only(bottom: 20),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Tambah Link Baru', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Link',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL Link',
                        hintText: 'Contoh: https://example.com',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    // Pemilihan Ikon
                    ListTile(
                      title: const Text('Pilih Ikon', style: TextStyle(color: Colors.white)),
                      trailing: Icon(_selectedIcon, color: Colors.white),
                      onTap: _selectIcon,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.white54)),
                      tileColor: Colors.red[700],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addLink,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Link'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Daftar link yang sudah ada
            Expanded(
              child: _editableLinks.isEmpty
                  ? const Center(child: Text("Belum ada link kustom.", style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                itemCount: _editableLinks.length,
                itemBuilder: (context, index) {
                  final link = _editableLinks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.red[600],
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Icon(link.icon, color: Colors.white),
                      title: Text(link.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(link.url, style: const TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => _removeLink(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebviewPage extends StatefulWidget {
  final String title;
  final String url;

  const WebviewPage({super.key, required this.title, required this.url});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse(widget.url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)), // Menggunakan AppBar default
      body: WebViewWidget(controller: _controller),
    );
  }
}

// Catatan: Pastikan CustomColor ada atau diimport dari file lain jika Anda menggunakannya
// Jika tidak, Anda bisa menghapus bagian ini jika tidak lagi diperlukan.
/*
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
*/