import 'package:flutter/material.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_card.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String nama = "Admin Kecamatan";
  String email = "admin@gmail.com";
  String kecamatan = "Kundur Barat";

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Profile",
      child: ListView(
        children: [
          const SizedBox(height: 10),

          // 🖼️ FOTO + NAMA (BISA DIKLIK)
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ganti foto profil")),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage(
                        "assets/images/fotoprofile.png",
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Petugas Kecamatan",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 📋 INFO AKUN
          const Text("Informasi Akun",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          infoItem(Icons.person, "Nama", nama),
          infoItem(Icons.email, "Email", email),
          infoItem(Icons.location_city, "Kecamatan", kecamatan),

          const SizedBox(height: 20),

          // ⚙️ PENGATURAN
          const Text("Pengaturan",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          menuItem(Icons.edit, "Edit Profil", () => editProfil()),
          menuItem(Icons.lock, "Ganti Password", () => gantiPassword()),

          const SizedBox(height: 20),

          // 🚪 LOGOUT
          logoutButton(),
        ],
      ),
    );
  }

  // 📋 INFO ITEM
  Widget infoItem(IconData icon, String title, String value) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ⚙️ MENU ITEM (SUDAH AKTIF)
  Widget menuItem(IconData icon, String title, VoidCallback onTap) {
    return AppCard(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 10),
              Text(title),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 14)
        ],
      ),
    );
  }

  // ✏️ EDIT PROFIL
  void editProfil() {
    TextEditingController namaC = TextEditingController(text: nama);
    TextEditingController emailC = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profil"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaC, decoration: const InputDecoration(labelText: "Nama")),
            TextField(controller: emailC, decoration: const InputDecoration(labelText: "Email")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                nama = namaC.text;
                email = emailC.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // 🔒 GANTI PASSWORD
  void gantiPassword() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ganti Password"),
        content: const Text("Fitur ini belum terhubung ke backend"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // 🚪 LOGOUT (KONFIRMASI)
  Widget logoutButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Konfirmasi"),
            content: const Text("Yakin ingin logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Logout berhasil")),
                  );
                },
                child: const Text("Logout"),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "Logout",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}