import 'package:flutter/material.dart';
import '../widgets/bottom_menuwarga.dart';

class PengaduanPage extends StatelessWidget {
  const PengaduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// APPBAR DENGAN LONCENG
      appBar: const AppBarSiKubar(
        title: "Pengaduan",
      ),

      /// BODY
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2F80ED),
              Color(0xFF1C4FA1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: const Center(
          child: Text(
            "Halaman Pengaduan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),

      /// MENU BAWAH
      bottomNavigationBar: const BottomMenu(
        currentIndex: 2,
      ),
    );
  }
}