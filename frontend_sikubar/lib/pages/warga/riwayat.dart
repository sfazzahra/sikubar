import 'package:flutter/material.dart';
import '../../widgets/bottom_menuwarga.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  final List<Map<String, String>> semuaPengajuan = const [
    {
      "jenis": "Surat Keterangan Domisili",
      "alasan": "Pendaftaran sekolah",
      "file": "domisili.pdf",
      "status": "Menunggu Verifikasi",
    },
    {
      "jenis": "Surat Keterangan Usaha",
      "alasan": "Bantuan UMKM",
      "file": "usaha.pdf",
      "status": "Diproses",
    },
    {
      "jenis": "Surat Keterangan Tidak Mampu",
      "alasan": "Beasiswa",
      "file": "sktm.pdf",
      "status": "Disetujui",
    },
    {
      "jenis": "Surat Keterangan Kematian",
      "alasan": "Administrasi keluarga",
      "file": "kematian.pdf",
      "status": "Ditolak",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final riwayatList = semuaPengajuan.where((data) {
      return data["status"] == "Disetujui" ||
             data["status"] == "Ditolak";
    }).toList();

    return Scaffold(
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

              /// 🔥 HEADER BARU (TANPA NOTIF)
              SizedBox(
                height: 90,
                child: Stack(
                  children: [

                    /// BACK
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

                    /// TITLE
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance,
                              color: Colors.white, size: 32),
                          SizedBox(height: 4),
                          Text(
                            "Riwayat Pengajuan",
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

              /// LIST
              Expanded(
                child: riwayatList.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada riwayat",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: riwayatList.length,
                        itemBuilder: (context, index) {
                          final data = riwayatList[index];
                          final status = data["status"] ?? "-";
                          final statusColor = _getStatusColor(status);

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  data["jenis"] ?? "-",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  data["alasan"] ?? "-",
                                  style: const TextStyle(fontSize: 12),
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file, size: 16),
                                    const SizedBox(width: 5),
                                    Text(data["file"] ?? "-"),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    const Text("Status: "),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const BottomMenu(currentIndex: 3),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Disetujui":
        return Colors.green;
      case "Ditolak":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}