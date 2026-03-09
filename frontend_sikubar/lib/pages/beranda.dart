import 'package:flutter/material.dart';
import '../widgets/bottom_menuwarga.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// APPBAR DENGAN LONCENG
      appBar: const AppBarSiKubar(
        title: "Beranda",
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

        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),

            child: const Text(
              "Selamat Datang di Aplikasi SiKubar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

      /// MENU BAWAH
      bottomNavigationBar: const BottomMenu(
        currentIndex: 0,
      ),
    );
  }
}