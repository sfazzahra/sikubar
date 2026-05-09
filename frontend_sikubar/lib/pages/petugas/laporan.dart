import 'package:flutter/material.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_card.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String selectedFilter = "Hari ini";

  // 📊 DATA DINAMIS
  Map<String, Map<String, dynamic>> data = {
    "Hari ini": {
      "total": 50,
      "disetujui": 30,
      "ditolak": 20,
      "progress": 0.6,
    },
    "Minggu": {
      "total": 120,
      "disetujui": 90,
      "ditolak": 30,
      "progress": 0.75,
    },
    "Bulan": {
      "total": 300,
      "disetujui": 250,
      "ditolak": 50,
      "progress": 0.85,
    },
  };

  @override
  Widget build(BuildContext context) {
    var current = data[selectedFilter]!;

    return AppLayout(
      title: "Laporan",
      child: ListView(
        children: [
          // 📅 FILTER
          Row(
            children: [
              filter("Hari ini"),
              filter("Minggu"),
              filter("Bulan"),
            ],
          ),

          const SizedBox(height: 15),

          // 📊 STATISTIK DINAMIS
          Row(
            children: [
              stat("${current["total"]}", "Total"),
              stat("${current["disetujui"]}", "Disetujui"),
              stat("${current["ditolak"]}", "Ditolak"),
            ],
          ),

          const SizedBox(height: 20),

          // 📈 PROGRESS DINAMIS
          const Text("Progress Pelayanan",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${(current["progress"] * 100).toInt()}% Selesai"),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: current["progress"],
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 📋 LIST LAPORAN
          const Text("Riwayat Laporan",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          laporanItem("Laporan Januari", "120 data", "Selesai"),
          laporanItem("Laporan Februari", "98 data", "Selesai"),
          laporanItem("Laporan Maret", "45 data", "Diproses"),

          const SizedBox(height: 20),

          // 📥 DOWNLOAD (ADA LOADING)
          GestureDetector(
            onTap: downloadExcel,
            child: fullButton("Download Excel", Colors.blue),
          ),
        ],
      ),
    );
  }

  // 🔘 FILTER
  Widget filter(String text) {
    bool active = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.blue : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 📊 STAT CARD
  Widget stat(String angka, String label) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5), // 🔥 INI YANG PENTING
      child: AppCard(
        child: Column(
          children: [
            Text(
              angka,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

  // 📋 ITEM LAPORAN (DETAIL POPUP)
  Widget laporanItem(String title, String jumlah, String status) {
    Color statusColor =
        status == "Selesai" ? Colors.green : Colors.orange;

    return AppCard(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text("Jumlah: $jumlah\nStatus: $status"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup"),
              ),
            ],
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                Text(jumlah, style: const TextStyle(fontSize: 12)),
              ]),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 11),
            ),
          )
        ],
      ),
    );
  }

  // 📥 DOWNLOAD SIMULASI
  void downloadExcel() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Download berhasil")),
    );
  }

  // 🔘 BUTTON
  Widget fullButton(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(text,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}