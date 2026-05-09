import 'package:flutter/material.dart';

class NotifikasiKasiPage extends StatelessWidget {
  const NotifikasiKasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> notif = [
      "Berkas baru dari Petugas - Siti Fatimah",
      "Berkas baru dari Petugas - Raniya",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: ListView.builder(
        itemCount: notif.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notif[index]),
          );
        },
      ),
    );
  }
}