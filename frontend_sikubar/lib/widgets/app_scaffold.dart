import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool? showBack;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showBack,
    this.actions,
  });

  static const Color primaryDark = Color(0xFF0B2B5C);
  static const Color primary = Color(0xFF1C4FA1);
  static const Color primaryLight = Color(0xFF2F80ED);

  @override
  Widget build(BuildContext context) {
    final canPop = showBack ?? Navigator.canPop(context);

    return Scaffold(
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // ── BACKGROUND sama seperti login ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryDark, primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Shape geometris kanan atas
          Positioned(
            top: -120,
            right: -90,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  gradient: LinearGradient(
                    colors: [
                      primaryLight.withOpacity(0.35),
                      primaryLight.withOpacity(0.0),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          ),
          // Lingkaran outline kiri bawah
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 40,
                ),
              ),
            ),
          ),

          // ── KONTEN UTAMA ──
          SafeArea(
            child: Column(
              children: [
                _AppHeader(
                  title: title,
                  canPop: canPop,
                  actions: actions,
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  final String title;
  final bool canPop;
  final List<Widget>? actions;

  const _AppHeader({
    required this.title,
    required this.canPop,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Stack(
        children: [
          if (canPop)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/LogoSiKubar.png',
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          if (actions != null && actions!.isNotEmpty)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}