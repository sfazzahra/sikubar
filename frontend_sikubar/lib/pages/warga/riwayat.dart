import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menuwarga.dart';
import '../../widgets/app_scaffold.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final _api = ApiService();

  String formatTanggal(String? datetime) {
    if (datetime == null || datetime.isEmpty) return '-';

    try {
      final dt = DateTime.parse(datetime).toLocal();

      const bulan = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];

      return '${dt.day} ${bulan[dt.month]} ${dt.year}, '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return datetime;
    }
  }

  List<Map<String, dynamic>> riwayat = [];
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
      final semua =
          List<Map<String, dynamic>>.from(res['data']['data'] ?? []);
      setState(() {
        riwayat = semua
            .where((p) => _statusRiwayat.contains(p['status']))
            .toList();
      });
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    } catch (_) {
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Riwayat Pengajuan',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadRiwayat,
        ),
      ],
      bottomNavigationBar: const BottomMenu(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : riwayat.isEmpty
                ? const Center(
                    child: Text('Belum ada riwayat.',
                        style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: riwayat.length,
                    itemBuilder: (_, i) => _riwayatCard(riwayat[i]),
                  ),
      ),
    );
  }

  Widget _riwayatCard(Map<String, dynamic> data) {
    final jenis = data['jenis_surat']?['nama'] ?? '-';
    final nomor = data['nomor_pengajuan'] ?? '-';
    final status = data['status'] ?? '-';
    final alasan = data['alasan_penolakan'];
    final selesai = data['tanggal_selesai'];
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  jenis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// NOMOR PENGAJUAN
          Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 15,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  nomor,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// TANGGAL
          if (selesai != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF2F80ED),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status == 'ditolak'
                              ? 'Tanggal Ditolak'
                              : 'Tanggal Selesai',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatTanggal(selesai),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C4FA1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          /// ALASAN PENOLAKAN
          if (alasan != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alasan Penolakan',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alasan,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}