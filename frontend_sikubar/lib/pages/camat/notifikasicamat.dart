import 'package:flutter/material.dart';

class NotifikasiCamatPage extends StatelessWidget {
  const NotifikasiCamatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// BODY
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2F80ED),
                Color(0xFF1C4FA1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),

          child: Column(
            children: [

              /// ================= HEADER =================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  children: [

                    /// 🔙 BACK
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(width: 5),

                    /// TITLE
                    const Text(
                      "Notifikasi Camat",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= LIST =================
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(15),
                  children: const [

                    /// 🔥 NOTIF 1
                    NotifikasiItem(
                      icon: Icons.description,
                      title: "Pengajuan Baru Masuk",
                      message:
                          "Pengajuan KTP-el dari Andi telah divalidasi oleh Kasi dan menunggu persetujuan Anda.",
                      time: "5 menit lalu",
                    ),

                    /// 🔥 NOTIF 2
                    NotifikasiItem(
                      icon: Icons.assignment_turned_in,
                      title: "Pengajuan Siap Disetujui",
                      message:
                          "Surat Ahli Waris dari Budi sudah diverifikasi dan siap untuk disetujui.",
                      time: "20 menit lalu",
                    ),

                    /// 🔥 NOTIF 3
                    NotifikasiItem(
                      icon: Icons.notifications_active,
                      title: "Pengajuan Diteruskan ke Camat",
                      message:
                          "Pengajuan Dispensasi Nikah dari Siti telah diteruskan ke Anda.",
                      time: "1 jam lalu",
                    ),

                    /// 🔥 NOTIF 4
                    NotifikasiItem(
                      icon: Icons.info,
                      title: "Reminder Persetujuan",
                      message:
                          "Masih ada pengajuan yang belum Anda setujui hari ini.",
                      time: "Hari ini",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= ITEM =================

class NotifikasiItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;

  const NotifikasiItem({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ICON
          CircleAvatar(
            backgroundColor: const Color(0xFF2F80ED),
            child: Icon(icon, color: Colors.white),
          ),

          const SizedBox(width: 10),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}