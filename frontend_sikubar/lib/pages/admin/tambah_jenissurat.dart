import 'package:flutter/material.dart';
import '../../services/api_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// TAB 2 — JENIS SURAT
// ══════════════════════════════════════════════════════════════════════════════
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
  final syaratCtrl = TextEditingController(); // dipisah koma
  final tujuanCtrl = TextEditingController(); // dipisah koma

  int?   seksiId;
  bool   isActive  = true;
  bool   showForm  = false;
  bool   isLoading = false;
  bool   isSaving  = false;
  int?   editId;    // null = tambah baru, ada nilai = edit

  List<Map<String, dynamic>> jenisSuratList = [];

  static const Map<int, String> seksiNama = {
    1: 'Seksi Pemerintah',
    2: 'Seksi Ketentraman dan Ketertiban',
    3: 'Seksi Pemberdayaan Masyarakat',
    4: 'Seksi Kesejahteraan Sosial',
    5: 'Seksi Lingkungan Hidup',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getJenisSuratAdmin();
      setState(() {
        jenisSuratList = List<Map<String, dynamic>>.from(
            res['data']['data'] ?? []);
      });
    } catch (_) {
      _snack('Gagal memuat data.', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _simpan() async {
    if (namaCtrl.text.trim().isEmpty || kodeCtrl.text.trim().isEmpty ||
        seksiId == null) {
      _snack('Nama, kode, dan seksi wajib diisi.', isError: true);
      return;
    }

    setState(() => isSaving = true);
    try {
      // persyaratan & tujuan: dari string dipisah koma
      final persyaratan = syaratCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final tujuan = tujuanCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final body = {
        'nama'        : namaCtrl.text.trim(),
        'kode'        : kodeCtrl.text.trim().toUpperCase(),
        'deskripsi'   : deskCtrl.text.trim(),
        'seksi_id'    : seksiId,
        'persyaratan' : persyaratan,
        'tujuan'      : tujuan,
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
        title: const Text('Hapus Jenis Surat'),
        content: Text('Hapus "$nama"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
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
    namaCtrl.text  = js['nama'] ?? '';
    kodeCtrl.text  = js['kode'] ?? '';
    deskCtrl.text  = js['deskripsi'] ?? '';
    seksiId        = js['seksi_id'];
    isActive       = js['is_active'] ?? true;
    editId         = js['id'];

    final p = js['persyaratan'];
    if (p is List) syaratCtrl.text = p.join(', ');

    final t = js['tujuan'];
    if (t is List) tujuanCtrl.text = t.join(', ');

    setState(() => showForm = true);
  }

  void _resetForm() {
    namaCtrl.clear(); kodeCtrl.clear();
    deskCtrl.clear(); syaratCtrl.clear(); tujuanCtrl.clear();
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
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // TOMBOL TAMBAH
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    if (showForm) _resetForm();
                    else setState(() => showForm = true);
                  },
                  icon: Icon(showForm ? Icons.close : Icons.add,
                      color: Colors.white),
                  label: Text(
                    showForm
                        ? 'Tutup Form'
                        : editId != null
                            ? 'Edit Jenis Surat'
                            : 'Tambah Jenis Surat',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              // FORM
              if (showForm) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10)]),
                  child: Column(children: [
                    if (editId != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.edit, size: 16,
                              color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text('Mode Edit',
                              style: TextStyle(color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                          const Spacer(),
                          GestureDetector(
                            onTap: _resetForm,
                            child: const Text('Batal',
                                style: TextStyle(color: Colors.red,
                                    fontSize: 12)),
                          ),
                        ]),
                      ),

                    _inp(namaCtrl, 'Nama Jenis Surat', Icons.description_outlined),
                    _inp(kodeCtrl, 'Kode (cth: BBM, KK)', Icons.tag),
                    _inp(deskCtrl, 'Deskripsi', Icons.info_outline),

                    // PERSYARATAN
                    _inp(syaratCtrl, 'Persyaratan (pisah koma)', Icons.checklist),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contoh persyaratan: KTP, KK, Surat Permohonan',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // TUJUAN
                    _inp(tujuanCtrl, 'Tujuan Pengajuan (pisah koma)', Icons.flag_outlined),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contoh tujuan: Untuk usaha, Untuk nelayan, Lainnya',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _dropdownSeksi(),
                    const SizedBox(height: 14),

                    // Toggle aktif
                    Row(children: [
                      const Text('Status Aktif',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Switch(
                        value: isActive,
                        onChanged: (v) => setState(() => isActive = v),
                        activeColor: const Color(0xFF2F80ED),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F80ED),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16))),
                        onPressed: isSaving ? null : _simpan,
                        child: isSaving
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(
                                editId != null ? 'Perbarui' : 'Simpan',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                ),
              ],

              const SizedBox(height: 20),

              Row(children: [
                const Text('Daftar Jenis Surat',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFF2F80ED))),
              ]),

              const SizedBox(height: 8),

              jenisSuratList.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: const Center(
                          child: Text('Belum ada jenis surat.',
                              style: TextStyle(color: Colors.grey))),
                    )
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

  Widget _jenisSuratCard(Map<String, dynamic> js) {
    final nama   = js['nama'] ?? '-';
    final kode   = js['kode'] ?? '-';
    final seksi  = js['seksi']?['nama'] as String? ?? '-';
    final aktif  = js['is_active'] == true;
    final syarat = (js['persyaratan'] as List?)?.cast<String>() ?? [];
    final tujuan = (js['tujuan'] as List?)?.cast<String>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(nama, style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          GestureDetector(
            onTap: () => _toggleAktif(js['id']),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: aktif
                      ? Colors.green.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(aktif ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(
                      color: aktif ? Colors.green : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(8)),
            child: Text(kode, style: const TextStyle(
                color: Color(0xFF2F80ED), fontSize: 11,
                fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(seksi,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
          ),
        ]),

        // PERSYARATAN CHIPS
        if (syarat.isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Persyaratan',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 4,
            children: syarat.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6)),
              child: Text(s, style: const TextStyle(
                  fontSize: 11, color: Colors.black54)),
            )).toList(),
          ),
        ],

        // TUJUAN CHIPS
        if (tujuan.isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Tujuan',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 4,
            children: tujuan.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6)),
              child: Text(t, style: const TextStyle(
                  fontSize: 11, color: Color(0xFF1C4FA1))),
            )).toList(),
          ),
        ],

        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2F80ED))),
              onPressed: () => _isiFormEdit(js),
              icon: const Icon(Icons.edit, size: 16,
                  color: Color(0xFF2F80ED)),
              label: const Text('Edit',
                  style: TextStyle(color: Color(0xFF2F80ED))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red)),
              onPressed: () => _hapus(js['id'], nama),
              icon: const Icon(Icons.delete_outline, size: 16,
                  color: Colors.red),
              label: const Text('Hapus',
                  style: TextStyle(color: Colors.red)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _inp(TextEditingController c, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          filled: true, fillColor: const Color(0xFFF5F7FB),
          prefixIcon: Icon(icon, color: const Color(0xFF2F80ED)),
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _dropdownSeksi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: seksiId,
          isExpanded: true,
          hint: const Text('Pilih Seksi Penanganan'),
          items: seksiNama.entries
              .map((e) => DropdownMenuItem(
                  value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) => setState(() => seksiId = v),
        ),
      ),
    );
  }
}