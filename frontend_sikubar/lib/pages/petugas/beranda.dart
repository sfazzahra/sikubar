import 'package:flutter/material.dart';
import '../../widgets/app_layout.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Dashboard",
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔵 HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Selamat Datang",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 4),
                    Text("Petugas Kecamatan",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 📊 STATISTIK
          Row(
            children: [
              stat("120", "Total", Colors.blue),
              const SizedBox(width: 8),
              stat("45", "Diproses", Colors.orange),
              const SizedBox(width: 8),
              stat("50", "Selesai", Colors.green),
            ],
          ),

          const SizedBox(height: 20),

          // ⚠️ NOTIFIKASI PENTING
          const Text("Perlu Perhatian",
              style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          warning("5 berkas belum diverifikasi", Colors.orange),
          warning("2 pengaduan baru masuk", Colors.red),

          const SizedBox(height: 20),

          // 📅 RINGKASAN HARI INI
          const Text("Ringkasan Hari Ini",
              style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          summary("Berkas diverifikasi", "12"),
          summary("Pengaduan ditanggapi", "8"),
          summary("Laporan dibuat", "3"),

          const SizedBox(height: 20),

          // 📋 AKTIVITAS
          const Text("Aktivitas Terbaru",
              style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          activity("Verifikasi berkas Ahmad", "Baru saja"),
          activity("Tanggapan pengaduan Sari", "10 menit lalu"),
          activity("Download laporan", "1 jam lalu"),
        ],
      ),
    );
  }

  // 📊 STAT
  Widget stat(String value, String title, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            )
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ⚠️ WARNING
  Widget warning(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // 📅 SUMMARY
  Widget summary(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 📋 ACTIVITY
  Widget activity(String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(time,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}