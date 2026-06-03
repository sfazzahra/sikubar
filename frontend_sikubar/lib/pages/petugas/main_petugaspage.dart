import 'package:flutter/material.dart';

// Import halaman petugas
import 'berandapetugas.dart';
import 'verifikasipetugas.dart';
import 'pengaduan_petugas.dart';
import 'monitoring_petugas.dart';
import 'profilepetugas.dart';

class MainPetugasPage extends StatefulWidget {
  const MainPetugasPage({super.key});

  @override
  State<MainPetugasPage> createState() => _MainPetugasPageState();
}

class _MainPetugasPageState extends State<MainPetugasPage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    BerandaPetugasPage(),
    ProfilePetugasPage(),
    VerifikasiPetugasPage(),
    PengaduanPetugasPage(),
    MonitoringPetugasPage(),
  ];

  void onTabChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2F80ED),
        unselectedItemColor: Colors.grey,
        onTap: onTabChanged,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
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
            label: "Monitoring",
          ),
        ],
      ),
    );
  }
}