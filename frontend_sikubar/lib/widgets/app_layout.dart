import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const AppLayout({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 🔵 BACKGROUND GRADIENT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 🔥 HEADER FIX
              SizedBox(
  height: 90,
  child: Stack(
    children: [
      // 🔙 BACK BUTTON (FIX DI KIRI ATAS)
      if (Navigator.canPop(context))
        Positioned(
          left: 16,
          top: 10, // 🔥 ini bikin dia naik ke atas
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back,
                color: Colors.white, size: 26),
          ),
        ),

      // 🎯 CENTER (ICON + TITLE)
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance,
                color: Colors.white, size: 32),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

              const SizedBox(height: 10),

              // 📦 CONTENT
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}