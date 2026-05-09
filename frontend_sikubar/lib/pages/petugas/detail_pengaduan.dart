import 'package:flutter/material.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_card.dart';
import 'tanggapan_pengaduan.dart';

class DetailPengaduanPage extends StatelessWidget {
  final String nama;
  final String isi;
  final String status;
  final String tanggal;

  const DetailPengaduanPage({
    super.key,
    required this.nama,
    required this.isi,
    required this.status,
    required this.tanggal,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = getStatusColor(status);

    return AppLayout(
      title: "Detail Pengaduan",
      child: ListView(
        children: [
          AppCard(
            child: Text("Pelapor: $nama"),
          ),
          AppCard(
            child: Text("Tanggal: $tanggal"),
          ),
          AppCard(
            child: Text("Isi: $isi"),
          ),
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status"),
                Text(status,
                    style: TextStyle(color: statusColor)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TanggapanPengaduanPage(nama: nama),
                ),
              );
            },
            child: fullButton("Tanggapi", Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget fullButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child:
            Text(text, style: const TextStyle(color: Colors.white)),
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