import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// BODY
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2F80ED),
              Color(0xFF1C4FA1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: ListView(
          padding: const EdgeInsets.all(15),
          children: const [

            NotifikasiItem(
              icon: Icons.description,
              title: "Pengajuan Surat Diproses",
              message: "Pengajuan surat domisili Anda sedang diproses.",
              time: "5 menit lalu",
            ),

            NotifikasiItem(
              icon: Icons.check_circle,
              title: "Pengajuan Disetujui",
              message: "Surat keterangan usaha Anda telah disetujui.",
              time: "1 jam lalu",
            ),

            NotifikasiItem(
              icon: Icons.report_problem,
              title: "Pengaduan Diterima",
              message: "Pengaduan Anda telah diterima oleh petugas.",
              time: "Kemarin",
            ),

          ],
        ),
      ),
    );
  }
}

/// ================= WIDGET ITEM NOTIFIKASI =================

class NotifikasiItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;

  const NotifikasiItem({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ICON
          CircleAvatar(
            backgroundColor: const Color(0xFF2F80ED),
            child: Icon(icon, color: Colors.white),
          ),

          const SizedBox(width: 10),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}