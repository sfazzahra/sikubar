import 'package:flutter/material.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_card.dart';
import 'lihat_pengaduan.dart';
import 'tanggapan_pengaduan.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  String selectedTab = "Semua";

  List<Map<String, String>> allData = [
    {
      "nama": "Sari Dewi",
      "isi": "Pelayanan lambat",
      "status": "Baru",
      "tanggal": "12 Jan 2024",
      "tanggapan": ""
    },
    {
      "nama": "Ahmad",
      "isi": "Berkas lama diproses",
      "status": "Diproses",
      "tanggal": "10 Jan 2024",
      "tanggapan": ""
    },
    {
      "nama": "Budi",
      "isi": "Petugas tidak ramah",
      "status": "Selesai",
      "tanggal": "08 Jan 2024",
      "tanggapan": "Sudah ditindaklanjuti"
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filtered = allData.where((item) {
      return selectedTab == "Semua" || item["status"] == selectedTab;
    }).toList();

    return AppLayout(
      title: "Pengaduan Layanan",
      child: Column(
        children: [
          // 🔘 TAB + BADGE
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                tab("Semua"),
                tab("Baru"),
                tab("Diproses"),
                tab("Selesai"),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 📋 LIST
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("Tidak ada data 😢"))
                : ListView(
                    children: filtered.map((e) {
                      return buildCard(e);
                    }).toList(),
                  ),
          )
        ],
      ),
    );
  }

  // 🔢 COUNT BADGE
  String count(String status) {
    return allData
        .where((e) => e["status"] == status)
        .length
        .toString();
  }

  // 🔘 TAB
  Widget tab(String text) {
    bool active = selectedTab == text;

    String total =
        text == "Semua" ? allData.length.toString() : count(text);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? Colors.white
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                color: active ? Colors.blue : Colors.white,
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),

            // 🔥 BADGE
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: active ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                total,
                style: TextStyle(
                  fontSize: 10,
                  color:
                      active ? Colors.white : Colors.blue,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 📋 CARD
  Widget buildCard(Map<String, String> data) {
    Color statusColor = getStatusColor(data["status"]!);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(data["nama"]!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600)),
              Text(data["tanggal"]!,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 5),

          // ISI
          Text(data["isi"]!),

          const SizedBox(height: 6),

          // STATUS
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Text(
              data["status"]!,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11),
            ),
          ),

          const SizedBox(height: 10),

          // BUTTON
          Row(
            children: [
              Expanded(
                child: data["status"] == "Selesai"
                    ? btnLihat(data)
                    : btnTanggapi(data),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 🔘 BUTTON LIHAT
  Widget btnLihat(Map<String, String> data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LihatPengaduanPage(
              nama: data["nama"]!,
              isi: data["isi"]!,
              status: data["status"]!,
              tanggal: data["tanggal"]!,
              tanggapan: data["tanggapan"]!,
            ),
          ),
        );
      },
      child: buttonUI("Lihat Tanggapan", Colors.green),
    );
  }

  // 🔘 BUTTON TANGGAPI
  Widget btnTanggapi(Map<String, String> data) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                TanggapanPengaduanPage(
                    nama: data["nama"]!),
          ),
        );

        // 🔥 REALTIME UPDATE
        if (result != null) {
          setState(() {
            data["status"] = result["status"];
            data["tanggapan"] =
                result["tanggapan"];
          });
        }
      },
      child: buttonUI("Tanggapi", Colors.blue),
    );
  }

  // 🎨 BUTTON UI
  Widget buttonUI(String text, Color color) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11),
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Baru":
        return Colors.orange;
      case "Diproses":
        return Colors.blue;
      case "Selesai":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}