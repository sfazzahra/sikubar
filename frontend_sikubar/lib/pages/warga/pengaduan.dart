import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_menuwarga.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  final _api = ApiService();

  String? kategoriDipilih;
  final isiCtrl = TextEditingController();
  Uint8List? buktiBytes;
  String? buktiNama;

  List<Map<String, dynamic>> pengaduanList = [];
  bool isLoading = false;
  bool isSending = false;

  static const _blue = Color(0xFF2F80ED);
  static const _darkBlue = Color(0xFF1C4FA1);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  Future<void> _loadPengaduan() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getRiwayatPengaduan();
      setState(() {
        pengaduanList = List<Map<String, dynamic>>.from(res['data']['data'] ?? []);
      });
    } catch (_) {
    } finally {
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
        buktiNama = result.files.single.name;
      });
    }
  }

  Future<void> _kirim() async {
    if (kategoriDipilih == null) { _snack('Pilih kategori pengaduan.', isError: true); return; }
    if (isiCtrl.text.trim().isEmpty) { _snack('Isi pengaduan wajib diisi.', isError: true); return; }

    setState(() => isSending = true);
    try {
      await _api.kirimPengaduanDenganBukti(
        judul: kategoriDipilih!,
        isi: isiCtrl.text.trim(),
        buktiBytes: buktiBytes,
        buktiNama: buktiNama,
      );
      _snack('Pengaduan berhasil dikirim.');
      setState(() { kategoriDipilih = null; buktiBytes = null; buktiNama = null; });
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
      case 'selesai': return Colors.green;
      case 'diproses': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        title: 'Pengaduan Layanan',
        actions: const [],
        bottomNavigationBar: const BottomMenu(currentIndex: 4),
        body: Column(
          children: [
            _tabBar(),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(children: [_tabForm(), _tabDaftar()]),
            ),
          ],
        ),
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
        tabs: [Tab(text: 'Form Pengaduan'), Tab(text: 'Daftar Pengaduan')],
      ),
    );
  }

  Widget _tabForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(children: [
        // ── KATEGORI CARD ─────────────────────────────────────────
        _formCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _formSectionLabel('Kategori Pengaduan', Icons.category_outlined, Colors.orange),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: kategoriDipilih,
            decoration: _inputDecoration('Pilih kategori', Icons.category_outlined),
            items: kategoriList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
            onChanged: (v) => setState(() => kategoriDipilih = v),
          ),
        ])),

        const SizedBox(height: 12),

        // ── ISI PENGADUAN CARD ────────────────────────────────────
        _formCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _formSectionLabel('Isi Pengaduan', Icons.message_outlined, _blue),
          const SizedBox(height: 12),
          TextField(
            controller: isiCtrl,
            maxLines: 5,
            decoration: _inputDecoration('Tulis pengaduan Anda...', Icons.edit_outlined)
                .copyWith(alignLabelWithHint: true, prefixIcon: null),
          ),
        ])),

        const SizedBox(height: 12),

        // ── BUKTI CARD ────────────────────────────────────────────
        _formCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _formSectionLabel('Bukti', Icons.image_outlined, Colors.purple),
          const SizedBox(height: 4),
          Text('Opsional — foto/dokumen pendukung',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pilihBukti,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              decoration: BoxDecoration(
                color: buktiBytes != null ? Colors.green.withOpacity(0.05) : const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: buktiBytes != null ? Colors.green.shade300 : Colors.grey.shade200),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: buktiBytes != null ? Colors.green.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    buktiBytes != null ? Icons.check_circle : Icons.upload_file,
                    color: buktiBytes != null ? Colors.green : Colors.grey,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    buktiNama ?? 'Tap untuk upload bukti (JPG/PNG/PDF)',
                    style: TextStyle(
                      fontSize: 13,
                      color: buktiBytes != null ? Colors.green.shade700 : Colors.grey.shade500,
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

          if (buktiBytes != null &&
              (buktiNama!.endsWith('.jpg') || buktiNama!.endsWith('.jpeg') || buktiNama!.endsWith('.png'))) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(buktiBytes!, height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
        ])),

        const SizedBox(height: 20),

        // ── TOMBOL KIRIM ──────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_blue, _darkBlue]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: _blue.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 5)),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: isSending ? null : _kirim,
            child: isSending
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Kirim Pengaduan',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ]),
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
      focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _blue, width: 1.5)),
    );
  }

  Widget _tabDaftar() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (pengaduanList.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.campaign_outlined, size: 60, color: Colors.white54),
          SizedBox(height: 12),
          Text('Belum ada pengaduan.', style: TextStyle(color: Colors.white70)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: pengaduanList.length,
      itemBuilder: (_, i) {
        final d = pengaduanList[i];
        final status = d['status'] ?? '-';
        final color = _statusColor(status);
        final hasBalasan = d['balasan'] != null;

        return GestureDetector(
          onTap: () => _showDetail(context, d),
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
                        child: Icon(Icons.campaign_outlined, color: color, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(d['judul'] ?? '-',
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
                    Text(d['isi'] ?? '-',
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (hasBalasan) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade100)),
                        child: Row(children: [
                          const Icon(Icons.reply, size: 14, color: Colors.green),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(d['balasan'],
                                style: const TextStyle(fontSize: 12, color: Colors.green),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Text('Lihat Detail →',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade400))),
                  ]),
                ),
              ],
            ),
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
      final color = _statusColor(status);
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Text('Detail Pengaduan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(status,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 20),
              _detailRow('Kategori', data['judul'] ?? '-'),
              const Divider(height: 24),
              _detailRow('Isi Pengaduan', data['isi'] ?? '-'),
              if (data['balasan'] != null) ...[
                const Divider(height: 24),
                _detailRow('Balasan Petugas', data['balasan'], valueColor: Colors.green.shade700),
              ],
              const SizedBox(height: 16),
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
            ],
          ),
        ),
      );
    },
  );
}

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: valueColor ?? Colors.black87)),
    ]);
  }
}