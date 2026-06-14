import 'package:flutter/material.dart';

// HALAMAN CAMAT
import '../pages/camat/berandacamat.dart';
import '../pages/camat/profilecamat.dart';
import '../pages/camat/monitoringpengajuan_camat.dart';
import '../pages/camat/monitoringpengaduan_camat.dart';

/// ================= APP BAR CAMAT =================
class AppBarCamat extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarCamat({
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

/// ================= BOTTOM MENU CAMAT =================
class BottomMenuCamat extends StatelessWidget {
  final int currentIndex;

  const BottomMenuCamat({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const DashboardCamatPage();
        break;

      case 1:
        page = const ProfilCamatPage();
        break;

      case 2:
        page = const MonitoringPengajuanCamatPage();
        break;

      case 3:
        page = const MonitoringPengaduanCamatPage();
        break;

      default:
        page = const DashboardCamatPage();
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
          icon: Icon(Icons.assignment),
          label: 'Pengajuan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report_problem),
          label: 'Pengaduan',
        ),
      ],
    );
  }
}