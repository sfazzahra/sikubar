import 'package:flutter/material.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_card.dart';
import 'detail_verifikasi.dart';

class VerifikasiPage extends StatefulWidget {
  const VerifikasiPage({super.key});

  @override
  State<VerifikasiPage> createState() => _VerifikasiPageState();
}

class _VerifikasiPageState extends State<VerifikasiPage> {
  String selectedTab = "Semua";

  List data = [
    {
      "nama": "Siti Fatimah",
      "layanan": "SKU",
      "status": "Pending",
      "alasan": ""
    },
    {
      "nama": "Raniya",
      "layanan": "SKTM",
      "status": "Diproses",
      "alasan": ""
    },
    {
      "nama": "cahya syifa",
      "layanan": "SKBM",
      "status": "Pending",
      "alasan": ""
    },
    {
      "nama": "Siti Aminah",
      "layanan": "SKU",
      "status": "Disetujui",
      "alasan": ""
    },
  ];

  @override
  Widget build(BuildContext context) {
    final list = filteredData();

    return AppLayout(
      title: "Verifikasi Berkas",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: searchBox()),
              const SizedBox(width: 10),
              dropdownBox("120"),
            ],
          ),
          const SizedBox(height: 10),

          // ✅ TAB (SCROLLABLE)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                tab("Semua"),
                tab("Pending"),
                tab("Diproses"),
                tab("Ditolak"),
                tab("Disetujui"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return buildCard(list[index]);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Text("Cari berkas...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget dropdownBox(String text) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text("$text ▼")),
    );
  }

  Widget tab(String text) {
    bool active = selectedTab == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = text;
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

  Widget buildCard(Map item) {
    Color statusColor = getStatusColor(item['status']);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailVerifikasiPage(data: item),
            ),
          );

          if (result != null) {
            setState(() {
              item['status'] = result['status'];
              item['alasan'] = result['alasan'];
            });
          }
        },
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['nama'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
              const SizedBox(height: 4),
              Text(item['layanan']),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item['status'],
                  style: TextStyle(color: statusColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List filteredData() {
    if (selectedTab == "Semua") return data;

    return data
        .where((item) => item['status'] == selectedTab)
        .toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Diproses":
        return Colors.blue;
      case "Ditolak":
        return Colors.red;
      case "Disetujui":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}