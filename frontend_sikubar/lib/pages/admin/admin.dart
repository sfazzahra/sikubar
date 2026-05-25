import 'package:flutter/material.dart';
import 'profil_admin.dart';
import 'tambahpengguna.dart';
import 'tambah_jenissurat.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F80ED),
          elevation: 0,
          title: const Text(
            'Halo Admin 👋',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.people_outline), text: 'Pengguna'),
              Tab(icon: Icon(Icons.description_outlined), text: 'Jenis Surat'),
              Tab(icon: Icon(Icons.person_outline), text: 'Profil'),
            ],
          ),
        ),
        body: const TabBarView(children: [
          AdminPenggunaTab(),
          AdminJenisSuratTab(),
          AdminProfilTab(),
        ]),
      ),
    );
  }
}