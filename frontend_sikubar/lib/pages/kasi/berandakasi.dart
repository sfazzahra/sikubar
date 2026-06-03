import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BerandaKasiPage extends StatefulWidget {
  const BerandaKasiPage({super.key});

  @override
  State<BerandaKasiPage> createState() => _BerandaKasiPageState();
}

class _BerandaKasiPageState extends State<BerandaKasiPage> {
  final _api = ApiService();
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? statistik;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  setState(() => isLoading = true);

  await Future.delayed(const Duration(seconds: 1));

  setState(() {
    profileData = {
      "nama": "Anisya Rahmawati",
    };

    statistik = {
      "menunggu_review": 8,
      "disetujui": 15,
      "ditolak": 2,
      "total": 25,
    };

    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C4FA1), Color(0xFF2F80ED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _buildHeader(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            _buildStatistik(),
                            const SizedBox(height: 20),
                            _buildMenuCepat(context),
                          ]),
                        ),
                      ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final nama = profileData?['nama'] ?? 'Kepala Seksi';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Selamat Datang,',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          Text(nama,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const Text('Kepala Seksi',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/notifikasi'),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _konfirmasiLogout,
        ),
      ]),
    );
  }

  Widget _buildStatistik() {
    final menunggu = statistik?['menunggu_review'] ?? 0;
    final disetujui = statistik?['disetujui'] ?? 0;
    final ditolak = statistik?['ditolak'] ?? 0;
    final total = statistik?['total'] ?? 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Ringkasan Pengajuan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _statCard('Menunggu Review', menunggu.toString(),
              Icons.pending_actions, Colors.orange),
          _statCard('Disetujui', disetujui.toString(),
              Icons.check_circle_outline, Colors.green),
          _statCard('Ditolak', ditolak.toString(),
              Icons.cancel_outlined, Colors.red),
          _statCard('Total', total.toString(),
              Icons.assignment_outlined, Colors.blue),
        ],
      ),
    ]);
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 2),
          ],
        )),
      ]),
    );
  }

  Widget _buildMenuCepat(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Menu', style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _menuItem(context, Icons.assignment_turned_in_outlined,
            'Review\nPengajuan', Colors.blue,
            () => Navigator.pushNamed(context, '/kasi/pengajuan'))),
        const SizedBox(width: 12),
        Expanded(child: _menuItem(context, Icons.file_download_outlined,
            'Unduh\nSurat', Colors.teal,
            () => Navigator.pushNamed(context, '/kasi/surat'))),
      ]),
    ]);
  }

  Widget _menuItem(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  // FR-25: Logout
  void _konfirmasiLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C4FA1)),
            onPressed: () async {
              await _api.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}