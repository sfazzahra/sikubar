import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/bottom_menuwarga.dart';
import '../../../widgets/app_scaffold.dart';
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

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  
  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.fetchNotifikasi();
  });
}

  static Future<void> _bukaMaps(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat membuka Google Maps');
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
  title: 'Kecamatan Kundur Barat',
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
  bottomNavigationBar: const BottomMenu(currentIndex: 0),
  body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _banner(),
            const SizedBox(height: 16),
            _quickStats(),
            const SizedBox(height: 24),
            _sectionTitle('Tentang Kecamatan', Icons.info_rounded),
            const SizedBox(height: 12),
            _deskripsiKecamatan(),
            const SizedBox(height: 24),
            _sectionTitle('Data Kecamatan', Icons.bar_chart_rounded),
            const SizedBox(height: 12),
            _statistikGrid(),
            const SizedBox(height: 24),
            _sectionTitle('Wilayah Kecamatan', Icons.map_rounded),
            const SizedBox(height: 12),
            _wilayahList(),
            const SizedBox(height: 24),
            _sectionTitle('Jam Pelayanan', Icons.access_time_rounded),
            const SizedBox(height: 12),
            _jadwalPelayanan(),
            const SizedBox(height: 24),
            _sectionTitle('Hubungi Kami', Icons.contact_phone_rounded),
            const SizedBox(height: 12),
            _kontakCard(),
          ],
        ),
      ),
    );
  }

  // ─── SECTION TITLE ──────────────────────────────────────────────────────────
  static Widget _sectionTitle(String title, IconData icon) {
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

  // ─── BANNER ─────────────────────────────────────────────────────────────────
  static Widget _banner() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/kantorcamatkuba.jpeg', fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kantor Kecamatan Kundur Barat',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kabupaten Karimun, Kepulauan Riau',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── QUICK STATS ────────────────────────────────────────────────────────────
  static Widget _quickStats() {
    return Row(
      children: [
        _quickStatItem('19.405', 'Penduduk', Icons.people_alt_rounded,
            kPrimary, const Color(0xFFEFF6FF)),
        const SizedBox(width: 10),
        _quickStatItem('5', 'Wilayah', Icons.map_rounded,
            kTeal, const Color(0xFFF0FDFA)),
        const SizedBox(width: 10),
        _quickStatItem('271,51', 'Km²', Icons.terrain_rounded,
            kOrange, const Color(0xFFFFF7ED)),
      ],
    );
  }

  static Widget _quickStatItem(
      String value, String label, IconData icon, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  // ─── DESKRIPSI ──────────────────────────────────────────────────────────────
  static Widget _deskripsiKecamatan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'Kecamatan Kundur Barat merupakan salah satu kecamatan di Kabupaten Karimun yang terbentuk dari pemekaran Kecamatan Kundur berdasarkan Undang-Undang Nomor 53 Tahun 1999. Kecamatan ini terdiri dari 1 kelurahan dan 4 desa dengan luas wilayah sekitar 271,51 km².',
        textAlign: TextAlign.justify,
        style: TextStyle(
          height: 1.65,
          fontSize: 13,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  // ─── STATISTIK GRID ─────────────────────────────────────────────────────────
  static Widget _statistikGrid() {
    final items = [
      {'icon': Icons.people_rounded,      'value': '19.405', 'label': 'Total Penduduk', 'color': kPrimary, 'bg': const Color(0xFFEFF6FF)},
      {'icon': Icons.location_city_rounded,'value': '1',      'label': 'Kelurahan',      'color': kPurple,  'bg': const Color(0xFFF5F3FF)},
      {'icon': Icons.holiday_village_rounded,'value':'4',     'label': 'Desa',           'color': kTeal,    'bg': const Color(0xFFF0FDFA)},
      {'icon': Icons.grid_view_rounded,   'value': '44',     'label': 'Total RW',        'color': kOrange,  'bg': const Color(0xFFFFF7ED)},
      {'icon': Icons.grid_3x3_rounded,    'value': '111',    'label': 'Total RT',        'color': kRed,     'bg': const Color(0xFFFEF2F2)},
      {'icon': Icons.terrain_rounded,     'value': '271,51', 'label': 'Luas (Km²)',      'color': kGreen,   'bg': const Color(0xFFF0FDF4)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item  = items[i];
        final color = item['color'] as Color;
        final bg    = item['bg'] as Color;
        final icon  = item['icon'] as IconData;
        return Container(
          padding: const EdgeInsets.all(12),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration:
                    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(item['value'] as String,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(item['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  maxLines: 2),
            ],
          ),
        );
      },
    );
  }

  // ─── WILAYAH LIST ───────────────────────────────────────────────────────────
  static Widget _wilayahList() {
    final List<Map<String, String>> desa = [
      {
        'nama': 'Kelurahan Sawang',
        'tipe': 'Kelurahan',
        'maps': 'https://www.google.com/maps/search/?api=1&query=0.7356319825097459,103.3663654820449',
      },
      {
        'nama': 'Desa Sawang Laut',
        'tipe': 'Desa',
        'maps': 'https://www.google.com/maps/search/?api=1&query=0.7867482887624505,103.35494699406387',
      },
      {
        'nama': 'Desa Kundur',
        'tipe': 'Desa',
        'maps': 'https://www.google.com/maps/search/?api=1&query=0.8360522314943809,103.37720049406374',
      },
      {
        'nama': 'Desa Sawang Selatan',
        'tipe': 'Desa',
        'maps': 'https://www.google.com/maps/search/?api=1&query=0.7323572025467546,103.39925038242122',
      },
      {
        'nama': 'Desa Gemuruh',
        'tipe': 'Desa',
        'maps': 'https://www.google.com/maps/search/?api=1&query=0.8816802780603981,103.379782767474',
      },
    ];

    return Column(
      children: desa.map((item) {
        final isKelurahan = item['tipe'] == 'Kelurahan';
        final color  = isKelurahan ? kPrimary : kTeal;
        final bgColor = isKelurahan ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDFA);
        return GestureDetector(
          onTap: () => _bukaMaps(item['maps']!),
          child: Container(
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: bgColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.location_on_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['nama']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF1B2433))),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: bgColor, borderRadius: BorderRadius.circular(20)),
                        child: Text(item['tipe']!,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.map_rounded, color: Colors.grey.shade400, size: 14),
                    const SizedBox(width: 4),
                    const Text('Buka Maps',
                        style: TextStyle(
                            fontSize: 11, color: kPrimary, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 2),
                    const Icon(Icons.open_in_new_rounded, color: kPrimary, size: 12),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── JADWAL PELAYANAN ───────────────────────────────────────────────────────
  static Widget _jadwalPelayanan() {
    final jadwal = [
      {'hari': 'Senin – Kamis', 'jam': '08.00 – 14.00', 'buka': true},
      {'hari': 'Jumat',         'jam': '08.00 – 11.30', 'buka': true},
      {'hari': 'Sabtu – Minggu','jam': 'Tutup',          'buka': false},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: jadwal.map((item) {
          final buka = item['buka'] as bool;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: buka ? kGreen : kRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item['hari'] as String,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1B2433),
                          fontWeight: FontWeight.w500)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: buka ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(item['jam'] as String,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: buka ? kGreen : kRed)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── KONTAK ─────────────────────────────────────────────────────────────────
  static Widget _kontakCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _kontakItem(
            Icons.location_on_rounded,
            'Alamat',
            'Jl. Kartini, Sawang, Kec. Kundur Barat, Kab. Karimun',
            kPrimary,
            const Color(0xFFEFF6FF),
          ),
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          _kontakItem(
            Icons.phone_rounded,
            'Telepon',
            '(0777) 123456',
            kGreen,
            const Color(0xFFF0FDF4),
          ),
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          _kontakItem(
            Icons.access_time_rounded,
            'Jam Operasional',
            'Senin – Jumat, 08.00 – 14.00 WIB',
            kOrange,
            const Color(0xFFFFF7ED),
          ),
        ],
      ),
    );
  }

  static Widget _kontakItem(
      IconData icon, String label, String value, Color color, Color bgColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration:
              BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1B2433),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}