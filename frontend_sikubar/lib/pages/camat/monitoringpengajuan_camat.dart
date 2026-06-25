import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menucamat.dart';
import '../../widgets/app_scaffold.dart';
// ─── Design tokens (disamakan dengan VerifikasiPetugasPage) ───
const Color kPrimary = Color(0xFF2F80ED);
const Color kPrimaryDark = Color(0xFF1B5FC4);
const Color kAccent = Color(0xFF7C3AED);

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'disetujui':
    case 'selesai':
      return const Color(0xFF10B981);
    case 'ditolak':
      return const Color(0xFFEF4444);
    case 'diproses':
    case 'menunggu':
      return const Color(0xFFF59E0B);
    case 'diverifikasi':
      return kPrimary;
    default:
      return const Color(0xFF94A3B8);
  }
}

IconData statusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'disetujui':
      return Icons.verified_rounded;
    case 'selesai':
      return Icons.task_alt_rounded;
    case 'ditolak':
      return Icons.cancel_rounded;
    case 'diproses':
    case 'menunggu':
      return Icons.schedule_rounded;
    case 'diverifikasi':
      return Icons.fact_check_rounded;
    default:
      return Icons.description_rounded;
  }
}

class MonitoringPengajuanCamatPage extends StatefulWidget {
  const MonitoringPengajuanCamatPage({super.key});

  @override
  State<MonitoringPengajuanCamatPage> createState() =>
      _MonitoringPengajuanCamatPageState();
}

class _MonitoringPengajuanCamatPageState
    extends State<MonitoringPengajuanCamatPage> {
  final ApiService _api = ApiService();

  bool isLoading = true;
  List allData = [];
  String selectedTab = 'Semua';

  static const List<String> _tabs = [
    'Semua',
    'diproses',
    'disetujui',
    'ditolak',
    'selesai',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getCamatPengajuan();
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

  List get _filtered {
    if (selectedTab == 'Semua') return allData;
    return allData
        .where((e) =>
            (e['status'] ?? '').toString().toLowerCase() == selectedTab)
        .toList();
  }

  String _labelTab(String key) {
    switch (key) {
      case 'Semua':
        return 'SEMUA';
      case 'diproses':
        return 'DIPROSES';
      case 'disetujui':
        return 'DISETUJUI';
      case 'ditolak':
        return 'DITOLAK';
      case 'selesai':
        return 'SELESAI';
      default:
        return key.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Monitoring Pengajuan',
      showBack: false,
      actions: [],
      bottomNavigationBar: const BottomMenuCamat(currentIndex: 2),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _tabs.map(_buildTab).toList(),
                  ),
                ),
              ),
            ),
          ),
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
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
    final icon = text == 'Semua' ? Icons.apps_rounded : statusIcon(text);

    return GestureDetector(
      onTap: () => setState(() => selectedTab = text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [kPrimary, kPrimaryDark])
              : null,
          borderRadius: BorderRadius.circular(20),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: active ? Colors.white : Colors.white.withOpacity(0.85)),
            const SizedBox(width: 6),
            Text(
              _labelTab(text),
              style: TextStyle(
                color: active ? Colors.white : Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
          ],
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
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ),
          SizedBox(height: 16),
          Text('Memuat pengajuan...',
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
            child: const Icon(Icons.inbox_outlined, size: 38, color: Colors.white),
          ),
          const SizedBox(height: 18),
          const Text("Tidak ada data pengajuan",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.5)),
        ],
      ),
    );
  }

  Widget _buildCard(Map item) {
    final status = (item['status'] ?? '-').toString().toLowerCase();
    final color = statusColor(status);
    final icon = statusIcon(status);
    final hasSurat =
        item['surat_url'] != null && item['surat_url'].toString().isNotEmpty;

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
                gradient: LinearGradient(colors: [color.withOpacity(0.55), color]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['user']?['nama'] ?? '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(item['jenis_surat']?['nama'] ?? '-',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12.5),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(item['nomor_pengajuan'] ?? '-',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.event_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(item['created_at'] ?? '-',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 13, color: color),
                            const SizedBox(width: 6),
                            Text(_labelTab(status),
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (hasSurat)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: kAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.picture_as_pdf_rounded, size: 13, color: kAccent),
                              const SizedBox(width: 4),
                              const Text('Surat tersedia',
                                  style: TextStyle(
                                      color: kAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
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

  void _showDetail(Map item) {
    final status = (item['status'] ?? '-').toString().toLowerCase();
    final berkas = List.from(item['berkas'] ?? []);
    final suratUrl = item['surat_url']?.toString();
    final color = statusColor(status);
    final icon = statusIcon(status);

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
                          child: Icon(icon, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Detail Pengajuan",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(item['nomor_pengajuan'] ?? '-',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12.5)),
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
                            child: Text("Status: ${_labelTab(status)}",
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statTile("Nama Warga", item['user']?['nama'] ?? '-'),
                        const SizedBox(width: 10),
                        _statTile(
                            "Jenis Surat", item['jenis_surat']?['nama'] ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statTile("Tanggal", item['created_at'] ?? '-'),
                        const SizedBox(width: 10),
                        _statTile("Nomor", item['nomor_pengajuan'] ?? '-'),
                      ],
                    ),

                    if (item['catatan'] != null &&
                        item['catatan'].toString().isNotEmpty)
                      _calloutCard(
                        icon: Icons.sticky_note_2_outlined,
                        color: kPrimary,
                        label: "Catatan Petugas",
                        text: item['catatan'].toString(),
                      ),

                    if (item['alasan_penolakan'] != null &&
                        item['alasan_penolakan'].toString().isNotEmpty)
                      _calloutCard(
                        icon: Icons.error_outline_rounded,
                        color: const Color(0xFFEF4444),
                        label: "Alasan Penolakan",
                        text: item['alasan_penolakan'].toString(),
                      ),

                    const SizedBox(height: 22),

                    if (berkas.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text("Berkas Persyaratan",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14.5)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text("${berkas.length} file",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...berkas.map((b) {
                        final fileUrl = b['url'];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap:
                                  fileUrl != null ? () => _openUrl(fileUrl) : null,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.picture_as_pdf_rounded,
                                          color: Colors.red.shade600, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            b['nama_berkas'] ?? '-',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5),
                                          ),
                                          const SizedBox(height: 3),
                                          Text('Ketuk untuk membuka berkas',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: kPrimary
                                                      .withOpacity(0.85))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: kPrimary.withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.open_in_new_rounded,
                                          size: 16,
                                          color: kPrimary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],

                    if (suratUrl != null && suratUrl.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade50,
                              Colors.green.shade50.withOpacity(0.4)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.task_alt_rounded,
                                      color: Colors.green.shade600, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                      "Surat telah diupload oleh petugas",
                                      style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: _pillButton(
                                label: "Lihat Surat",
                                icon: Icons.open_in_new_rounded,
                                color: const Color(0xFF10B981),
                                onTap: () => _openUrl(suratUrl),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

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
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _calloutCard({
    required IconData icon,
    required Color color,
    required String label,
    required String text,
    double topMargin = 14,
  }) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 3),
                Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.32),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}