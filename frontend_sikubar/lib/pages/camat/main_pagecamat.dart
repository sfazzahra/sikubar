import 'package:flutter/material.dart';

import 'berandacamat.dart';
import 'persetujuan.dart';
import 'monitoringcamat.dart';
import 'pengaduancamat.dart';
import 'profilecamat.dart';

class MainPageCamat extends StatefulWidget {
  const MainPageCamat({super.key});

  @override
  State<MainPageCamat> createState() => _MainPageCamatState();
}

class _MainPageCamatState extends State<MainPageCamat> {

  int currentIndex = 0;

  final pages = [
    const BerandaCamatPage(),
    const ProfilCamatPage(),
    const PersetujuanPage(),
    const MonitoringPage(),
    const PengaduanCamatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

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
            icon: Icon(Icons.person),
            label: "Profil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Persetujuan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Monitoring",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: "Pengaduan",
          ),
        ],
      ),
    );
  }
}