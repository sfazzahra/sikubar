import 'package:flutter/material.dart';
import '../../services/api_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// TAB 2 — JENIS SURAT
// ══════════════════════════════════════════════════════════════════════════════

const Color _kPrimary     = Color(0xFF2F80ED);
const Color _kPrimaryDark = Color(0xFF1B5FC4);
const Color _kBg          = Color(0xFFF5F7FB);

class AdminJenisSuratTab extends StatefulWidget {
  const AdminJenisSuratTab({super.key});

  @override
  State<AdminJenisSuratTab> createState() => _AdminJenisSuratTabState();
}

class _AdminJenisSuratTabState extends State<AdminJenisSuratTab> {
  final _api = ApiService();

  final namaCtrl   = TextEditingController();
  final kodeCtrl   = TextEditingController();
  final deskCtrl   = TextEditingController();
  final syaratCtrl = TextEditingController();
  final tujuanCtrl = TextEditingController();

  int?  seksiId;
  bool  isActive  = true;
  bool  showForm  = false;
  bool  isLoading = false;
  bool  isSaving  = false;
  int?  editId;

  List<Map<String, dynamic>> jenisSuratList = [];

  static const Map<int, String> seksiNama = {
    1: 'Seksi Pemerintah',
    2: 'Seksi Ketentraman dan Ketertiban',
    3: 'Seksi Pemberdayaan Masyarakat',
    4: 'Seksi Kesejahteraan Sosial',
    5: 'Seksi Lingkungan Hidup',
  };

  static const Map<int, Color> seksiColor = {
    1: Color(0xFF2F80ED),
    2: Color(0xFFEF4444),
    3: Color(0xFF10B981),
    4: Color(0xFFF97316),
    5: Color(0xFF0D9488),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    namaCtrl.dispose(); kodeCtrl.dispose(); deskCtrl.dispose();
    syaratCtrl.dispose(); tujuanCtrl.dispose();
    super.dispose();
  }

  List<String> _splitSemicolon(String raw) => raw
      .split(';')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getJenisSuratAdmin();
      setState(() {
        jenisSuratList =
            List<Map<String, dynamic>>.from(res['data']['data'] ?? []);
      });
    } catch (_) {
      _snack('Gagal memuat data.', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _simpan() async {
    if (namaCtrl.text.trim().isEmpty ||
        kodeCtrl.text.trim().isEmpty ||
        seksiId == null) {
      _snack('Nama, kode, dan seksi wajib diisi.', isError: true);
      return;
    }
    setState(() => isSaving = true);
    try {
      final body = {
        'nama'        : namaCtrl.text.trim(),
        'kode'        : kodeCtrl.text.trim().toUpperCase(),
        'deskripsi'   : deskCtrl.text.trim(),
        'seksi_id'    : seksiId,
        'persyaratan' : _splitSemicolon(syaratCtrl.text),
        'tujuan'      : _splitSemicolon(tujuanCtrl.text),
        'is_active'   : isActive,
      };
      if (editId == null) {
        await _api.createJenisSurat(body);
        _snack('Jenis surat berhasil ditambahkan.');
      } else {
        await _api.updateJenisSurat(editId!, body);
        _snack('Jenis surat berhasil diperbarui.');
      }
      _resetForm();
      await _load();
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _hapus(int id, String nama) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Jenis Surat',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Jenis surat "$nama" akan dihapus secara permanen.',
            style: const TextStyle(fontSize: 13.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.deleteJenisSurat(id);
      _snack('Jenis surat dihapus.');
      await _load();
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    }
  }

  Future<void> _toggleAktif(int id) async {
    try {
      await _api.toggleAktifJenisSurat(id);
      await _load();
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    }
  }

  void _isiFormEdit(Map<String, dynamic> js) {
    namaCtrl.text = js['nama'] ?? '';
    kodeCtrl.text = js['kode'] ?? '';
    deskCtrl.text = js['deskripsi'] ?? '';
    seksiId       = js['seksi_id'];
    isActive      = js['is_active'] ?? true;
    editId        = js['id'];
    final p = js['persyaratan'];
    if (p is List) syaratCtrl.text = p.join('; ');
    final t = js['tujuan'];
    if (t is List) tujuanCtrl.text = t.join('; ');
    setState(() => showForm = true);
  }

  void _resetForm() {
    namaCtrl.clear(); kodeCtrl.clear(); deskCtrl.clear();
    syaratCtrl.clear(); tujuanCtrl.clear();
    setState(() {
      seksiId  = null;
      isActive = true;
      editId   = null;
      showForm = false;
    });
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  int get _totalAktif =>
      jenisSuratList.where((js) => js['is_active'] == true).length;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(color: _kPrimary))
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              // ── SUMMARY CARD ────────────────────────────────────────────
              _summaryCard(),
              const SizedBox(height: 20),

              // ── TOMBOL TAMBAH ────────────────────────────────────────────
              _addButton(),

              // ── FORM ─────────────────────────────────────────────────────
              if (showForm) ...[
                const SizedBox(height: 16),
                _buildForm(),
              ],

              const SizedBox(height: 24),

              // ── HEADER DAFTAR ─────────────────────────────────────────────
              Row(children: [
                Container(
                  width: 4, height: 20,
                  decoration: BoxDecoration(
                      color: _kPrimary, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 10),
                const Text('Daftar Jenis Surat',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2433))),
                const Spacer(),
                GestureDetector(
                  onTap: _load,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.refresh_rounded,
                        color: _kPrimary, size: 18),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // ── LIST ──────────────────────────────────────────────────────
              jenisSuratList.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: jenisSuratList.length,
                      itemBuilder: (_, i) =>
                          _jenisSuratCard(jenisSuratList[i]),
                    ),
            ]),
          );
  }

  // ── SUMMARY CARD ──────────────────────────────────────────────────────────
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, _kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _kPrimary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.description_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total Jenis Surat',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text('${jenisSuratList.length} Jenis',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _miniStat('Aktif', '$_totalAktif', Colors.greenAccent),
          const SizedBox(height: 4),
          _miniStat('Nonaktif',
              '${jenisSuratList.length - _totalAktif}',
              Colors.white60),
        ]),
      ]),
    );
  }

  Widget _miniStat(String label, String val, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text('$label: $val',
          style: TextStyle(color: color, fontSize: 11,
              fontWeight: FontWeight.w600)),
    ]);
  }

  // ── ADD BUTTON ────────────────────────────────────────────────────────────
  Widget _addButton() {
    final isEdit = editId != null;
    return GestureDetector(
      onTap: () => setState(() { if (showForm) _resetForm(); else showForm = true; }),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: showForm
              ? Colors.grey.shade100
              : (isEdit ? const Color(0xFFFFF7ED) : _kPrimary),
          borderRadius: BorderRadius.circular(16),
          border: showForm && isEdit
              ? Border.all(color: Colors.orange.shade200)
              : null,
          boxShadow: showForm ? [] : [
            BoxShadow(
                color: _kPrimary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            showForm ? Icons.close_rounded
                : (isEdit ? Icons.edit_rounded : Icons.add_rounded),
            color: showForm
                ? Colors.grey
                : (isEdit ? Colors.orange : Colors.white),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            showForm ? 'Tutup Form'
                : (isEdit ? 'Edit Jenis Surat' : 'Tambah Jenis Surat'),
            style: TextStyle(
                color: showForm
                    ? Colors.grey.shade600
                    : (isEdit ? Colors.orange : Colors.white),
                fontWeight: FontWeight.w700,
                fontSize: 14),
          ),
        ]),
      ),
    );
  }

  // ── FORM ──────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Form header
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: editId != null
                    ? Colors.orange.shade50
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(
                editId != null
                    ? Icons.edit_rounded
                    : Icons.note_add_rounded,
                color: editId != null ? Colors.orange : _kPrimary,
                size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            editId != null ? 'Edit Jenis Surat' : 'Tambah Jenis Surat Baru',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1B2433)),
          ),
          if (editId != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: _resetForm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Batal Edit',
                    style: TextStyle(
                        color: Colors.red, fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 20),

        // Nama + Kode (2 kolom)
        Row(children: [
          Expanded(child: _inp(namaCtrl, 'Nama Jenis Surat', Icons.description_outlined)),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: _inp(kodeCtrl, 'Kode', Icons.tag_rounded),
          ),
        ]),

        _inp(deskCtrl, 'Deskripsi (opsional)', Icons.info_outline),

        // Divider
        _formDivider('Persyaratan & Tujuan'),

        _inp(syaratCtrl,
            'Persyaratan (pisah dengan titik koma)',
            Icons.checklist_rounded),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 14),
          child: Text('Contoh: KTP; KK; Surat Permohonan',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ),

        _inp(tujuanCtrl,
            'Tujuan Pengajuan (pisah dengan titik koma)',
            Icons.flag_outlined),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 14),
          child: Text('Contoh: Untuk usaha; Untuk nelayan; Lainnya',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ),

        // Divider
        _formDivider('Seksi & Status'),

        _dropdownSeksi(),
        const SizedBox(height: 14),

        // Toggle aktif
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: _kBg, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                  isActive
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: isActive
                      ? const Color(0xFF10B981)
                      : Colors.grey.shade400,
                  size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Status Jenis Surat',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1B2433))),
                Text(isActive ? 'Aktif — warga dapat mengajukan' : 'Nonaktif',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ]),
            ),
            Switch(
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
              activeColor: const Color(0xFF10B981),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // Save button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            onPressed: isSaving ? null : _simpan,
            child: isSaving
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(editId != null ? 'Perbarui' : 'Simpan Jenis Surat',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
          ),
        ),
      ]),
    );
  }

  Widget _formDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(child: Divider(color: Colors.grey.shade200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200)),
      ]),
    );
  }

  // ── JENIS SURAT CARD ──────────────────────────────────────────────────────
  Widget _jenisSuratCard(Map<String, dynamic> js) {
    final nama   = js['nama']  as String? ?? '-';
    final kode   = js['kode']  as String? ?? '-';
    final seksi  = js['seksi']?['nama'] as String? ?? '-';
    final sid    = js['seksi_id'] as int? ?? 0;
    final aktif  = js['is_active'] == true;
    final syarat = (js['persyaratan'] as List?)?.cast<String>() ?? [];
    final tujuan = (js['tujuan'] as List?)?.cast<String>() ?? [];
    final sColor = seksiColor[sid] ?? _kPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: [

        // ── Header strip warna seksi ────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: sColor.withOpacity(0.06),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: sColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.description_rounded, color: sColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nama,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1B2433))),
              const SizedBox(height: 2),
              Text(seksi,
                  style: TextStyle(
                      fontSize: 11,
                      color: sColor,
                      fontWeight: FontWeight.w500)),
            ])),
            // Kode badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: sColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(kode,
                  style: TextStyle(
                      color: sColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: 8),
            // Toggle aktif
            GestureDetector(
              onTap: () => _toggleAktif(js['id']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: aktif
                        ? const Color(0xFFF0FDF4)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                        color: aktif
                            ? const Color(0xFF10B981)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(aktif ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                          color: aktif
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ),

        // ── Body ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            if (syarat.isNotEmpty) ...[
              _chipSection('Persyaratan', syarat,
                  Colors.grey.shade100, Colors.grey.shade700,
                  Icons.checklist_rounded, Colors.grey.shade500),
              const SizedBox(height: 10),
            ],

            if (tujuan.isNotEmpty)
              _chipSection('Tujuan', tujuan,
                  sColor.withOpacity(0.08), sColor,
                  Icons.flag_rounded, sColor),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // Action buttons
            Row(children: [
              Expanded(
                child: _actionBtn(
                  label: 'Edit',
                  icon: Icons.edit_rounded,
                  color: _kPrimary,
                  bg: const Color(0xFFEFF6FF),
                  onTap: () => _isiFormEdit(js),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBtn(
                  label: 'Hapus',
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red,
                  bg: const Color(0xFFFEF2F2),
                  onTap: () => _hapus(js['id'], nama),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _chipSection(
    String label,
    List<String> items,
    Color chipBg,
    Color chipFg,
    IconData icon,
    Color iconColor,
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: iconColor,
                fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6, runSpacing: 5,
        children: items.map((s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: chipBg, borderRadius: BorderRadius.circular(6)),
          child: Text(s, style: TextStyle(fontSize: 11, color: chipFg)),
        )).toList(),
      ),
    ]);
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ]),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: const Column(children: [
        Icon(Icons.inbox_rounded, size: 40, color: Color(0xFFCBD5E1)),
        SizedBox(height: 12),
        Text('Belum ada jenis surat',
            style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        Text('Tambahkan jenis surat menggunakan tombol di atas.',
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
      ]),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────
  Widget _inp(TextEditingController c, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: Icon(icon, color: _kPrimary, size: 19),
          filled: true,
          fillColor: _kBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kPrimary, width: 1.4)),
        ),
      ),
    );
  }

  Widget _dropdownSeksi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: _kBg, borderRadius: BorderRadius.circular(14)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: seksiId,
          isExpanded: true,
          hint: Text('Pilih Seksi Penanganan',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          items: seksiNama.entries
              .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value, style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: (v) => setState(() => seksiId = v),
        ),
      ),
    );
  }
}