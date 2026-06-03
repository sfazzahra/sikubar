import 'package:flutter/material.dart';

import '../../widgets/bottom_menukasi.dart';
import 'berandakasi.dart';
import 'validasikasi.dart';
import 'profilekasi.dart';

class MainKasiPage extends StatefulWidget {
  const MainKasiPage({super.key});

  @override
  State<MainKasiPage> createState() => _MainKasiPageState();
}

class _MainKasiPageState extends State<MainKasiPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    BerandaKasiPage(),
    ValidasiKasiPage(),
    ProfileKasiPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomMenuKasi(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}