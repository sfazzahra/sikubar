import 'package:flutter/material.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_card.dart';

class ProsesVerifikasiPage extends StatefulWidget {
  final Map data;

  const ProsesVerifikasiPage({
    super.key,
    required this.data,
  });

  @override
  State<ProsesVerifikasiPage> createState() =>
      _ProsesVerifikasiPageState();
}

class _ProsesVerifikasiPageState
    extends State<ProsesVerifikasiPage> {
  final TextEditingController alasanController =
      TextEditingController();

  bool showAlasan = false;

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Proses Verifikasi",
      child: ListView(
        children: [
          AppCard(child: Text("Nama: ${widget.data['nama']}")),
          AppCard(child: Text("Layanan: ${widget.data['layanan']}")),

          const SizedBox(height: 20),

          // ✅ SETUJUI
          button("Setujui", Colors.green, () {
            Navigator.pop(context, {
              "status": "Disetujui", // ✅ FIX DI SINI
              "alasan": "",
            });
          }),

          const SizedBox(height: 10),

          // 🔄 DIPROSES
          button("Diproses", Colors.blue, () {
            Navigator.pop(context, {
              "status": "Diproses",
              "alasan": "",
            });
          }),

          const SizedBox(height: 10),

          // ❌ TOLAK
          button("Tolak", Colors.red, () {
            setState(() {
              showAlasan = true;
            });
          }),

          // 🔥 INPUT ALASAN
          if (showAlasan) ...[
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Alasan Penolakan"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: alasanController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Contoh: Berkas tidak lengkap",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🚀 KIRIM PENOLAKAN
            button("Kirim Penolakan", Colors.red, () {
              if (alasanController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Alasan wajib diisi"),
                  ),
                );
                return;
              }

              Navigator.pop(context, {
                "status": "Ditolak",
                "alasan": alasanController.text,
              });
            }),
          ],
        ],
      ),
    );
  }

  Widget button(
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
      ),
    );
  }
}