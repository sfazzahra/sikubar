import 'package:flutter/material.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_card.dart';

class LihatPengaduanPage extends StatelessWidget {
  final String nama;
  final String isi;
  final String status;
  final String tanggal;
  final String tanggapan; // 🔥 TAMBAHAN

  const LihatPengaduanPage({
    super.key,
    required this.nama,
    required this.isi,
    required this.status,
    required this.tanggal,
    required this.tanggapan, // 🔥 TAMBAHAN
  });

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Detail Pengaduan",
      child: ListView(
        children: [
          // 👤 PELAPOR
          AppCard(
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    Text(tanggal,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 📝 ISI PENGADUAN
          const Text("Isi Pengaduan",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          AppCard(
            child: Text(isi),
          ),

          const SizedBox(height: 10),

          // 📌 STATUS
          const Text("Status",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          AppCard(
            child: Text(status),
          ),

          const SizedBox(height: 10),

          // 💬 TANGGAPAN (🔥 BARU)
          const Text("Tanggapan Petugas",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          AppCard(
            child: Text(
              tanggapan.isEmpty
                  ? "Belum ada tanggapan"
                  : tanggapan,
            ),
          ),
        ],
      ),
    );
  }
}