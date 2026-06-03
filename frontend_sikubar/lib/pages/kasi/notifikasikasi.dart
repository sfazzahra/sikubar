import 'package:flutter/material.dart';

class NotifikasiKasiPage extends StatelessWidget {

  final List<Map<String, dynamic>> notifList = [

    {
      "judul": "Pengajuan Baru",
      "pesan": "Ada pengajuan baru dari petugas",
      "tanggal": "25 Mei 2026",
    },

    {
      "judul": "Validasi Pengajuan",
      "pesan": "Pengajuan siap direview",
      "tanggal": "24 Mei 2026",
    },
  ];

  NotifikasiKasiPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          "Notifikasi Kasi",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: ListView.builder(
        itemCount: notifList.length,

        itemBuilder: (context, index) {

          final data = notifList[index];

          return Card(

            margin: const EdgeInsets.all(12),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: ListTile(

              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,

                child: Icon(
                  Icons.notifications,
                  color: Colors.blue.shade900,
                ),
              ),

              title: Text(
                data["judul"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(data["pesan"]),

              trailing: Text(data["tanggal"]),
            ),
          );
        },
      ),
    );
  }
}