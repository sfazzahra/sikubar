import 'package:flutter/material.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_card.dart';
import 'lihat_pengaduan.dart';

class TanggapanPengaduanPage extends StatefulWidget {
  final String nama;

  const TanggapanPengaduanPage({super.key, required this.nama});

  @override
  State<TanggapanPengaduanPage> createState() =>
      _TanggapanPengaduanPageState();
}

class _TanggapanPengaduanPageState
    extends State<TanggapanPengaduanPage> {
  final TextEditingController tanggapanController =
      TextEditingController();

  String status = "Diproses";

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Tanggapan Pengaduan",
      child: ListView(
        children: [
          // 👤 DATA PELAPOR
          AppCard(
            child: Text(
              "Pelapor: ${widget.nama}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          // 💬 INPUT TANGGAPAN
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tanggapan"),
                const SizedBox(height: 6),
                TextField(
                  controller: tanggapanController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Tulis tanggapan...",
                  ),
                ),
              ],
            ),
          ),

          // 📌 STATUS
          AppCard(
            child: DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(
                    value: "Diproses", child: Text("Diproses")),
                DropdownMenuItem(
                    value: "Selesai", child: Text("Selesai")),
              ],
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // 🚀 BUTTON KIRIM
          GestureDetector(
            onTap: () {
              if (tanggapanController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Tanggapan tidak boleh kosong"),
                  ),
                );
                return;
              }

              // 🔥 PINDAH KE HALAMAN LIHAT PENGADUAN (SUDAH INCLUDE TANGGAPAN)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LihatPengaduanPage(
                    nama: widget.nama,
                    isi: "Pengaduan dari ${widget.nama}", // dummy isi
                    status: status,
                    tanggal: DateTime.now()
                        .toString()
                        .substring(0, 16),
                    tanggapan: tanggapanController.text, // 🔥 PENTING
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Kirim",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}