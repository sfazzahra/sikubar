import 'package:flutter/material.dart';

// ================= NOTIFICATION =================
import 'notifications/notification_service.dart';

// ================= AUTH =================
import 'pages/loginpage.dart';

// ================= WARGA =================
import 'pages/warga/beranda.dart';
import 'pages/warga/pengajuan.dart';
import 'pages/warga/pengaduan.dart' as warga;
import 'pages/warga/profilewarga.dart' as wargaProfile;
import 'pages/warga/riwayat.dart';

// ================= PETUGAS =================
import 'pages/petugas/main_petugaspage.dart';

// ================= CAMAT =================
import 'pages/camat/main_pagecamat.dart';

// ================= KASI =================
import 'pages/kasi/main_kasipage.dart';

// ================= ADMIN =================
import 'pages/admin/admin.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // // Observer lifecycle supaya badge refresh saat app dibuka lagi
  // WidgetsBinding.instance.addObserver(
  //   AppLifecycleNotificationObserver(),
  // );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SiKubar',
      initialRoute: '/',
      routes: {
        // ================= AUTH =================
        '/': (context) => const LoginPage(),

        // ================= WARGA =================
        '/warga': (context) => const BerandaPage(),
        '/beranda': (context) => const BerandaPage(),
        '/pengajuan': (context) => const PengajuanPage(),
        '/pengaduan': (context) => const warga.PengaduanPage(),
        '/riwayat': (context) => const RiwayatPage(),
        '/profile': (context) => const wargaProfile.ProfilePage(),

        // ================= PETUGAS =================
        '/petugas': (context) => const MainPetugasPage(),

        // ================= CAMAT =================
        '/camat': (context) => const MainPageCamat(),

        // ================= KASI =================
        '/kasi': (context) => const MainKasiPage(),

        // ================= ADMIN =================
        '/admin': (context) => const AdminPage(),
      },
    );
  }
}