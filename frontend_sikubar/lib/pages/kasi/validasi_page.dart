import 'package:flutter/material.dart';

class ValidasiPage extends StatefulWidget {
  const ValidasiPage({super.key});

  @override
  State<ValidasiPage> createState() => _ValidasiPageState();
}

class _ValidasiPageState extends State<ValidasiPage> {
  String selectedTab = "Semua";

  final List<Map<String, String>> data = [
    {"nama": "Siti Fatimah", "layanan": "SKU", "status": "Diproses"},
    {"nama": "Raniya", "layanan": "SKTM", "status": "Disetujui"},
    {"nama": "Cahya Syifa", "layanan": "SKBM", "status": "Diproses"},
  ];

  @override
  Widget build(BuildContext context) {
    final list = filteredData();

    return Scaffold(
      appBar: AppBar(title: const Text("Validasi")),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // TAB
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                tab("Semua"),
                tab("Diproses"),
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
          ),
        ],
      ),
    );
  }

  Widget tab(String text) {
    final active = selectedTab == text;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = text),
      child: Container(
        margin: const EdgeInsets.only(right: 8, left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildCard(Map item) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(item['nama'] ?? ''),
        subtitle: Text(item['layanan'] ?? ''),
        trailing: Text(item['status'] ?? ''),
      ),
    );
  }

  List<Map<String, String>> filteredData() {
    if (selectedTab == "Semua") return data;
    return data.where((e) => e['status'] == selectedTab).toList();
  }
}