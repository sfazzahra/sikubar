import 'package:flutter/material.dart';

import '../pages/petugas/berandapetugas.dart';
import '../pages/petugas/profilepetugas.dart';
import '../pages/petugas/verifikasipetugas.dart';
import '../pages/petugas/pengaduan_petugas.dart';
import '../pages/petugas/monitoring_petugas.dart';

class BottomMenuPetugas extends StatelessWidget {
  final int currentIndex;

  const BottomMenuPetugas({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const BerandaPetugasPage();
        break;
      case 1:
        page = const ProfilePetugasPage();
        break;
      case 2:
        page = const VerifikasiPetugasPage();
        break;
      case 3:
        page = const PengaduanPetugasPage();
        break;
      case 4:
        page = const MonitoringPetugasPage();
        break;
      default:
        page = const BerandaPetugasPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF2F80ED),
      unselectedItemColor: Colors.grey,
      onTap: (index) => _navigate(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        BottomNavigationBarItem(icon: Icon(Icons.verified), label: "Verifikasi"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Pengaduan"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Monitoring"),
      ],
    );
  }
}