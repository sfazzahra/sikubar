import 'package:flutter/material.dart';

class BottomMenuKasi extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomMenuKasi({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,

      selectedItemColor: const Color(0xFF1C4FA1),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check_outlined),
          activeIcon: Icon(Icons.fact_check),
          label: "Validasi",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}