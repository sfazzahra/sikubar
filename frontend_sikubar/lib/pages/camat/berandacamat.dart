import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menucamat.dart';
import 'monitoringpengajuan_camat.dart';
import 'monitoringpengaduan_camat.dart';

class DashboardCamatPage extends StatefulWidget {
  const DashboardCamatPage({super.key});

  @override
  State<DashboardCamatPage> createState() => _DashboardCamatPageState();
}

class _DashboardCamatPageState extends State<DashboardCamatPage> {
  final ApiService _api = ApiService();
  bool isLoading = true;
  Map<String, dynamic> stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getCamatDashboard();
      setState(() {
        stats = res['data'] ?? {};
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A73E8), Color(0xFF56CCF2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadStats,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildGreeting(),
                const SizedBox(height: 20),
                _buildStatSection(),
                const SizedBox(height: 20),
                _buildMenuSection(context),
                const SizedBox(height: 20),
                _buildWeeklyChart(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomMenuCamat(currentIndex: 0),
    );
  }

  // ─── GREETING ─────────────────────────────
  Widget _buildGreeting() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.account_balance,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat Datang,',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('Bapak/Ibu Camat',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('Kecamatan Kundur Barat',
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── STAT CARDS ───────────────────────────
  Widget _buildStatSection() {
    if (isLoading) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }

    final items = [
      (
        'Total Pengajuan',
        stats['total_pengajuan'] ?? 0,
        Icons.assignment_outlined,
        Colors.white
      ),
      (
        'Disetujui',
        stats['pengajuan_disetujui'] ?? 0,
        Icons.check_circle_outline,
        Colors.greenAccent
      ),
      (
        'Ditolak',
        stats['pengajuan_ditolak'] ?? 0,
        Icons.cancel_outlined,
        Colors.redAccent
      ),
      (
        'Pengaduan',
        stats['total_pengaduan'] ?? 0,
        Icons.campaign_outlined,
        Colors.orangeAccent
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item.$3, color: item.$4, size: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.$2}',
                      style: TextStyle(
                          color: item.$4,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text(item.$1,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── MENU SHORTCUT ────────────────────────
  Widget _buildMenuSection(BuildContext context) {
    final menus = [
      (
        'Monitoring\nPengajuan',
        Icons.assignment_outlined,
        const MonitoringPengajuanCamatPage()
      ),
      (
        'Monitoring\nPengaduan',
        Icons.campaign_outlined,
        const MonitoringPengaduanCamatPage()
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Menu Utama',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          children: menus.map((m) {
            return Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => m.$3)),
                child: Container(
                  margin: EdgeInsets.only(
                      right: m == menus.last ? 0 : 10),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(m.$2,
                            color: const Color(0xFF1A73E8), size: 28),
                      ),
                      const SizedBox(height: 10),
                      Text(m.$1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── CHART MINGGUAN ────────────────────────
  Widget _buildWeeklyChart() {
    final weekly = List<Map<String, dynamic>>.from(
        stats['statistik_mingguan'] ??
            [
              {'hari': 'Sen', 'jumlah': 0},
              {'hari': 'Sel', 'jumlah': 0},
              {'hari': 'Rab', 'jumlah': 0},
              {'hari': 'Kam', 'jumlah': 0},
              {'hari': 'Jum', 'jumlah': 0},
            ]);

    final maxVal = weekly
        .map((e) => (e['jumlah'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengajuan Minggu Ini',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekly.map((d) {
              final val = (d['jumlah'] as num).toDouble();
              final barH = maxVal == 0 ? 10.0 : (val / maxVal) * 80;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${d['jumlah']}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    height: barH < 10 ? 10 : barH,
                    width: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(d['hari'],
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}