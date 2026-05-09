import 'package:flutter/material.dart';
import '../../widgets/bottom_menucamat.dart';

class BerandaCamatPage extends StatelessWidget {
  const BerandaCamatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// 🔥 BACKGROUND
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              /// 🔥 HEADER
              SizedBox(
                height: 90,
                child: Stack(
                  children: [

                    if (Navigator.canPop(context))
                      Positioned(
                        left: 16,
                        top: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 26),
                        ),
                      ),

                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance,
                              color: Colors.white, size: 32),
                          SizedBox(height: 4),
                          Text(
                            "Dashboard Camat",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [

                    /// 🔵 HEADER USER
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
                            child: Icon(Icons.account_balance,
                                color: Colors.blue),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Selamat Datang",
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12)),
                              SizedBox(height: 4),
                              Text("Camat",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 📊 STATISTIK
                    Row(
                      children: [
                        stat("150", "Total", Colors.blue),
                        const SizedBox(width: 8),
                        stat("30", "Menunggu", Colors.orange),
                        const SizedBox(width: 8),
                        stat("120", "Selesai", Colors.green),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// ⚠️ PERLU PERSETUJUAN
                    const Text("Perlu Persetujuan",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 10),

                    warning("10 pengajuan menunggu persetujuan", Colors.orange),
                    warning("3 pengaduan belum ditindaklanjuti", Colors.red),

                    const SizedBox(height: 20),

                    /// 📅 RINGKASAN
                    const Text("Ringkasan Hari Ini",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 10),

                    summary("Disetujui", "18"),
                    summary("Ditolak", "5"),
                    summary("Dipantau", "7"),

                    const SizedBox(height: 20),

                    /// 📋 AKTIVITAS
                    const Text("Aktivitas Terbaru",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 10),

                    activity("Menyetujui surat Andi", "Baru saja"),
                    activity("Menolak pengajuan Budi", "15 menit lalu"),
                    activity("Monitoring laporan", "1 jam lalu"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /// 🔥 MENU CAMAT
      bottomNavigationBar: const BottomMenuCamat(currentIndex: 0),
    );
  }

  /// 📊 STAT
  Widget stat(String value, String title, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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

  /// ⚠️ WARNING
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

  /// 📅 SUMMARY
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

  /// 📋 ACTIVITY
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