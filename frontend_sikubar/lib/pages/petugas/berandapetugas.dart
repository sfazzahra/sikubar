import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/notification_badge.dart';
import '../../notifications/notifikasi_page.dart';
import '../../widgets/app_scaffold.dart';

const Color kPrimary     = Color(0xFF2F80ED);
const Color kPrimaryDark = Color(0xFF1B5FC4);
const Color kTeal        = Color(0xFF0D9488);
const Color kOrange      = Color(0xFFF97316);
const Color kGreen       = Color(0xFF10B981);
const Color kRed         = Color(0xFFEF4444);
const Color kPurple      = Color(0xFF7C3AED);

String _sapaan() {
  final h = DateTime.now().hour;
  if (h < 11) return 'Selamat Pagi';
  if (h < 15) return 'Selamat Siang';
  if (h < 19) return 'Selamat Sore';
  return 'Selamat Malam';
}

String _inisial(String nama) {
  final parts = nama.trim().split(' ').where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
  return parts[0][0].toUpperCase();
}

class BerandaPetugasPage extends StatefulWidget {
  const BerandaPetugasPage({super.key});

  @override
  State<BerandaPetugasPage> createState() => _BerandaPetugasPageState();
}

class _BerandaPetugasPageState extends State<BerandaPetugasPage>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  bool isLoading = true;
  String namaPetugas = '';

  int totalPengajuan        = 0;
  int totalPengaduan        = 0;
  int selesai               = 0;
  int belumVerifikasi       = 0;
  int pengaduanBaru         = 0;
  int diverifikasiHariIni   = 0;
  int pengaduanDitanggapi   = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.fetchNotifikasi();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        _api.getStatistikPetugas(),
        _api.getProfilPetugas(),
      ]);
      final statistik = results[0]['data'];
      final profil    = results[1]['data'];
      setState(() {
        namaPetugas         = profil['nama'] ?? 'Petugas';
        totalPengajuan      = statistik['total'] ?? 0;
        totalPengaduan      = statistik['total_pengaduan'] ?? 0;
        selesai             = statistik['selesai'] ?? 0;
        belumVerifikasi     = statistik['perlu_perhatian']?['belum_verifikasi'] ?? 0;
        pengaduanBaru       = statistik['perlu_perhatian']?['pengaduan_baru'] ?? 0;
        diverifikasiHariIni = statistik['ringkasan_hari_ini']?['diverifikasi'] ?? 0;
        pengaduanDitanggapi = statistik['ringkasan_hari_ini']?['pengaduan_ditanggapi'] ?? 0;
        isLoading           = false;
      });
      _animCtrl.forward(from: 0);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: kRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Beranda Petugas',
      showBack: false,
      actions: [
        NotificationBadgeIcon(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotifikasiPage()),
          ).then((_) => NotificationService.instance.refreshBadge()),
        ),
      ],
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : FadeTransition(
              opacity: _fadeIn,
              child: RefreshIndicator(
                color: kPrimary,
                backgroundColor: Colors.white,
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(),
                      const SizedBox(height: 24),
                      _sectionTitle('Statistik Tugas', Icons.bar_chart_rounded),
                      const SizedBox(height: 12),
                      _buildStatSection(),
                      const SizedBox(height: 24),
                      _sectionTitle('Perlu Perhatian', Icons.notifications_active_rounded),
                      const SizedBox(height: 12),
                      _buildPerluPerhatian(),
                      const SizedBox(height: 24),
                      _sectionTitle('Aktivitas Hari Ini', Icons.today_rounded),
                      const SizedBox(height: 12),
                      _buildAktivitasHariIni(),
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
    final days   = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final dateStr = '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';

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
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: kPrimary.withOpacity(0.2), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              namaPetugas.isEmpty ? '?' : _inisial(namaPetugas),
              style: const TextStyle(
                color: kPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sapaan(),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  namaPetugas.isEmpty ? 'Petugas' : namaPetugas,
                  style: const TextStyle(
                    color: Color(0xFF1B2433),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.badge_rounded, color: kPrimary, size: 11),
                          SizedBox(width: 4),
                          Text('Petugas',
                              style: TextStyle(
                                  color: kPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today_rounded, size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
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
        'value': totalPengajuan.toString(),
        'icon': Icons.assignment_rounded,
        'color': kPrimary,
        'bg': const Color(0xFFEFF6FF),
      },
      {
        'label': 'Total Pengaduan',
        'value': totalPengaduan.toString(),
        'icon': Icons.campaign_rounded,
        'color': kOrange,
        'bg': const Color(0xFFFFF7ED),
      },
      {
        'label': 'Selesai Diproses',
        'value': selesai.toString(),
        'icon': Icons.task_alt_rounded,
        'color': kGreen,
        'bg': const Color(0xFFF0FDF4),
      },
      {
        'label': 'Belum Verifikasi',
        'value': belumVerifikasi.toString(),
        'icon': Icons.pending_actions_rounded,
        'color': kRed,
        'bg': const Color(0xFFFEF2F2),
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

  // ─── PERLU PERHATIAN ────────────────────────────────────────────────────────
  Widget _buildPerluPerhatian() {
    final oke = belumVerifikasi == 0 && pengaduanBaru == 0;
    if (oke) {
      return _alertTile(
        icon: Icons.verified_rounded,
        title: 'Semua sudah tertangani!',
        subtitle: 'Tidak ada item yang perlu perhatian saat ini.',
        color: kGreen,
        bgColor: const Color(0xFFF0FDF4),
      );
    }
    return Column(
      children: [
        if (belumVerifikasi > 0)
          _alertTile(
            icon: Icons.folder_copy_rounded,
            title: '$belumVerifikasi berkas belum diverifikasi',
            subtitle: 'Segera tinjau dan verifikasi berkas masuk.',
            color: kOrange,
            bgColor: const Color(0xFFFFF7ED),
          ),
        if (belumVerifikasi > 0 && pengaduanBaru > 0) const SizedBox(height: 10),
        if (pengaduanBaru > 0)
          _alertTile(
            icon: Icons.mark_email_unread_rounded,
            title: '$pengaduanBaru pengaduan baru masuk',
            subtitle: 'Ada pengaduan warga yang belum ditanggapi.',
            color: kRed,
            bgColor: const Color(0xFFFEF2F2),
          ),
      ],
    );
  }

  Widget _alertTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: Color(0xFF1B2433))),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AKTIVITAS HARI INI ─────────────────────────────────────────────────────
  Widget _buildAktivitasHariIni() {
    final items = [
      {
        'label': 'Berkas\nDiverifikasi',
        'value': diverifikasiHariIni.toString(),
        'icon': Icons.verified_rounded,
        'color': kPrimary,
        'bg': const Color(0xFFEFF6FF),
      },
      {
        'label': 'Pengaduan\nDitanggapi',
        'value': pengaduanDitanggapi.toString(),
        'icon': Icons.forum_rounded,
        'color': kTeal,
        'bg': const Color(0xFFF0FDFA),
      },
    ];

    return Row(
      children: items.map((d) {
        final color   = d['color'] as Color;
        final bgColor = d['bg'] as Color;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: d == items.first ? 5 : 0,
              left: d == items.last ? 5 : 0,
            ),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(d['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['value'] as String,
                        style: TextStyle(
                          fontSize: 26,
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
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}