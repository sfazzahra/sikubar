import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menuwarga.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final _api = ApiService();

  List<Map<String, dynamic>> riwayat  = [];
  bool isLoading = false;

  // Status yang tampil di halaman riwayat (selesai & ditolak)
  static const _statusRiwayat = ['selesai', 'ditolak'];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() => isLoading = true);
    try {
      // Ambil semua, filter lokal agar konsisten dengan tampilan lama
      final res = await _api.getRiwayatPengajuan();
      final semua = List<Map<String, dynamic>>.from(
          res['data']['data'] ?? []);
      setState(() {
        riwayat = semua
            .where((p) => _statusRiwayat.contains(p['status']))
            .toList();
      });
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    } catch (_) {} finally {
      setState(() => isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai': return Colors.green;
      case 'ditolak': return Colors.red;
      default       : return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // HEADER
            SizedBox(
              height: 90,
              child: Stack(children: [
                if (Navigator.canPop(context))
                  Positioned(
                    left: 16, top: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 26),
                    ),
                  ),
                Positioned(
                  right: 10, top: 10,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadRiwayat,
                  ),
                ),
                const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.account_balance, color: Colors.white, size: 32),
                    SizedBox(height: 4),
                    Text('Riwayat Pengajuan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),

            const SizedBox(height: 10),

            // LIST
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : riwayat.isEmpty
                      ? const Center(
                          child: Text('Belum ada riwayat.',
                              style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          itemCount: riwayat.length,
                          itemBuilder: (_, i) => _riwayatCard(riwayat[i]),
                        ),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: const BottomMenu(currentIndex: 3),
    );
  }

  Widget _riwayatCard(Map<String, dynamic> data) {
    final jenis  = data['jenis_surat']?['nama'] ?? '-';
    final nomor  = data['nomor_pengajuan'] ?? '-';
    final status = data['status'] ?? '-';
    final alasan = data['alasan_penolakan'];
    final selesai = data['tanggal_selesai'];
    final color  = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(jenis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.tag, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(nomor, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
        if (selesai != null) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
            const SizedBox(width: 4),
            Text(selesai.toString().substring(0, 10),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ],
        const SizedBox(height: 10),
        Row(children: [
          const Text('Status: '),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Text(status,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        ]),
        if (alasan != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8)),
            child: Text('Alasan: $alasan',
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        ],
      ]),
    );
  }
}