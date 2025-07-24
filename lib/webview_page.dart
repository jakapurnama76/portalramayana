import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ✅ Import Font Awesome

class WebViewPage extends StatefulWidget {
  final String title; // ✅ Tambahkan properti title
  final String url;
  const WebViewPage({Key? key, required this.title, required this.url}) : super(key: key); // ✅ Perbarui constructor

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params =
    const PlatformWebViewControllerCreationParams();

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // ✅ Gunakan title dari widget
        backgroundColor: Colors.maroon, // ✅ Tambahkan warna AppBar yang konsisten
        // ✅ Tambahkan widget 'leading' ini untuk ikon back kustom
        leading: IconButton(
          icon: Image.asset(
            'assets/images/arrow_back.png', // ✅ GANTI DENGAN JALUR FILE ANDA!
            color: Colors.white, // Sesuaikan warna gambar
            width: 24, // Sesuaikan ukuran
            height: 24, // Sesuaikan ukuran
          ),
          onPressed: () {
            // Ini akan kembali ke halaman sebelumnya (HomePage)
            Navigator.pop(context);
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

// ✅ Tambahkan ekstensi CustomColor jika belum ada di file ini atau pastikan sudah diimport dari file lain
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