import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

String _inisialKasi(String nama) {
  final parts = nama.trim().split(' ').where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
  return parts[0][0].toUpperCase();
}

class BerandaKasiPage extends StatefulWidget {
  const BerandaKasiPage({super.key});

  @override
  State<BerandaKasiPage> createState() => _BerandaKasiPageState();
}

class _BerandaKasiPageState extends State<BerandaKasiPage>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  bool isLoading = true;
  String nama = '';
  int menunggu    = 0;
  int disetujui   = 0;
  int ditolak     = 0;
  int total       = 0;
  List<Map<String, dynamic>> suratSelesai = [];

  // Data perlu perhatian (opsional: bisa dari API atau dihitung dari list)
  int menungguTinjau = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
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
        _api.getProfilKasi(),
        _api.getPengajuanKasi(),
      ]);
      final profil       = results[0];
      final pengajuanRes = results[1];
      final List<dynamic> list = pengajuanRes['data'] ?? [];
      int mng = 0, dis = 0, dtl = 0;
      List<Map<String, dynamic>> surat = [];
      for (final item in list) {
        final status = item['status'] ?? '';
        if (status == 'menunggu_kasi') mng++;
        if (status == 'disetujui_kasi') dis++;
        if (status == 'ditolak') dtl++;
        if (status == 'selesai' && item['surat_path'] != null) {
          surat.add(Map<String, dynamic>.from(item));
        }
      }
      setState(() {
        nama           = profil['data']?['nama'] ?? profil['nama'] ?? 'Kepala Seksi';
        menunggu       = mng;
        menungguTinjau = mng;
        disetujui      = dis;
        ditolak        = dtl;
        total          = list.length;
        suratSelesai   = surat;
        isLoading      = false;
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

  Future<void> _bukaUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak bisa membuka surat'),
              backgroundColor: kRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Beranda Kasi',
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
                      _sectionTitle('Ringkasan Pengajuan', Icons.bar_chart_rounded),
                      const SizedBox(height: 12),
                      _buildStatSection(),
                      const SizedBox(height: 24),
                      _sectionTitle('Perlu Perhatian', Icons.notifications_active_rounded),
                      const SizedBox(height: 12),
                      _buildPerluPerhatian(),
                      const SizedBox(height: 24),
                      _sectionTitle('Surat Selesai', Icons.description_rounded),
                      const SizedBox(height: 12),
                      _buildDaftarSurat(),
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
    final days    = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    final months  = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
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
              color: const Color(0xFFF0FDFA),
              shape: BoxShape.circle,
              border: Border.all(color: kTeal.withOpacity(0.2), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              nama.isEmpty ? '?' : _inisialKasi(nama),
              style: const TextStyle(
                color: kTeal,
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
                  greeting,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  nama.isEmpty ? 'Kepala Seksi' : nama,
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
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.admin_panel_settings_rounded, color: kTeal, size: 11),
                          SizedBox(width: 4),
                          Text('Kepala Seksi',
                              style: TextStyle(color: kTeal, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today_rounded, size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
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
        'label': 'Menunggu Tinjau',
        'value': menunggu.toString(),
        'icon': Icons.pending_actions_rounded,
        'color': kOrange,
        'bg': const Color(0xFFFFF7ED),
      },
      {
        'label': 'Disetujui',
        'value': disetujui.toString(),
        'icon': Icons.check_circle_rounded,
        'color': kGreen,
        'bg': const Color(0xFFF0FDF4),
      },
      {
        'label': 'Ditolak',
        'value': ditolak.toString(),
        'icon': Icons.cancel_rounded,
        'color': kRed,
        'bg': const Color(0xFFFEF2F2),
      },
      {
        'label': 'Total Pengajuan',
        'value': total.toString(),
        'icon': Icons.assignment_rounded,
        'color': kPrimary,
        'bg': const Color(0xFFEFF6FF),
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
    if (menungguTinjau == 0) {
      return _alertTile(
        icon: Icons.verified_rounded,
        title: 'Semua pengajuan sudah ditinjau!',
        subtitle: 'Tidak ada berkas yang menunggu persetujuan saat ini.',
        color: kGreen,
        bgColor: const Color(0xFFF0FDF4),
      );
    }
    return _alertTile(
      icon: Icons.folder_copy_rounded,
      title: '$menungguTinjau pengajuan menunggu ditinjau',
      subtitle: 'Segera tinjau dan berikan keputusan persetujuan.',
      color: kOrange,
      bgColor: const Color(0xFFFFF7ED),
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

  // ─── DAFTAR SURAT SELESAI ───────────────────────────────────────────────────
  Widget _buildDaftarSurat() {
    if (suratSelesai.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
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
        child: const Column(
          children: [
            Icon(Icons.inbox_rounded, size: 36, color: Color(0xFFCBD5E1)),
            SizedBox(height: 10),
            Text('Belum ada surat selesai',
                style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text('Surat yang sudah selesai diproses akan muncul di sini.',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return Column(
      children: suratSelesai.map((item) => _buildSuratCard(item)).toList(),
    );
  }

  Widget _buildSuratCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: kTeal, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['warga']?['nama'] ?? '-',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1B2433))),
                const SizedBox(height: 2),
                Text(item['jenis_surat']?['nama'] ?? '-',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const SizedBox(height: 2),
                Text(item['nomor_pengajuan'] ?? '-',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFB0BEC5))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _bukaUrl(item['surat_path']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new_rounded, color: kTeal, size: 13),
                  SizedBox(width: 4),
                  Text('Buka',
                      style: TextStyle(
                          color: kTeal, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}