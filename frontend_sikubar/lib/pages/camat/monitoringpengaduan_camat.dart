import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menucamat.dart';
import '../../widgets/app_scaffold.dart';

// ─── Design tokens (disamakan dengan PengaduanPetugasPage) ───
const Color kPrimary = Color(0xFF2F80ED);
const Color kPrimaryDark = Color(0xFF1B5FC4);
const Color kGreen = Color(0xFF10B981);
const Color kOrange = Color(0xFFF59E0B);
const Color kGrey = Color(0xFF94A3B8);

class MonitoringPengaduanCamatPage extends StatefulWidget {
  const MonitoringPengaduanCamatPage({super.key});

  @override
  State<MonitoringPengaduanCamatPage> createState() =>
      _MonitoringPengaduanCamatPageState();
}

class _MonitoringPengaduanCamatPageState
    extends State<MonitoringPengaduanCamatPage> {
  final ApiService _api = ApiService();

  bool isLoading = true;
  List allData = [];
  String selectedTab = 'Diproses';

  static const List<String> _tabs = ['Diproses', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getCamatPengaduan();
      setState(() {
        allData = res['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─── Filter berdasarkan field 'status' mentah dari API.
  // Tab 'Diproses' menampilkan semua status selain 'selesai'.
  // Tab 'Selesai' menampilkan status 'selesai' saja.
  List get _filtered {
    if (selectedTab == 'Diproses') {
      return allData.where((e) {
        final status = (e['status'] ?? '').toString().toLowerCase().trim();
        return status != 'selesai';
      }).toList();
    }
    return allData.where((e) {
      final status = (e['status'] ?? '').toString().toLowerCase().trim();
      return status == 'selesai';
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'menunggu':
        return kOrange;
      case 'selesai':
        return kGreen;
      default:
        return kGrey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase().trim()) {
      case 'menunggu':
        return Icons.schedule_rounded;
      case 'selesai':
        return Icons.task_alt_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  IconData _getTabIcon(String tab) {
    return tab == 'Diproses'
        ? Icons.hourglass_top_rounded
        : Icons.task_alt_rounded;
  }

  // ─── Helper: cek apakah file adalah gambar berdasarkan ekstensi URL
  bool _isGambar(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.png') ||
        u.endsWith('.webp');
  }

  /// Bangun URL bukti dengan aman (disamakan dengan PengaduanPetugasPage):
  /// - Jika backend sudah mengembalikan URL lengkap (http/https), pakai langsung.
  /// - Jika hanya path relatif, gabungkan dengan storageBaseUrl dari ApiService.
  /// - Membersihkan prefix 'storage/' ganda jika sudah ada di path mentah.
  String _buildBuktiUrl(String rawPath) {
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return rawPath;
    }
    final cleanPath = rawPath.startsWith('storage/')
        ? rawPath.substring('storage/'.length)
        : rawPath;
    return '${ApiService.storageBaseUrl}/storage/$cleanPath';
  }

  // ─── Helper: preview gambar fullscreen dengan pinch-zoom
  void _bukaPreviewGambar(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Colors.white54, size: 36),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper: buka dokumen non-gambar (PDF) lewat aplikasi eksternal
  void _bukaDokumen(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka dokumen: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Buka tab baru di web (disamakan dengan PengaduanPetugasPage) ─────
  void _bukaTabBaru(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  // ─── Web: hanya tombol buka tab baru, tanpa thumbnail ─────────────────
  Widget _buildBuktiWeb(String url) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _bukaTabBaru(url),
        icon: const Icon(Icons.open_in_new_rounded, size: 16),
        label: const Text("Lihat Gambar di Tab Baru"),
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  // ─── Mobile: thumbnail tap fullscreen ─────────────────────────────────
  Widget _buildImageThumbnail(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (ctx2, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.4)),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: 120,
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image_outlined,
                    color: Colors.grey.shade400, size: 28),
                const SizedBox(height: 6),
                Text("Gagal memuat gambar",
                    style:
                        TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Tile dokumen non-gambar ───────────────────────────────────────────
  Widget _buildDocTile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_outlined,
                color: Colors.red, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text("Lihat dokumen bukti",
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
          ),
          Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Monitoring Pengaduan',
      showBack: false,
      bottomNavigationBar: const BottomMenuCamat(currentIndex: 3),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.22)),
              ),
              child: Row(
                children:
                    _tabs.map((t) => Expanded(child: _buildTab(t))).toList(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: isLoading
                  ? _buildLoadingState()
                  : _filtered.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          key: ValueKey('list-$selectedTab'),
                          color: kPrimary,
                          backgroundColor: Colors.white,
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 10, 16, 24),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _buildCard(_filtered[i]),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    final active = selectedTab == text;
    final icon = _getTabIcon(text);

    return GestureDetector(
      onTap: () => setState(() => selectedTab = text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [kPrimary, kPrimaryDark])
              : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14,
                  color: active
                      ? Colors.white
                      : Colors.white.withOpacity(0.85)),
              const SizedBox(width: 6),
              Text(
                text.toUpperCase(),
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      key: ValueKey('loading'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child:
                CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ),
          SizedBox(height: 16),
          Text('Memuat pengaduan...',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forum_outlined, size: 38, color: Colors.white),
          ),
          const SizedBox(height: 18),
          const Text("Tidak ada pengaduan",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5)),
          const SizedBox(height: 6),
          Text("Pengaduan dengan status ini\nakan muncul di sini",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _buildCard(Map item) {
    final status = (item['status'] ?? '-').toString();
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    final hasBalasan =
        item['balasan'] != null && item['balasan'].toString().trim().isNotEmpty;

    return GestureDetector(
      onTap: () => _showDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [color.withOpacity(0.55), color]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.85), color],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.campaign_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['nama'] ?? '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(item['judul'] ?? item['kategori'] ?? '-',
                                style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      item['isi'] ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.5, color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 13, color: color),
                            const SizedBox(width: 6),
                            Text(status.toUpperCase(),
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasBalasan
                              ? kGreen.withOpacity(0.08)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: hasBalasan
                                ? kGreen.withOpacity(0.3)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasBalasan
                                  ? Icons.mark_chat_read_outlined
                                  : Icons.mark_chat_unread_outlined,
                              size: 13,
                              color: hasBalasan ? kGreen : Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasBalasan ? 'Sudah Ditanggapi' : 'Belum Ditanggapi',
                              style: TextStyle(
                                color: hasBalasan ? kGreen : Colors.grey.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.event_outlined,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(item['tanggal'] ?? '-',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Detail (read-only) — camat hanya boleh melihat, tidak ada form
  // tanggapan maupun tombol kirim. Bukti pendukung dari warga tetap
  // ditampilkan supaya camat bisa melihat lampiran apa adanya.
  void _showDetail(Map item) {
    final status = (item['status'] ?? '-').toString();
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    final hasBalasan =
        item['balasan'] != null && item['balasan'].toString().trim().isNotEmpty;

    // ── Bangun URL bukti dengan aman (urutan field disamakan dengan
    // PengaduanPetugasPage: bukti_path → bukti_url, file_bukti sebagai
    // fallback tambahan jika backend camat masih mengirim key lama) ──
    final buktiRaw =
        (item['bukti_path'] ?? item['bukti_url'] ?? item['file_bukti'] ?? '')
            .toString()
            .trim();
    final buktiUrl = buktiRaw.isEmpty ? '' : _buildBuktiUrl(buktiRaw);
    final hasBukti = buktiUrl.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 14,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ─── Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color.withOpacity(0.85), color],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.campaign_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Detail Pengaduan",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(item['judul'] ?? item['kategori'] ?? '-',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded,
                                size: 18, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ─── Status banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text("Status: ${status.toUpperCase()}",
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ─── Info grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statTile("Nama Pelapor", item['nama'] ?? '-'),
                        const SizedBox(width: 10),
                        _statTile("Tanggal", item['tanggal'] ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _statTileFull("Judul", item['judul'] ?? item['kategori'] ?? '-'),
                    const SizedBox(height: 18),

                    // ─── Isi pengaduan
                    const Text("Isi Pengaduan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14.5)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(item['isi'] ?? '-',
                          style: const TextStyle(fontSize: 13.5, height: 1.5)),
                    ),

                    // ─── Bukti Pendukung dari warga (jika ada) ─────────────
                    // Disamakan dengan PengaduanPetugasPage: di web hanya
                    // tampil tombol "buka di tab baru", di mobile tampil
                    // thumbnail yang bisa di-tap untuk preview fullscreen.
                    if (hasBukti) ...[
                      const SizedBox(height: 18),
                      const Text("Bukti Pendukung",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14.5)),
                      const SizedBox(height: 10),
                      if (_isGambar(buktiUrl))
                        kIsWeb
                            ? _buildBuktiWeb(buktiUrl)
                            : GestureDetector(
                                onTap: () =>
                                    _bukaPreviewGambar(context, buktiUrl),
                                child: _buildImageThumbnail(buktiUrl),
                              )
                      else
                        InkWell(
                          onTap: () => _bukaDokumen(context, buktiUrl),
                          borderRadius: BorderRadius.circular(16),
                          child: _buildDocTile(),
                        ),
                    ],

                    // ─── Tanggapan petugas (read-only, tanpa form input)
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(
                          hasBalasan
                              ? Icons.mark_chat_read_outlined
                              : Icons.mark_chat_unread_outlined,
                          size: 16,
                          color: hasBalasan ? kGreen : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        const Text('Tanggapan Petugas',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (hasBalasan)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kGreen.withOpacity(0.25)),
                        ),
                        child: Text(item['balasan'] ?? '-',
                            style: const TextStyle(
                                fontSize: 13, height: 1.5, color: Colors.black87)),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kOrange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kOrange.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_top_rounded,
                                color: kOrange, size: 18),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Pengaduan belum mendapat tanggapan dari petugas',
                                style: TextStyle(color: kOrange, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _statTileFull(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}