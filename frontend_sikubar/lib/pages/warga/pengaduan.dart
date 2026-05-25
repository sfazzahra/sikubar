import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menuwarga.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  final _api = ApiService();

  // Form
  String? kategoriDipilih;
  final isiCtrl = TextEditingController();
  Uint8List? buktiBytes;
  String?    buktiNama;

  // Data
  List<Map<String, dynamic>> pengaduanList = [];
  bool isLoading = false;
  bool isSending = false;

  // Kategori (judul) — sesuai dropdown lama
  static const List<String> kategoriList = [
    'Pelayanan Lambat',
    'Petugas Tidak Ramah',
    'Fasilitas Kurang',
    'Prosedur Tidak Jelas',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadPengaduan();
  }

  Future<void> _loadPengaduan() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getRiwayatPengaduan();
      setState(() {
        pengaduanList = List<Map<String, dynamic>>.from(
            res['data']['data'] ?? []);
      });
    } catch (_) {} finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pilihBukti() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        buktiBytes = result.files.single.bytes;
        buktiNama  = result.files.single.name;
      });
    }
  }

  Future<void> _kirim() async {
    if (kategoriDipilih == null) {
      _snack('Pilih kategori pengaduan.', isError: true);
      return;
    }
    if (isiCtrl.text.trim().isEmpty) {
      _snack('Isi pengaduan wajib diisi.', isError: true);
      return;
    }

    setState(() => isSending = true);
    try {
      await _api.kirimPengaduanDenganBukti(
  judul: kategoriDipilih!,
  isi: isiCtrl.text.trim(),
  buktiBytes: buktiBytes,
  buktiNama: buktiNama,
);
      _snack('Pengaduan berhasil dikirim.');
      setState(() {
        kategoriDipilih = null;
        buktiBytes = null;
        buktiNama  = null;
      });
      isiCtrl.clear();
      await _loadPengaduan();
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    } catch (_) {
      _snack('Gagal mengirim pengaduan.', isError: true);
    } finally {
      setState(() => isSending = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai' : return Colors.green;
      case 'diproses': return Colors.orange;
      default        : return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(child: Column(children: [
            _header(),
            const SizedBox(height: 10),
            _tabBar(),
            const SizedBox(height: 10),
            Expanded(child: TabBarView(children: [
              _tabForm(),
              _tabDaftar(),
            ])),
          ])),
        ),
        bottomNavigationBar: const BottomMenu(currentIndex: 4),
      ),
    );
  }

  Widget _header() {
    return SizedBox(height: 90, child: Stack(children: [
      if (Navigator.canPop(context))
        Positioned(left: 16, top: 10,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
          )),
      Positioned(right: 10, top: 10,
        child: IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/notifikasi'),
        )),
      const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.account_balance, color: Colors.white, size: 32),
        SizedBox(height: 4),
        Text('Pengaduan Layanan', style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ])),
    ]));
  }

  Widget _tabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25)),
      child: const TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25))),
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.white,
        tabs: [Tab(text: 'Form Pengaduan'), Tab(text: 'Daftar Pengaduan')],
      ),
    );
  }

  Widget _tabForm() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── KATEGORI (dropdown sebagai "judul") ─────────────────────────
          DropdownButtonFormField<String>(
            value: kategoriDipilih,
            decoration: InputDecoration(
              labelText: 'Kategori Pengaduan',
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: kategoriList
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: (v) => setState(() => kategoriDipilih = v),
          ),

          const SizedBox(height: 16),

          // ── ISI ──────────────────────────────────────────────────────────
          TextField(
            controller: isiCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Isi Pengaduan',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 16),

          // ── UPLOAD BUKTI ─────────────────────────────────────────────────
          const Text('Bukti (opsional)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                  color: Color(0xFF444444))),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pilihBukti,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              decoration: BoxDecoration(
                color: buktiBytes != null
                    ? Colors.green.withOpacity(0.07)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: buktiBytes != null
                      ? Colors.green.shade300
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(children: [
                Icon(
                  buktiBytes != null ? Icons.check_circle : Icons.upload_file,
                  color: buktiBytes != null ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    buktiNama ?? 'Tap untuk upload bukti (JPG/PNG/PDF)',
                    style: TextStyle(
                      fontSize: 13,
                      color: buktiBytes != null
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (buktiBytes != null)
                  GestureDetector(
                    onTap: () => setState(() { buktiBytes = null; buktiNama = null; }),
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
              ]),
            ),
          ),

          // Preview gambar jika ada
          if (buktiBytes != null &&
              (buktiNama!.endsWith('.jpg') ||
               buktiNama!.endsWith('.jpeg') ||
               buktiNama!.endsWith('.png'))) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(buktiBytes!, height: 160,
                  width: double.infinity, fit: BoxFit.cover),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C4FA1),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: isSending ? null : _kirim,
              child: isSending
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Kirim Pengaduan',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tabDaftar() {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    if (pengaduanList.isEmpty) {
      return const Center(
          child: Text('Belum ada pengaduan.',
              style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: pengaduanList.length,
      itemBuilder: (_, i) {
        final d      = pengaduanList[i];
        final status = d['status'] ?? '-';
        final color  = _statusColor(status);
        return GestureDetector(
          onTap: () => _showDetail(context, d),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(d['judul'] ?? '-',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(status,
                      style: TextStyle(color: color,
                          fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ]),
              const SizedBox(height: 6),
              Text(d['isi'] ?? '-',
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 13),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              if (d['balasan'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.reply, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(d['balasan'],
                          style: const TextStyle(
                              fontSize: 12, color: Colors.green)),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight,
                child: Text('Lihat Detail →',
                    style: TextStyle(
                        fontSize: 12, color: Colors.blue.shade400))),
            ]),
          ),
        );
      },
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) {
        final status = data['status'] ?? '-';
        final color  = _statusColor(status);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(width: 44, height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20))),
            ),
            const SizedBox(height: 20),
            const Text('Detail Pengaduan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _detailRow('Kategori', data['judul'] ?? '-'),
            const Divider(height: 24),
            _detailRow('Isi Pengaduan', data['isi'] ?? '-'),
            const Divider(height: 24),
            Row(children: [
              const Text('Status : ',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(status,
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.bold)),
              ),
            ]),
            if (data['balasan'] != null) ...[
              const Divider(height: 24),
              _detailRow('Balasan Petugas', data['balasan'],
                  valueColor: Colors.green.shade700),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C4FA1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87)),
    ]);
  }
}