import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_menuwarga.dart';
import '../../widgets/app_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class PengajuanPage extends StatefulWidget {
  /// Jika diisi (misalnya dari notifikasi), detail pengajuan dengan id ini
  /// akan otomatis terbuka begitu data selesai dimuat.
  final int? initialPengajuanId;

  const PengajuanPage({super.key, this.initialPengajuanId});

  @override
  State<PengajuanPage> createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  final _api = ApiService();

  Map<String, dynamic>? jenisSuratDipilih;
  String? tujuanSelected;
  bool isLainnya = false;
  final tujuanManualCtrl = TextEditingController();

  List<Map<String, dynamic>> berkasForm = [];
  Map<int, Map<String, dynamic>> fileUploads = {};
  List<Map<String, dynamic>> berkasPendukung = [];
  List<Map<String, dynamic>> jenisSuratList = [];
  List<Map<String, dynamic>> pengajuanList = [];

  bool isLoadingJenis = false;
  bool isLoadingPengajuan = false;
  bool isSending = false;

  // ── THEME ──────────────────────────────────────────────────────────────
  static const _blue = Color(0xFF2F80ED);
  static const _darkBlue = Color(0xFF1C4FA1);

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
    } catch (_) {
    } finally {
      setState(() => isLoadingJenis = false);
    }
  }

  Future<void> _loadPengajuan() async {
    setState(() => isLoadingPengajuan = true);
    try {
      final res = await _api.getRiwayatPengajuan();
      final semua = List<Map<String, dynamic>>.from(res['data']['data'] ?? []);
      setState(() {
        pengajuanList = semua.where((item) {
          final status = item['status']?.toString().toLowerCase() ?? '';
          return status != 'selesai' && status != 'ditolak';
        }).toList();
      });

      // Dibuka dari notifikasi → cari item terkait (dari seluruh riwayat,
      // termasuk yang sudah selesai/ditolak) lalu tampilkan detailnya.
      if (widget.initialPengajuanId != null) {
        final target = semua.firstWhere(
          (e) => e['id'] == widget.initialPengajuanId,
          orElse: () => {},
        );
        if (target.isNotEmpty && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showDetailPengajuan(target);
          });
        }
      }
    } catch (_) {
    } finally {
      setState(() => isLoadingPengajuan = false);
    }
  }

  void _onJenisSuratChanged(Map<String, dynamic>? val) {
    setState(() {
      jenisSuratDipilih = val;
      tujuanSelected = null;
      isLainnya = false;
      tujuanManualCtrl.clear();
      fileUploads.clear();
      berkasPendukung.clear();
      final persyaratan = val?['persyaratan'];
      if (persyaratan is List) {
        berkasForm = persyaratan
            .map<Map<String, dynamic>>((p) => {'nama_berkas': p.toString()})
            .toList();
      } else {
        berkasForm = [];
      }
    });
  }

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
          'bytes': result.files.single.bytes!,
          'filename': result.files.single.name,
        };
      });
    }
  }

  void _previewBerkas(int index) {
    final data = fileUploads[index];
    if (data == null) return;
    _showPreview(data['bytes'] as Uint8List, data['filename'] as String,
        onGanti: () => _pilihFile(index));
  }

  Future<void> _tambahBerkasPendukung() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.bytes == null) return;

    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keterangan Berkas'),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'cth: Surat Kuasa, Surat Domisili...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _blue),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        berkasPendukung.add({
          'keterangan': ctrl.text.trim().isEmpty ? result.files.single.name : ctrl.text.trim(),
          'bytes': result.files.single.bytes!,
          'filename': result.files.single.name,
        });
      });
    }
  }

  void _previewPendukung(int index) {
    final data = berkasPendukung[index];
    _showPreview(data['bytes'] as Uint8List, data['filename'] as String, onGanti: () async {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom, withData: true, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          berkasPendukung[index] = {
            ...berkasPendukung[index],
            'bytes': result.files.single.bytes!,
            'filename': result.files.single.name,
          };
        });
      }
    });
  }

  void _hapusPendukung(int index) => setState(() => berkasPendukung.removeAt(index));

  void _showPreview(Uint8List bytes, String filename, {required VoidCallback onGanti}) {
    final isImage = filename.toLowerCase().endsWith('.jpg') ||
        filename.toLowerCase().endsWith('.jpeg') ||
        filename.toLowerCase().endsWith('.png');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 16),
            Text(filename, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 16),
            if (isImage)
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(bytes, fit: BoxFit.contain, height: 300, width: double.infinity))
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(filename, style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('${(bytes.length / 1024).toStringAsFixed(1)} KB',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
              ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () { Navigator.pop(context); onGanti(); },
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Ganti File'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: _darkBlue),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Sudah Benar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _ajukan() async {
    if (jenisSuratDipilih == null) { _snack('Pilih jenis surat terlebih dahulu.', isError: true); return; }
    final tujuanOpts = _tujuanOptions;
    if (tujuanOpts.isNotEmpty && tujuanSelected == null) { _snack('Pilih tujuan pengajuan.', isError: true); return; }
    if (isLainnya && tujuanManualCtrl.text.trim().isEmpty) { _snack('Masukkan tujuan pengajuan.', isError: true); return; }
    if (berkasForm.isNotEmpty && fileUploads.length != berkasForm.length) { _snack('Upload semua berkas yang diperlukan.', isError: true); return; }

    setState(() => isSending = true);
    try {
      final berkas = <Map<String, dynamic>>[];
      for (int i = 0; i < berkasForm.length; i++) {
        berkas.add({'nama': berkasForm[i]['nama_berkas'], 'bytes': fileUploads[i]!['bytes'], 'filename': fileUploads[i]!['filename']});
      }
      for (final bp in berkasPendukung) {
        berkas.add({'nama': '[Pendukung] ${bp['keterangan']}', 'bytes': bp['bytes'], 'filename': bp['filename']});
      }
      final String tujuanFinal = isLainnya ? tujuanManualCtrl.text.trim() : tujuanSelected ?? '';
      await _api.buatPengajuan(jenisSuratId: jenisSuratDipilih!['id'], tujuan: tujuanFinal, berkas: berkas);
      _snack('Pengajuan berhasil dikirim!');
      setState(() {
        jenisSuratDipilih = null; tujuanSelected = null; isLainnya = false;
        berkasForm = []; fileUploads = {}; berkasPendukung = [];
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
      case 'selesai': return Colors.green;
      case 'ditolak': return Colors.red;
      case 'diproses': return Colors.orange;
      case 'diverifikasi': return _blue;
      case 'ditandatangani': return Colors.teal;
      default: return Colors.grey;
    }
  }

  bool _isImageFile(String filename) {
    final lower = filename.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        title: 'Pengajuan Surat',
        actions: const [],
        bottomNavigationBar: const BottomMenu(currentIndex: 2),
        body: Column(children: [
          _tabBar(),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(children: [
              _tabForm(),
              _tabDaftar(),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(25)),
      child: const TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25))),
        labelColor: _blue,
        unselectedLabelColor: Colors.white,
        tabs: [
          Tab(text: 'Form Pengajuan'),
          Tab(text: 'Daftar Pengajuan'),
        ],
      ),
    );
  }

  Widget _tabForm() {
    final tujuanOpts = _tujuanOptions;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(children: [
        // ── JENIS SURAT CARD ──────────────────────────────────────
        _formCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _formSectionLabel('Jenis Surat', Icons.description_outlined, _blue),
            const SizedBox(height: 12),
            isLoadingJenis
                ? const Center(child: CircularProgressIndicator(color: _blue))
                : DropdownButtonFormField<Map<String, dynamic>>(
                    value: jenisSuratDipilih,
                    decoration: _inputDecoration('Pilih jenis surat', Icons.description_outlined),
                    items: jenisSuratList
                        .map((js) => DropdownMenuItem<Map<String, dynamic>>(
                              value: js,
                              child: Text(js['nama'] ?? ''),
                            ))
                        .toList(),
                    onChanged: _onJenisSuratChanged,
                  ),

            if (jenisSuratDipilih != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_blue.withOpacity(0.08), _blue.withOpacity(0.03)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _blue.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: _blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        jenisSuratDipilih!['deskripsi'] ?? '-',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1C4FA1), height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ]),
        ),

        // ── TUJUAN CARD ───────────────────────────────────────────
        if (tujuanOpts.isNotEmpty) ...[
          const SizedBox(height: 12),
          _formCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _formSectionLabel('Tujuan Pengajuan', Icons.flag_outlined, Colors.orange),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tujuanOpts.contains(tujuanSelected) ? tujuanSelected : null,
                decoration: _inputDecoration('Pilih tujuan', Icons.flag_outlined),
                items: tujuanOpts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() {
                  tujuanSelected = v;
                  isLainnya = v == 'Lainnya';
                  if (!isLainnya) tujuanManualCtrl.clear();
                }),
              ),
              if (isLainnya) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: tujuanManualCtrl,
                  decoration: _inputDecoration('Masukkan tujuan', Icons.edit_outlined),
                ),
              ],
            ]),
          ),
        ],

        // ── BERKAS WAJIB ──────────────────────────────────────────
        if (berkasForm.isNotEmpty) ...[
          const SizedBox(height: 12),
          _formCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _formSectionLabel('Berkas Persyaratan', Icons.lock_outline, Colors.red),
              const SizedBox(height: 4),
              Text('Semua berkas wajib diunggah',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 14),
              ...List.generate(berkasForm.length, (i) {
                final nama = berkasForm[i]['nama_berkas'] as String;
                final sudahUpload = fileUploads.containsKey(i);
                final filename = fileUploads[i]?['filename'] as String?;
                final isImage = filename != null && _isImageFile(filename);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: sudahUpload ? Colors.green.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: sudahUpload ? Colors.green.shade300 : Colors.grey.shade200),
                  ),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: sudahUpload ? Colors.green.withOpacity(0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            sudahUpload ? Icons.check_circle : Icons.insert_drive_file,
                            color: sudahUpload ? Colors.green : Colors.grey,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            if (sudahUpload && filename != null)
                              GestureDetector(
                                onTap: () => _previewBerkas(i),
                                child: Text(filename,
                                    style: const TextStyle(fontSize: 11, color: _blue, decoration: TextDecoration.underline)),
                              ),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _pilihFile(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: sudahUpload
                                    ? [Colors.grey.shade300, Colors.grey.shade400]
                                    : [_blue, _darkBlue],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              sudahUpload ? 'Ganti' : 'Unggah',
                              style: TextStyle(
                                  color: sudahUpload ? Colors.black54 : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    if (sudahUpload && isImage)
                      GestureDetector(
                        onTap: () => _previewBerkas(i),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
                          child: Image.memory(fileUploads[i]!['bytes'] as Uint8List,
                              height: 90, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                  ]),
                );
              }),
            ]),
          ),
        ],

        // ── BERKAS PENDUKUNG ──────────────────────────────────────
        if (jenisSuratDipilih != null) ...[
          const SizedBox(height: 12),
          _formCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _formSectionLabel('Berkas Pendukung', Icons.add_circle_outline, Colors.teal),
              const SizedBox(height: 4),
              Text('Opsional — tambahkan jika diperlukan',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 14),
              ...List.generate(berkasPendukung.length, (i) {
                final bp = berkasPendukung[i];
                final filename = bp['filename'] as String;
                final isImage = _isImageFile(filename);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.attach_file, color: Colors.teal, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(bp['keterangan'] as String,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            GestureDetector(
                              onTap: () => _previewPendukung(i),
                              child: Text(filename,
                                  style: const TextStyle(fontSize: 11, color: Colors.teal, decoration: TextDecoration.underline)),
                            ),
                          ]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => _hapusPendukung(i),
                        ),
                      ]),
                    ),
                    if (isImage)
                      GestureDetector(
                        onTap: () => _previewPendukung(i),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
                          child: Image.memory(bp['bytes'] as Uint8List,
                              height: 90, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                  ]),
                );
              }),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.teal.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _tambahBerkasPendukung,
                  icon: Icon(Icons.add, color: Colors.teal.shade400),
                  label: Text(
                    berkasPendukung.isEmpty ? 'Tambah Berkas Pendukung' : 'Tambah Lagi',
                    style: TextStyle(color: Colors.teal.shade600, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 20),

        // ── TOMBOL AJUKAN ─────────────────────────────────────────
Container(
  width: double.infinity,
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF10B981),
        Color(0xFF059669),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Color.fromARGB(255, 133, 216, 170),
        blurRadius: 14,
        offset: Offset(0, 6),
      ),
    ],
  ),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    onPressed: isSending ? null : _ajukan,
    child: isSending
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Ajukan Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
  ),
),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _formCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _formSectionLabel(String title, IconData icon, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
    ]);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _blue),
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue, width: 1.5)),
    );
  }

  Widget _tabDaftar() {
    if (isLoadingPengajuan) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (pengajuanList.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.white54),
          SizedBox(height: 12),
          Text('Belum ada pengajuan aktif.', style: TextStyle(color: Colors.white70)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPengajuan,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: pengajuanList.length,
        itemBuilder: (_, i) {
          final item = pengajuanList[i];
          final nama = item['jenis_surat']?['nama'] ?? '-';
          final nomor = item['nomor_pengajuan'] ?? '-';
          final status = item['status'] ?? '-';
          final color = _statusColor(status);

          return GestureDetector(
            onTap: () => _showDetailPengajuan(item),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.description_outlined, color: color, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(nama,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(status,
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.tag, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(nomor, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const Spacer(),
                        Text('Lihat Detail →',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade400)),
                      ]),
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailPengajuan(Map<String, dynamic> data) {
    final status = data['status'] ?? '-';
    final color = _statusColor(status);
    final berkas = data['berkas'] as List? ?? [];
    final berkasWajib = berkas.where((b) => !(b['nama_berkas'] ?? '').startsWith('[Pendukung]')).toList();
    final berkasPendukungList = berkas.where((b) => (b['nama_berkas'] ?? '').startsWith('[Pendukung]')).toList();

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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 44, height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)))),
            const SizedBox(height: 20),
            Row(children: [
              const Text('Detail Pengajuan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 20),
            _detailRow('Jenis Surat', data['jenis_surat']?['nama'] ?? '-'),
            if (data['tujuan'] != null) ...[const Divider(height: 24), _detailRow('Tujuan', data['tujuan'])],
            const Divider(height: 24),
            _detailRow('Nomor Pengajuan', data['nomor_pengajuan'] ?? '-'),
            if (data['catatan'] != null) ...[const Divider(height: 24), _detailRow('Catatan Petugas', data['catatan'])],
            if (data['alasan_penolakan'] != null) ...[
              const Divider(height: 24),
              _detailRow('Alasan Penolakan', data['alasan_penolakan'], valueColor: Colors.red),
            ],
            if (berkasWajib.isNotEmpty) ...[
              const Divider(height: 24),
              const Text('Berkas Persyaratan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              ...berkasWajib.map<Widget>((b) => _berkasTile(b)).toList(),
            ],
            if (berkasPendukungList.isNotEmpty) ...[
              const Divider(height: 24),
              Row(children: [
                const Text('Berkas Pendukung',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('${berkasPendukungList.length} file',
                      style: const TextStyle(fontSize: 11, color: _blue)),
                ),
              ]),
              const SizedBox(height: 8),
              ...berkasPendukungList.map<Widget>((b) => _berkasTile(b, isPendukung: true)).toList(),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _darkBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup', style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _berkasTile(Map<String, dynamic> b, {bool isPendukung = false}) {
    String namaTampil = b['nama_berkas'] ?? '-';
    if (isPendukung && namaTampil.startsWith('[Pendukung] ')) {
      namaTampil = namaTampil.replaceFirst('[Pendukung] ', '');
    }
    final fileUrl = b['file_url'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: isPendukung ? Colors.teal.withOpacity(0.06) : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isPendukung ? Colors.teal.shade100 : Colors.grey.shade200)),
      child: Row(children: [
        Icon(isPendukung ? Icons.attach_file : Icons.insert_drive_file,
            size: 16, color: isPendukung ? Colors.teal : Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(namaTampil, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            if ((b['file_original'] ?? '').isNotEmpty)
              Text(b['file_original'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ]),
        ),
        if (fileUrl != null && fileUrl.isNotEmpty)
          IconButton(
            tooltip: 'Buka file',
            icon: const Icon(Icons.open_in_new, size: 18, color: _blue),
            onPressed: () async {
              final uri = Uri.parse(fileUrl);
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
      ]),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: valueColor ?? Colors.black87)),
    ]);
  }
}