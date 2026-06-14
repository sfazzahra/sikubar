import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menucamat.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/notification_badge.dart';
import '../../notifications/notifikasi_page.dart';


class MonitoringPengajuanCamatPage extends StatefulWidget {
  const MonitoringPengajuanCamatPage({super.key});

  @override
  State<MonitoringPengajuanCamatPage> createState() =>
      _MonitoringPengajuanCamatPageState();
}

class _MonitoringPengajuanCamatPageState
    extends State<MonitoringPengajuanCamatPage>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();

  late TabController _tabController;
  bool isLoading = true;
  List allData = [];

  // Filter tabs sesuai status alur
  static const _tabs = ['Semua', 'Diproses', 'Disetujui', 'Ditolak', 'Selesai'];

@override
void initState() {
  super.initState();

  _tabController = TabController(
    length: _tabs.length,
    vsync: this,
  );

  _tabController.addListener(() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  });

  _loadData();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.fetchNotifikasi();
  });
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final tab = _tabs[_tabController.index];
    if (tab == 'Semua') return allData;
    return allData
        .where((e) =>
            (e['status'] ?? '').toString().toLowerCase() ==
            tab.toLowerCase())
        .toList();
  }

  // ─────────────────────────────────────────
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
          child: Column(
            children: [
              _buildHeader(),
              _buildSummaryRow(),
              _buildTabBar(),
              const SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: _filtered.isEmpty
                            ? _emptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                                itemCount: _filtered.length,
                                itemBuilder: (_, i) =>
                                    _buildCard(_filtered[i]),
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomMenuCamat(currentIndex: 2),
    );
  }

  // ─── HEADER ───────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.assignment_outlined,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monitoring Pengajuan',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Pantau status pengajuan warga',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const Spacer(),

NotificationBadgeIcon(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const NotifikasiPage(),
    ),
  ).then(
    (_) => NotificationService.instance.refreshBadge(),
  ),
),
        ],
      ),
    );
  }

  // ─── SUMMARY STAT CHIPS ───────────────────
  Widget _buildSummaryRow() {
    if (allData.isEmpty) return const SizedBox.shrink();

    Map<String, int> counts = {};
    for (final item in allData) {
      final s = (item['status'] ?? 'lainnya').toString().toLowerCase();
      counts[s] = (counts[s] ?? 0) + 1;
    }

    final chips = [
      ('Total', allData.length, Colors.white),
      ('Disetujui', counts['disetujui'] ?? 0, Colors.greenAccent),
      ('Ditolak', counts['ditolak'] ?? 0, Colors.redAccent),
      ('Selesai', counts['selesai'] ?? 0, Colors.lightBlueAccent),
    ];

    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        children: chips
            .map((c) => _statChip(c.$1, c.$2, c.$3))
            .toList(),
      ),
    );
  }

  Widget _statChip(String label, int val, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$val',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  // ─── TAB BAR ──────────────────────────────
  Widget _buildTabBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        labelColor: const Color(0xFF1A73E8),
        unselectedLabelColor: Colors.white,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  // ─── CARD ─────────────────────────────────
  Widget _buildCard(Map item) {
    final status = (item['status'] ?? '-').toString();
    final hasSurat = item['surat_url'] != null &&
        item['surat_url'].toString().isNotEmpty;

    return GestureDetector(
      onTap: () => _showDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            // ─ top strip warna status
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _statusColor(status),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar inisial
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            _statusColor(status).withOpacity(0.15),
                        child: Text(
                          _inisial(item['user']?['nama'] ?? 'W'),
                          style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['user']?['nama'] ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            Text(
                              item['nomor_pengajuan'] ?? '-',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      _statusBadge(status),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.description_outlined,
                          size: 15, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item['jenis_surat']?['nama'] ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        item['created_at'] ?? '-',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                      const Spacer(),
                      if (hasSurat) ...[
                        const Icon(Icons.picture_as_pdf,
                            size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        const Text('Surat tersedia',
                            style: TextStyle(
                                fontSize: 11, color: Colors.green)),
                      ],
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

  // ─── DETAIL BOTTOM SHEET ──────────────────
  void _showDetail(Map item) {
    final status = (item['status'] ?? '-').toString();
    final berkas = List.from(item['berkas'] ?? []);
    final suratUrl = item['surat_url']?.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
              ),

              // Header sheet
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1A73E8)),
                    const SizedBox(width: 8),
                    const Text('Detail Pengajuan',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    _statusBadge(status),
                  ],
                ),
              ),

              const Divider(height: 24),

              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _detailRow('Nomor', item['nomor_pengajuan']),
                    _detailRow('Nama Warga', item['user']?['nama']),
                    _detailRow('Jenis Surat', item['jenis_surat']?['nama']),
                    _detailRow('Tanggal Pengajuan', item['created_at']),
                    if (item['catatan'] != null && item['catatan'] != '')
                      _detailRow('Catatan Petugas', item['catatan']),
                    if (item['alasan_penolakan'] != null &&
                        item['alasan_penolakan'] != '')
                      _detailRow('Alasan Penolakan', item['alasan_penolakan'],
                          isRed: true),

                    const SizedBox(height: 16),

                    // Berkas persyaratan
                    if (berkas.isNotEmpty) ...[
                      const Text('Berkas Persyaratan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      ...berkas.map((b) => _berkasItem(b)),
                      const SizedBox(height: 16),
                    ],

                    // Surat jadi
                    if (suratUrl != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified,
                                color: Colors.green.shade700),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Surat telah diupload oleh petugas',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.open_in_new,
                              color: Colors.green),
                          label: const Text('Lihat Surat',
                              style: TextStyle(color: Colors.green)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _openUrl(suratUrl),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────
  Widget _detailRow(String label, String? value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 3),
          Text(value ?? '-',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isRed ? Colors.red : Colors.black87)),
        ],
      ),
    );
  }

  Widget _berkasItem(Map b) {
    return GestureDetector(
      onTap: b['url'] != null ? () => _openUrl(b['url']) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(b['nama_berkas'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _capitalize(status),
        style: TextStyle(
            color: _statusColor(status),
            fontWeight: FontWeight.bold,
            fontSize: 11),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      children: const [
        SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 60, color: Colors.white54),
              SizedBox(height: 12),
              Text('Tidak ada data pengajuan',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'diproses':
      case 'menunggu':
        return Colors.orange;
      case 'diverifikasi':
        return const Color(0xFF1A73E8);
      default:
        return Colors.grey;
    }
  }

  String _inisial(String nama) {
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) return parts[0][0] + parts[1][0];
    return parts[0].isNotEmpty ? parts[0][0] : '?';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }
}