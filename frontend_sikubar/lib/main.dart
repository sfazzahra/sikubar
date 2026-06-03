import 'package:flutter/material.dart';

// ================= AUTH =================
import 'pages/loginpage.dart';

// ================= WARGA =================
import 'pages/warga/beranda.dart';
import 'pages/warga/pengajuan.dart';
import 'pages/warga/pengaduan.dart' as warga;
import 'pages/warga/notifikasi.dart';
import 'pages/warga/riwayat.dart';
import 'pages/warga/profilewarga.dart' as wargaProfile;

// ================= PETUGAS =================
import 'pages/petugas/main_petugaspage.dart';

// ================= CAMAT =================
import 'pages/camat/main_pagecamat.dart';

// ================= KASI =================
import 'pages/kasi/main_kasipage.dart';

// ================= ADMIN =================
import 'pages/admin/admin.dart';

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

      /// UNTUK TEST ROLE
      initialRoute: '/',

      routes: {
        /// ================= AUTH =================
        '/': (context) => const LoginPage(),

        /// ================= WARGA =================
        '/warga': (context) => const BerandaPage(),
        '/beranda': (context) => const BerandaPage(),
        '/pengajuan': (context) => const PengajuanPage(),
        '/pengaduan': (context) => const warga.PengaduanPage(),
        '/notifikasi': (context) => const NotifikasiPage(),
        '/riwayat': (context) => const RiwayatPage(),
        '/profile': (context) => const wargaProfile.ProfilePage(),

        /// ================= PETUGAS =================
        '/petugas': (context) => const MainPetugasPage(),

        /// ================= CAMAT =================
        '/camat': (context) => const MainPageCamat(),

        /// ================= KASI =================
        '/kasi': (context) => const MainKasiPage(),

        /// ================= ADMIN =================
        '/admin': (context) => const AdminPage(),
      },
    );
  }
}