import 'package:flutter/material.dart';
import 'profil_admin.dart';
import 'tambahpengguna.dart';
import 'tambah_jenissurat.dart';

const Color _kGradStart = Color(0xFF0B2B5C);
const Color _kGradEnd   = Color(0xFF1C4FA1);

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _kGradEnd,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kGradStart, _kGradEnd],
              ),
            ),
          ),
          title: const Text(
            'Halo Admin 👋',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Color.fromARGB(255, 255, 255, 255),
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