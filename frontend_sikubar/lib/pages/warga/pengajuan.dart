import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menuwarga.dart';

class PengajuanPage extends StatefulWidget {
  const PengajuanPage({super.key});

  @override
  State<PengajuanPage> createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  final _api = ApiService();

  Map<String, dynamic>? jenisSuratDipilih;
  String? tujuanSelected;
  bool   isLainnya = false;
  final  tujuanManualCtrl = TextEditingController();

  List<Map<String, dynamic>> berkasForm = [];
  Map<int, Map<String, dynamic>> fileUploads = {}; // idx → {bytes, filename}

  List<Map<String, dynamic>> jenisSuratList  = [];
  List<Map<String, dynamic>> pengajuanList   = [];

  bool isLoadingJenis     = false;
  bool isLoadingPengajuan = false;
  bool isSending          = false;

  @override
  void initState() {
    super.initState();
    _loadJenisSurat();
    _loadPengajuan();
  }

  Future<void> _loadJenisSurat() async {
    setState(() => isLoadingJenis = true);
    try {
      final res = await _api.getJenisSurat();
      setState(() {
        jenisSuratList = List<Map<String, dynamic>>.from(res['data'] ?? []);
      });
    } catch (_) {} finally {
      setState(() => isLoadingJenis = false);
    }
  }

  Future<void> _loadPengajuan() async {
    setState(() => isLoadingPengajuan = true);
    try {
      final res = await _api.getRiwayatPengajuan();
      setState(() {
        pengajuanList = List<Map<String, dynamic>>.from(
            res['data']['data'] ?? []);
      });
    } catch (_) {} finally {
      setState(() => isLoadingPengajuan = false);
    }
  }

  void _onJenisSuratChanged(Map<String, dynamic>? val) {
    setState(() {
      jenisSuratDipilih = val;
      tujuanSelected    = null;
      isLainnya         = false;
      tujuanManualCtrl.clear();
      fileUploads.clear();
      final persyaratan = val?['persyaratan'];
      if (persyaratan is List) {
        berkasForm = persyaratan.map<Map<String, dynamic>>(
            (p) => {'nama_berkas': p.toString()}).toList();
      } else {
        berkasForm = [];
      }
    });
  }

  // Ambil daftar tujuan dari field 'tujuan' di jenis surat (List dari API)
  // + selalu tambah 'Lainnya' di akhir
  List<String> get _tujuanOptions {
    if (jenisSuratDipilih == null) return [];
    final raw = jenisSuratDipilih!['tujuan'];
    List<String> list = [];
    if (raw is List) {
      list = raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (!list.contains('Lainnya')) list.add('Lainnya');
    return list;
  }

  Future<void> _pilihFile(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        fileUploads[index] = {
          'bytes'   : result.files.single.bytes!,
          'filename': result.files.single.name,
        };
      });
    }
  }

  void _previewBerkas(int index) {
    final data = fileUploads[index];
    if (data == null) return;
    final bytes    = data['bytes'] as Uint8List;
    final filename = data['filename'] as String;
    final isImage  = filename.toLowerCase().endsWith('.jpg') ||
                     filename.toLowerCase().endsWith('.jpeg') ||
                     filename.toLowerCase().endsWith('.png');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 44, height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 16),
          Text(filename,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(bytes, fit: BoxFit.contain,
                  height: 320, width: double.infinity),
            )
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                const SizedBox(height: 8),
                Text(filename,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('${(bytes.length / 1024).toStringAsFixed(1)} KB',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () { Navigator.pop(context); _pilihFile(index); },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Ganti File'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C4FA1)),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Sudah Benar',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Future<void> _ajukan() async {
    if (jenisSuratDipilih == null) {
      _snack('Pilih jenis surat terlebih dahulu.', isError: true);
      return;
    }

    // Validasi tujuan jika ada opsi tujuan
    final tujuanOpts = _tujuanOptions;
    if (tujuanOpts.isNotEmpty && tujuanSelected == null) {
      _snack('Pilih tujuan pengajuan.', isError: true);
      return;
    }
    if (isLainnya && tujuanManualCtrl.text.trim().isEmpty) {
      _snack('Masukkan tujuan pengajuan.', isError: true);
      return;
    }

    if (berkasForm.isNotEmpty && fileUploads.length != berkasForm.length) {
      _snack('Upload semua berkas yang diperlukan.', isError: true);
      return;
    }

    setState(() => isSending = true);
    try {
      final berkas = <Map<String, dynamic>>[];
      for (int i = 0; i < berkasForm.length; i++) {
        berkas.add({
          'nama'    : berkasForm[i]['nama_berkas'],
          'bytes'   : fileUploads[i]!['bytes'],
          'filename': fileUploads[i]!['filename'],
        });
      }

      final String tujuanFinal = isLainnya
          ? tujuanManualCtrl.text.trim()
          : tujuanSelected!;

      await _api.buatPengajuan(
        jenisSuratId: jenisSuratDipilih!['id'],
        tujuan: tujuanFinal,
        berkas: berkas,
      );
      _snack('Pengajuan berhasil dikirim!');
      setState(() {
        jenisSuratDipilih = null;
        tujuanSelected    = null;
        isLainnya         = false;
        berkasForm        = [];
        fileUploads       = {};
      });
      tujuanManualCtrl.clear();
      await _loadPengajuan();
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    } catch (_) {
      _snack('Gagal mengirim pengajuan.', isError: true);
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

  Color _statusColor(String s) {
    switch (s) {
      case 'selesai'        : return Colors.green;
      case 'ditolak'        : return Colors.red;
      case 'diproses'       : return Colors.orange;
      case 'diverifikasi'   : return Colors.blue;
      case 'ditandatangani' : return Colors.teal;
      default               : return Colors.grey;
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

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
        bottomNavigationBar: const BottomMenu(currentIndex: 2),
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
        Text('Pengajuan Surat', style: TextStyle(
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
        tabs: [Tab(text: 'Form Pengajuan'), Tab(text: 'Daftar Pengajuan')],
      ),
    );
  }

  Widget _tabForm() {
    final tujuanOpts = _tujuanOptions;

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [

          // JENIS SURAT
          isLoadingJenis
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<Map<String, dynamic>>(
                  value: jenisSuratDipilih,
                  decoration: InputDecoration(
                    labelText: 'Jenis Surat',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: jenisSuratList
                      .map((js) => DropdownMenuItem<Map<String, dynamic>>(
                            value: js, child: Text(js['nama'] ?? '')))
                      .toList(),
                  onChanged: _onJenisSuratChanged,
                ),

          // INFO PERSYARATAN
          if (jenisSuratDipilih != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Keterangan:',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 12, color: Color(0xFF1C4FA1))),
                const SizedBox(height: 4),
                Text(jenisSuratDipilih!['deskripsi'] ?? '-',
                    style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ]),
            ),
          ],

          const SizedBox(height: 15),

          // TUJUAN — dari data API (field 'tujuan' di jenis surat)
          if (tujuanOpts.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              value: tujuanOpts.contains(tujuanSelected) ? tujuanSelected : null,
              decoration: InputDecoration(
                labelText: 'Tujuan Pengajuan',
                prefixIcon: const Icon(Icons.flag_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: tujuanOpts
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() {
                tujuanSelected = v;
                isLainnya = v == 'Lainnya';
                if (!isLainnya) tujuanManualCtrl.clear();
              }),
            ),

            if (isLainnya)
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextField(
                  controller: tujuanManualCtrl,
                  decoration: InputDecoration(
                    labelText: 'Masukkan tujuan',
                    prefixIcon: const Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],

          const SizedBox(height: 15),

          // BERKAS
          if (berkasForm.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Berkas Persyaratan',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                      fontSize: 13)),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Tap nama berkas untuk melihat preview',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ),
            const SizedBox(height: 10),
            ...List.generate(berkasForm.length, (i) {
              final nama        = berkasForm[i]['nama_berkas'] as String;
              final sudahUpload = fileUploads.containsKey(i);
              final filename    = fileUploads[i]?['filename'] as String?;
              final isImage     = filename != null &&
                  (filename.endsWith('.jpg') ||
                   filename.endsWith('.jpeg') ||
                   filename.endsWith('.png'));

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: sudahUpload
                      ? Colors.green.withOpacity(0.05)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sudahUpload
                          ? Colors.green.shade300
                          : Colors.grey.shade300),
                ),
                child: Column(children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 2),
                    leading: Icon(
                      sudahUpload ? Icons.check_circle : Icons.insert_drive_file,
                      color: sudahUpload ? Colors.green : Colors.grey,
                    ),
                    title: Text(nama,
                        style: const TextStyle(fontSize: 13)),
                    subtitle: sudahUpload
                        ? GestureDetector(
                            onTap: () => _previewBerkas(i),
                            child: Text(
                              filename ?? '',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2F80ED),
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        : null,
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: sudahUpload
                              ? Colors.grey.shade300
                              : const Color(0xFF2F80ED),
                          padding: const EdgeInsets.symmetric(horizontal: 12)),
                      onPressed: () => _pilihFile(i),
                      child: Text(sudahUpload ? 'Ganti' : 'Unggah',
                          style: TextStyle(
                              color: sudahUpload ? Colors.black54 : Colors.white,
                              fontSize: 12)),
                    ),
                  ),
                  if (sudahUpload && isImage)
                    GestureDetector(
                      onTap: () => _previewBerkas(i),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12)),
                        child: Image.memory(
                          fileUploads[i]!['bytes'] as Uint8List,
                          height: 90, width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ]),
              );
            }),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C4FA1),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              onPressed: isSending ? null : _ajukan,
              child: isSending
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Ajukan Sekarang',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tabDaftar() {
    if (isLoadingPengajuan) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    if (pengajuanList.isEmpty) {
      return const Center(
          child: Text('Belum ada pengajuan.',
              style: TextStyle(color: Colors.white)));
    }
    return RefreshIndicator(
      onRefresh: _loadPengajuan,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: pengajuanList.length,
        itemBuilder: (_, i) {
          final item   = pengajuanList[i];
          final nama   = item['jenis_surat']?['nama'] ?? '-';
          final nomor  = item['nomor_pengajuan'] ?? '-';
          final status = item['status'] ?? '-';
          final color  = _statusColor(status);
          return GestureDetector(
            onTap: () => _showDetailPengajuan(item),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Expanded(
                    child: Text(nama, style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(status, style: TextStyle(
                        color: color, fontWeight: FontWeight.bold,
                        fontSize: 11)),
                  ),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.tag, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(nomor, style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
                ]),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight,
                  child: Text('Lihat Detail →',
                      style: TextStyle(fontSize: 12,
                          color: Colors.blue.shade400))),
              ]),
            ),
          );
        },
      ),
    );
  }

  void _showDetailPengajuan(Map<String, dynamic> data) {
    final status = data['status'] ?? '-';
    final color  = _statusColor(status);
    final berkas = data['berkas'] as List? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Center(child: Container(width: 44, height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20)))),
            const SizedBox(height: 20),
            const Text('Detail Pengajuan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _detailRow('Jenis Surat',
                data['jenis_surat']?['nama'] ?? '-'),
            if (data['tujuan'] != null) ...[
              const Divider(height: 24),
              _detailRow('Tujuan', data['tujuan']),
            ],
            const Divider(height: 24),
            _detailRow('Nomor Pengajuan',
                data['nomor_pengajuan'] ?? '-'),
            const Divider(height: 24),
            Row(children: [
              const Text('Status : ',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(
                    color: color, fontWeight: FontWeight.bold)),
              ),
            ]),
            if (data['catatan'] != null) ...[
              const Divider(height: 24),
              _detailRow('Catatan Petugas', data['catatan']),
            ],
            if (data['alasan_penolakan'] != null) ...[
              const Divider(height: 24),
              _detailRow('Alasan Penolakan', data['alasan_penolakan'],
                  valueColor: Colors.red),
            ],
            if (berkas.isNotEmpty) ...[
              const Divider(height: 24),
              const Text('Berkas yang Diunggah',
                  style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 13)),
              const SizedBox(height: 8),
              ...berkas.map<Widget>((b) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.attach_file, size: 16,
                      color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(b['nama_berkas'] ?? '-',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                  ),
                  Text(b['file_original'] ?? '',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
                ]),
              )).toList(),
            ],
            const SizedBox(height: 20),
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
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: valueColor ?? Colors.black87)),
    ]);
  }
}