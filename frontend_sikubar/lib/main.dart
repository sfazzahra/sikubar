import 'package:flutter/material.dart';

import 'pages/loginpage.dart';
import 'pages/daftarpage.dart';
import 'pages/profilewarga.dart';
import 'pages/beranda.dart';
import 'pages/pengajuan.dart';
import 'pages/pengaduan.dart';
import 'pages/notifikasi.dart';
import 'pages/riwayat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SiKubar',

      initialRoute: '/',

      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        '/beranda': (context) => const BerandaPage(),
        '/pengajuan': (context) => const PengajuanPage(),
        '/pengaduan': (context) => const PengaduanPage(),
        '/notifikasi': (context) => const NotifikasiPage(),
        '/riwayat': (context) => const RiwayatPage(),

        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}