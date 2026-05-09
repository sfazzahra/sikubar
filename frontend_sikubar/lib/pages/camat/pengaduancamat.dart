import 'package:flutter/material.dart';
import '../../widgets/bottom_menucamat.dart';

class PengaduanCamatPage extends StatefulWidget {
  const PengaduanCamatPage({super.key});

  @override
  State<PengaduanCamatPage> createState() =>
      _PengaduanCamatPageState();
}

class _PengaduanCamatPageState
    extends State<PengaduanCamatPage> {

  /// 🔥 DATA DUMMY (DARI WARGA + BALASAN PETUGAS)
  List<Map<String, dynamic>> pengaduanList = [
    {
      "nama": "Andi",
      "kategori": "Pelayanan Lambat",
      "isi": "Pengurusan KTP lama sekali",
      "file": "bukti1.jpg",
      "status": "Diproses",
      "balasan": null
    },
    {
      "nama": "Budi",
      "kategori": "Fasilitas Kurang",
      "isi": "Ruang tunggu panas",
      "file": "bukti2.jpg",
      "status": "Selesai",
      "balasan": "Terima kasih, akan diperbaiki"
    },
    {
      "nama": "Siti",
      "kategori": "Petugas Tidak Ramah",
      "isi": "Petugas kurang sopan",
      "file": "bukti3.jpg",
      "status": "Selesai",
      "balasan": "Kami akan tindak lanjuti"
    },
  ];

  @override
  Widget build(BuildContext context) {

    final selesai = pengaduanList
        .where((e) => e["status"] == "Selesai")
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(

        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
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
                              "Pengaduan Camat",
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

                /// 🔥 TAB
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.white,
                    tabs: [
                      Tab(text: "Semua"),
                      Tab(text: "Selesai"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: TabBarView(
                    children: [

                      /// ================= SEMUA =================
                      ListView.builder(
                        itemCount: pengaduanList.length,
                        itemBuilder: (context, index) {
                          final item = pengaduanList[index];
                          return buildCard(item);
                        },
                      ),

                      /// ================= SELESAI =================
                      ListView.builder(
                        itemCount: selesai.length,
                        itemBuilder: (context, index) {
                          final item = selesai[index];
                          return buildCard(item);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        bottomNavigationBar:
            const BottomMenuCamat(currentIndex: 4),
      ),
    );
  }

  /// 🔥 CARD UI
  Widget buildCard(Map item) {
    Color statusColor =
        item["status"] == "Selesai"
            ? Colors.green
            : Colors.orange;

    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(item["nama"],
              style: const TextStyle(
                  fontWeight: FontWeight.bold)),

          const SizedBox(height: 5),

          Text(item["kategori"]),
          Text(item["isi"]),

          const SizedBox(height: 8),

          Text("File: ${item["file"]}"),

          const SizedBox(height: 8),

          /// STATUS
          Row(
            children: [
              const Text("Status: "),
              Text(
                item["status"],
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          /// BALASAN PETUGAS
          if (item["balasan"] != null) ...[
            const SizedBox(height: 10),
            const Text("Balasan Petugas:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(item["balasan"]),
          ],
        ],
      ),
    );
  }
}