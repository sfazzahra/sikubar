import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menucamat.dart';
import '../../widgets/app_scaffold.dart';
import 'monitoringpengajuan_camat.dart';
import 'monitoringpengaduan_camat.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/notification_badge.dart';
import '../../notifications/notifikasi_page.dart';

const Color kPrimary     = Color(0xFF2F80ED);
const Color kPrimaryDark = Color(0xFF1B5FC4);
const Color kTeal        = Color(0xFF0D9488);
const Color kOrange      = Color(0xFFF97316);
const Color kGreen       = Color(0xFF10B981);
const Color kRed         = Color(0xFFEF4444);
const Color kPurple      = Color(0xFF7C3AED);

class DashboardCamatPage extends StatefulWidget {
  const DashboardCamatPage({super.key});

  @override
  State<DashboardCamatPage> createState() => _DashboardCamatPageState();
}

class _DashboardCamatPageState extends State<DashboardCamatPage>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  bool isLoading = true;
  Map<String, dynamic> stats = {};

  @override
void initState() {
  super.initState();

  _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  _fadeIn = CurvedAnimation(
    parent: _animCtrl,
    curve: Curves.easeOut,
  );

  _loadStats();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.fetchNotifikasi();
  });
}

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getCamatDashboard();
      setState(() {
        stats     = res['data'] ?? {};
        isLoading = false;
      });
      _animCtrl.forward(from: 0);
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
  title: 'Dashboard Camat',
  showBack: false,

  actions: [
    NotificationBadgeIcon(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotifikasiPage(),
          ),
        );
      },
    ),
  ],

  bottomNavigationBar: const BottomMenuCamat(currentIndex: 0),
  body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : FadeTransition(
              opacity: _fadeIn,
              child: RefreshIndicator(
                color: kPrimary,
                backgroundColor: Colors.white,
                onRefresh: _loadStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(),
                      const SizedBox(height: 24),
                      _sectionTitle('Statistik', Icons.bar_chart_rounded),
                      const SizedBox(height: 12),
                      _buildStatSection(),
                      const SizedBox(height: 24),
                      _sectionTitle('Menu Monitoring', Icons.dashboard_rounded),
                      const SizedBox(height: 12),
                      _buildMenuSection(context),
                      const SizedBox(height: 24),
                      _sectionTitle('Pengajuan Minggu Ini', Icons.show_chart_rounded),
                      const SizedBox(height: 12),
                      _buildWeeklyChart(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ─── SECTION TITLE ──────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ─── GREETING ───────────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    final now = DateTime.now();
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dateStr = '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    String greeting = 'Selamat Pagi';
    if (now.hour >= 11 && now.hour < 15) greeting = 'Selamat Siang';
    else if (now.hour >= 15 && now.hour < 18) greeting = 'Selamat Sore';
    else if (now.hour >= 18) greeting = 'Selamat Malam';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, kPrimaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.account_balance_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Camat',
                  style: TextStyle(
                    color: Color(0xFF1B2433),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_city_rounded,
                        size: 12, color: kPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'Kundur Barat',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today_rounded,
                        size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STATISTIK 2×2 ──────────────────────────────────────────────────────────
  Widget _buildStatSection() {
    final items = [
      {
        'label': 'Total Pengajuan',
        'value': (stats['total_pengajuan'] ?? 0).toString(),
        'icon': Icons.assignment_rounded,
        'color': kPrimary,
        'bg': const Color(0xFFEFF6FF),
      },
      {
        'label': 'Disetujui',
        'value': (stats['pengajuan_disetujui'] ?? 0).toString(),
        'icon': Icons.check_circle_rounded,
        'color': kGreen,
        'bg': const Color(0xFFF0FDF4),
      },
      {
        'label': 'Ditolak',
        'value': (stats['pengajuan_ditolak'] ?? 0).toString(),
        'icon': Icons.cancel_rounded,
        'color': kRed,
        'bg': const Color(0xFFFEF2F2),
      },
      {
        'label': 'Pengaduan',
        'value': (stats['total_pengaduan'] ?? 0).toString(),
        'icon': Icons.campaign_rounded,
        'color': kOrange,
        'bg': const Color(0xFFFFF7ED),
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard(items[0])),
            const SizedBox(width: 10),
            Expanded(child: _statCard(items[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _statCard(items[2])),
            const SizedBox(width: 10),
            Expanded(child: _statCard(items[3])),
          ],
        ),
      ],
    );
  }

  Widget _statCard(Map<String, dynamic> d) {
    final color   = d['color'] as Color;
    final bgColor = d['bg'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(d['icon'] as IconData, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['value'] as String,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  d['label'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── MENU MONITORING ────────────────────────────────────────────────────────
  Widget _buildMenuSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _menuCard(
            label: 'Monitoring Pengajuan',
            sublabel: 'Pantau status pengajuan',
            icon: Icons.assignment_outlined,
            color: kPrimary,
            bgColor: const Color(0xFFEFF6FF),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MonitoringPengajuanCamatPage())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _menuCard(
            label: 'Monitoring Pengaduan',
            sublabel: 'Pantau laporan warga',
            icon: Icons.campaign_outlined,
            color: kOrange,
            bgColor: const Color(0xFFFFF7ED),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MonitoringPengaduanCamatPage())),
          ),
        ),
      ],
    );
  }

  Widget _menuCard({
    required String label,
    required String sublabel,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1B2433),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: color, size: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── BAR CHART MINGGUAN ─────────────────────────────────────────────────────
  Widget _buildWeeklyChart() {
    final weekly = List<Map<String, dynamic>>.from(
      stats['statistik_mingguan'] ?? [
        {'hari': 'Sen', 'jumlah': 0},
        {'hari': 'Sel', 'jumlah': 0},
        {'hari': 'Rab', 'jumlah': 0},
        {'hari': 'Kam', 'jumlah': 0},
        {'hari': 'Jum', 'jumlah': 0},
        {'hari': 'Sab', 'jumlah': 0},
        {'hari': 'Min', 'jumlah': 0},
      ],
    );

    final maxVal = weekly
        .map((e) => (e['jumlah'] as num).toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    final barColors = [kPrimary, kPurple, kTeal, kOrange, kGreen, kPrimary, kPurple];
    final bgColors  = [
      const Color(0xFFEFF6FF),
      const Color(0xFFF5F3FF),
      const Color(0xFFF0FDFA),
      const Color(0xFFFFF7ED),
      const Color(0xFFF0FDF4),
      const Color(0xFFEFF6FF),
      const Color(0xFFF5F3FF),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengajuan per Hari',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1B2433),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Minggu Ini',
                  style: TextStyle(
                    color: kPrimary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weekly.length, (i) {
                final d      = weekly[i];
                final val    = (d['jumlah'] as num).toDouble();
                final ratio  = maxVal == 0 ? 0.0 : val / maxVal;
                final barH   = 12.0 + ratio * 60;
                final color  = barColors[i % barColors.length];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${d['jumlah']}',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      height: barH,
                      width: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.7), color],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      d['hari'],
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}