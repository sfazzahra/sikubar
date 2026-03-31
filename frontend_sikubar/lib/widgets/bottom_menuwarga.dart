import 'package:flutter/material.dart';

import '../pages/beranda.dart';
import '../pages/pengajuan.dart';
import '../pages/pengaduan.dart';
import '../pages/notifikasi.dart';
import '../pages/riwayat.dart';
import '../pages/profilewarga.dart';

/// ================= APP BAR =================

class AppBarSiKubar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarSiKubar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: const Color(0xFF2F80ED),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotifikasiPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// ================= BOTTOM MENU =================

class BottomMenu extends StatelessWidget {
  final int currentIndex;

  const BottomMenu({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return; // ✅ biar gak reload page yang sama

    Widget page;

    switch (index) {
      case 0:
        page = const BerandaPage();
        break;
      case 1:
        page = const PengajuanPage();
        break;
      case 2:
        page = const PengaduanPage();
        break;
      case 3:
        page = const RiwayatPage();
        break;
      case 4:
        page = const ProfilePage();
        break;
      default:
        page = const BerandaPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF1C4FA1),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,

      onTap: (index) => _navigate(context, index),

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: "Pengajuan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report_problem),
          label: "Pengaduan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: "Riwayat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}