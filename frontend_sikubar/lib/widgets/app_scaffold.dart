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

  @override
  Widget build(BuildContext context) {
    final canPop = showBack ?? Navigator.canPop(context);

    return Scaffold(
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            
            colors: [Color(0xFF2F80ED), Color(0xFF1C4FA1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
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
      height: 110, // sebelumnya 90
      child: Stack(
        children: [
          // Tombol back
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

          // Logo dan judul
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

          // Actions kanan
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