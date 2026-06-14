import 'package:flutter/material.dart';

import 'berandacamat.dart';
import 'monitoringpengajuan_camat.dart';
import 'monitoringpengaduan_camat.dart';
import 'profilecamat.dart';

class MainPageCamat extends StatefulWidget {
  const MainPageCamat({super.key});

  @override
  State<MainPageCamat> createState() => _MainPageCamatState();
}

class _MainPageCamatState extends State<MainPageCamat> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const DashboardCamatPage(),
    const ProfilCamatPage(),
    const MonitoringPengajuanCamatPage(),
    const MonitoringPengaduanCamatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return pages[currentIndex];
  }
}