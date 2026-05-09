import 'package:flutter/material.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_card.dart';
import 'proses_verifikasi.dart';

class DetailVerifikasiPage extends StatelessWidget {
  final Map data;

  const DetailVerifikasiPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Color statusColor = getStatusColor(data['status']);

    return AppLayout(
      title: "Detail Berkas",
      child: ListView(
        children: [
          AppCard(child: Text("Nama: ${data['nama']}")),
          AppCard(child: Text("Layanan: ${data['layanan']}")),

          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status"),
                Text(
                  data['status'],
                  style: TextStyle(color: statusColor),
                ),
              ],
            ),
          ),

          // ❌ ALASAN JIKA DITOLAK
          if (data['status'] == "Ditolak" &&
              data['alasan'] != "")
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Alasan Penolakan",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(data['alasan']),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // 📎 FILE BERKAS
          const Text(
            "Berkas Upload",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),

          AppCard(
            child: Column(
              children: [
                fileItem("KTP.pdf"),
                fileItem("KK.pdf"),
                fileItem("Surat Pengantar.pdf"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🚀 PROSES (hanya kalau belum selesai)
          if (data['status'] != "Disetujui")
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProsesVerifikasiPage(data: data),
                  ),
                );

                if (result != null) {
                  Navigator.pop(context, result);
                }
              },
              child: fullButton(
                  "Proses Verifikasi", Colors.blue),
            ),
        ],
      ),
    );
  }

  Widget fileItem(String name) {
    return ListTile(
      leading: const Icon(Icons.insert_drive_file,
          color: Colors.blue),
      title: Text(name),
      trailing: const Icon(Icons.remove_red_eye),
      onTap: () {
        // nanti bisa buka file
      },
    );
  }

  Widget fullButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Diproses":
        return Colors.blue;
      case "Ditolak":
        return Colors.red;
      case "Disetujui": // ✅ FIX
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}