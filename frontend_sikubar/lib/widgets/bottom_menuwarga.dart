import 'package:flutter/material.dart';

import '../pages/warga/beranda.dart';
import '../pages/warga/pengajuan.dart';
import '../pages/warga/pengaduan.dart';
import '../pages/warga/profilewarga.dart';
import '../pages/warga/riwayat.dart';

/// ================= APP BAR =================
class AppBarSiKubar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarSiKubar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2F80ED),
            Color(0xFF56CCF2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 90,
          child: Stack(
            children: [
              // 🔙 BACK BUTTON
              if (Navigator.canPop(context))
                Positioned(
                  left: 16,
                  top: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),

              // 🎯 TITLE + ICON
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

/// ================= BOTTOM MENU =================
class BottomMenu extends StatelessWidget {
  final int currentIndex;

  const BottomMenu({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const BerandaPage();
        break;
      case 1:
        page = const ProfilePage();
        break;
      case 2:
        page = const PengajuanPage();
        break;
      case 3:
        page = const RiwayatPage();
        break;
      case 4:
        page = const PengaduanPage();
        break;
      default:
        page = const BerandaPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
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
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Pengajuan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report_problem),
          label: 'Pengaduan',
        ),
      ],
    );
  }
}