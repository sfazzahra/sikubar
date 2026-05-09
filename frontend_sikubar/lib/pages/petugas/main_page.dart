import 'package:flutter/material.dart';

// import halaman petugas
import 'beranda.dart';
import 'verifikasi.dart';
import 'pengaduan.dart';
import 'laporan.dart';
import 'profile.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const BerandaPage(),
    const VerifikasiPage(),
    const PengaduanPage(),
    const LaporanPage(),
    const ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: "Verifikasi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Pengaduan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Laporan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}