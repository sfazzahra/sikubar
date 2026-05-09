import 'package:flutter/material.dart';
import '../../widgets/bottom_menucamat.dart';

class PersetujuanPage extends StatefulWidget {
  const PersetujuanPage({super.key});

  @override
  State<PersetujuanPage> createState() => _PersetujuanPageState();
}

class _PersetujuanPageState extends State<PersetujuanPage> {

  /// 🔥 DATA DUMMY (MIRIP DATA WARGA)
  List<Map<String, dynamic>> pengajuanList = [
    {
      "nama": "Andi Saputra",
      "jenis_surat": "Pembuatan KTP-el",
      "alasan": "KTP hilang",
      "status": "Menunggu"
    },
    {
      "nama": "Budi Santoso",
      "jenis_surat": "Ahli Waris",
      "alasan": "Pengurusan warisan",
      "status": "Menunggu"
    },
    {
      "nama": "Siti Aminah",
      "jenis_surat": "Dispensasi Nikah",
      "alasan": "Keadaan mendesak",
      "status": "Disetujui"
    },
    {
      "nama": "Rizky",
      "jenis_surat": "Rekomendasi BBM",
      "alasan": "Untuk usaha",
      "status": "Ditolak"
    },
  ];

  /// 🔥 UPDATE STATUS
  void updateStatus(int index, String status) {
    setState(() {
      pengajuanList[index]["status"] = status;
    });
  }

  @override
  Widget build(BuildContext context) {

    /// FILTER DATA
    final menunggu = pengajuanList
        .where((e) => e["status"] == "Menunggu")
        .toList();

    final riwayat = pengajuanList
        .where((e) =>
            e["status"] == "Disetujui" ||
            e["status"] == "Ditolak")
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
                              "Persetujuan Camat",
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
                      Tab(text: "Menunggu"),
                      Tab(text: "Riwayat"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: TabBarView(
                    children: [

                      /// ================= MENUNGGU =================
                      ListView.builder(
                        itemCount: menunggu.length,
                        itemBuilder: (context, index) {
                          final item = menunggu[index];

                          return buildCard(item, index, true);
                        },
                      ),

                      /// ================= RIWAYAT =================
                      ListView.builder(
                        itemCount: riwayat.length,
                        itemBuilder: (context, index) {
                          final item = riwayat[index];

                          return buildCard(item, index, false);
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
            const BottomMenuCamat(currentIndex: 2),
      ),
    );
  }

  /// 🔥 CARD UI
  Widget buildCard(Map item, int index, bool isAction) {
    Color statusColor;

    switch (item["status"]) {
      case "Disetujui":
        statusColor = Colors.green;
        break;
      case "Ditolak":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

          Text(item["jenis_surat"]),
          Text(item["alasan"]),

          const SizedBox(height: 10),

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

          /// BUTTON ACTION
          if (isAction) ...[
            const SizedBox(height: 10),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: () {
                      updateStatus(index, "Disetujui");
                    },
                    child: const Text("Setujui"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    onPressed: () {
                      updateStatus(index, "Ditolak");
                    },
                    child: const Text("Tolak"),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}