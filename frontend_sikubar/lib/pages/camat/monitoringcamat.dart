import 'package:flutter/material.dart';
import '../../widgets/bottom_menucamat.dart';

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  /// 🔥 DATA DUMMY
  final int total = 150;
  final int disetujui = 100;
  final int ditolak = 20;
  final int menunggu = 30;

  /// DATA HARIAN (UNTUK CHART)
  final List<Map<String, dynamic>> dataHarian = const [
    {"hari": "Sen", "jumlah": 20},
    {"hari": "Sel", "jumlah": 25},
    {"hari": "Rab", "jumlah": 15},
    {"hari": "Kam", "jumlah": 30},
    {"hari": "Jum", "jumlah": 18},
  ];

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
                          Icon(Icons.bar_chart,
                              color: Colors.white, size: 32),
                          SizedBox(height: 4),
                          Text(
                            "Monitoring Camat",
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

                    /// 📊 TOTAL
                    buildStat("Total Pengajuan", "$total", Colors.blue),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        buildStat("Disetujui", "$disetujui", Colors.green),
                        const SizedBox(width: 8),
                        buildStat("Ditolak", "$ditolak", Colors.red),
                        const SizedBox(width: 8),
                        buildStat("Menunggu", "$menunggu", Colors.orange),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// 📊 GRAFIK SEDERHANA
                    const Text("Statistik Mingguan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),

                    const SizedBox(height: 10),

                    buildChart(),

                    const SizedBox(height: 20),

                    /// 📋 RINGKASAN
                    const Text("Ringkasan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),

                    const SizedBox(height: 10),

                    summary("Pelayanan cepat", "85%"),
                    summary("Pengajuan selesai tepat waktu", "78%"),
                    summary("Tingkat penolakan", "13%"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /// 🔥 MENU CAMAT
      bottomNavigationBar: const BottomMenuCamat(currentIndex: 3),
    );
  }

  /// 📊 CARD STAT
  Widget buildStat(String title, String value, Color color) {
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

  /// 📊 CHART BAR SEDERHANA
  Widget buildChart() {
    int maxValue = 30;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: dataHarian.map((data) {
          double height =
              (data["jumlah"] / maxValue) * 100;

          return Column(
            children: [
              Container(
                height: height,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 5),
              Text(data["hari"]),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 📋 SUMMARY
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
}