import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menucamat.dart';

class MonitoringPengaduanCamatPage extends StatefulWidget {
  const MonitoringPengaduanCamatPage({super.key});

  @override
  State<MonitoringPengaduanCamatPage> createState() =>
      _MonitoringPengaduanCamatPageState();
}

class _MonitoringPengaduanCamatPageState
    extends State<MonitoringPengaduanCamatPage>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();

  late TabController _tabController;
  bool isLoading = true;
  List allData = [];

  static const _tabs = ['Diproses', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  List get _filtered {
  final tab = _tabs[_tabController.index];

  if (tab == 'Diproses') {
    return allData.where((e) {
      final balasan = (e['balasan'] ?? '').toString().trim();
      return balasan.isEmpty;
    }).toList();
  }

  if (tab == 'Selesai') {
    return allData.where((e) {
      final balasan = (e['balasan'] ?? '').toString().trim();
      return balasan.isNotEmpty;
    }).toList();
  }

  return allData;
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
                        child:
                            CircularProgressIndicator(color: Colors.white))
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: _filtered.isEmpty
                            ? _emptyState()
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
      bottomNavigationBar: const BottomMenuCamat(currentIndex: 3),
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
            child: const Icon(Icons.campaign_outlined,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monitoring Pengaduan',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Pantau pengaduan & balasan petugas',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SUMMARY ─────────────────────────────
  Widget _buildSummaryRow() {
    if (allData.isEmpty) return const SizedBox.shrink();

    final total = allData.length;

final diproses = allData.where((e) {
  final balasan = (e['balasan'] ?? '').toString().trim();
  return balasan.isEmpty;
}).length;

final selesai = allData.where((e) {
  final balasan = (e['balasan'] ?? '').toString().trim();
  return balasan.isNotEmpty;
}).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _summaryChip('Total', total, Colors.white),
          const SizedBox(width: 8),
          _summaryChip('Diproses', diproses, Colors.orangeAccent),
          const SizedBox(width: 8),
          _summaryChip('Selesai', selesai, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$val',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
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
    final hasBalasan = item['balasan'] != null &&
    item['balasan'].toString().trim().isNotEmpty;

    final status = hasBalasan ? 'selesai' : 'diproses';

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
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            // strip warna status
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
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            _statusColor(status).withOpacity(0.15),
                        child: Text(
                          _inisial(item['nama'] ?? 'W'),
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
                            Text(item['nama'] ?? '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text(item['kategori'] ?? '-',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      _statusBadge(status),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    item['isi'] ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87),
                  ),

                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(item['tanggal'] ?? '-',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                      if (hasBalasan) ...[
                        const Icon(Icons.reply_outlined,
                            size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        const Text('Ada balasan',
                            style: TextStyle(
                                fontSize: 11, color: Colors.blue)),
                      ] else ...[
                        const Icon(Icons.hourglass_empty_outlined,
                            size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        const Text('Menunggu tanggapan',
                            style: TextStyle(
                                fontSize: 11, color: Colors.orange)),
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

  // ─── DETAIL SHEET ─────────────────────────
  void _showDetail(Map item) {
    final hasBalasan = item['balasan'] != null &&
    item['balasan'].toString().trim().isNotEmpty;

    final status = hasBalasan ? 'selesai' : 'diproses';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const Icon(Icons.campaign_outlined,
                        color: Color(0xFF1A73E8)),
                    const SizedBox(width: 8),
                    const Text('Detail Pengaduan',
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
                    _detailRow('Nama Warga', item['nama']),
                    _detailRow('Kategori', item['kategori']),
                    _detailRow('Tanggal', item['tanggal']),
                    const SizedBox(height: 4),

                    // Isi pengaduan
                    Text('Isi Pengaduan',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(item['isi'] ?? '-',
                          style: const TextStyle(height: 1.5)),
                    ),

                    const SizedBox(height: 16),

                    // Balasan petugas
                    if (hasBalasan) ...[
                      Row(
                        children: [
                          const Icon(Icons.reply,
                              size: 16, color: Color(0xFF1A73E8)),
                          const SizedBox(width: 6),
                          const Text('Balasan Petugas',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.support_agent,
                                    size: 16,
                                    color: Colors.blue.shade700),
                                const SizedBox(width: 6),
                                Text('Petugas',
                                    style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                                if (item['tanggal_balasan'] != null) ...[
                                  const Spacer(),
                                  Text(item['tanggal_balasan'],
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(item['balasan'],
                                style: const TextStyle(
                                    height: 1.5, fontSize: 13)),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.orange.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_top,
                                color: Colors.orange.shade700, size: 18),
                            const SizedBox(width: 10),
                            const Text(
                              'Pengaduan belum mendapat balasan dari petugas',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
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
  Widget _detailRow(String label, String? value) {
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
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
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
              Icon(Icons.campaign_outlined, size: 60, color: Colors.white54),
              SizedBox(height: 12),
              Text('Tidak ada data pengaduan',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'diproses':
        return Colors.orange;
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
}