import 'package:flutter/material.dart';

import 'validasi_page.dart';
import 'notifikasi_kasi.dart';

class MainPageKasi extends StatefulWidget {
  const MainPageKasi({super.key});

  @override
  State<MainPageKasi> createState() => _MainPageKasiState();
}

class _MainPageKasiState extends State<MainPageKasi> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    ValidasiPage(),
    NotifikasiKasiPage(),
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
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: "Validasi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifikasi",
          ),
        ],
      ),
    );
  }
}