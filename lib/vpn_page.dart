import 'package:flutter/material.dart';

class VpnPage extends StatelessWidget {
  const VpnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan VPN'),
      ),
      body: const Center(
        child: Text('Halaman Pengaturan VPN (sementara kosong)'),
      ),
    );
  }
}
