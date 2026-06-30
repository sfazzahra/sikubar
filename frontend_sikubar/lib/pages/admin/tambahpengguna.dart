import 'package:flutter/material.dart';
import '../../services/api_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// TAB 1 — PENGGUNA — background putih
// ══════════════════════════════════════════════════════════════════════════════

const Color _kPrimary     = Color(0xFF2F80ED);
const Color _kPrimaryDark = Color(0xFF1C4FA1);
const Color _kBg          = Color(0xFFF5F7FB);
const Color _kGradStart   = Color(0xFF0B2B5C);
const Color _kGradEnd     = Color(0xFF1C4FA1);

class AdminPenggunaTab extends StatefulWidget {
  const AdminPenggunaTab({super.key});

  @override
  State<AdminPenggunaTab> createState() => _AdminPenggunaTabState();
}

class _AdminPenggunaTabState extends State<AdminPenggunaTab> {
  final _api = ApiService();

  final namaCtrl  = TextEditingController();
  final nikCtrl   = TextEditingController();
  final emailCtrl = TextEditingController();
  final hpCtrl    = TextEditingController();
  final passCtrl  = TextEditingController();
  final konfCtrl  = TextEditingController();

  String role     = 'warga';
  int?   seksiId;
  bool   showForm  = false;
  bool   isLoading = false;
  bool   isSaving  = false;

  Map<String, List<Map<String, dynamic>>> grouped = {};

  static const Map<int, String> seksiNama = {
    1: 'Seksi Pemerintah',
    2: 'Seksi Ketentraman dan Ketertiban',
    3: 'Seksi Pemberdayaan Masyarakat',
    4: 'Seksi Kesejahteraan Sosial',
    5: 'Seksi Lingkungan Hidup',
  };

  static const Map<String, String> roleLabel = {
    'admin'  : 'Admin',
    'camat'  : 'Camat',
    'kasi'   : 'Kasi',
    'petugas': 'Petugas',
    'warga'  : 'Warga',
  };

  static const List<String> roleOrder = [
    'admin', 'camat', 'kasi', 'petugas', 'warga',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    namaCtrl.dispose(); nikCtrl.dispose(); emailCtrl.dispose();
    hpCtrl.dispose(); passCtrl.dispose(); konfCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final res  = await _api.getUsers();
      final list = List<Map<String, dynamic>>.from(res['data']['data'] ?? []);
      final Map<String, List<Map<String, dynamic>>> g = {};
      for (final u in list) {
        final r = u['role'] as String? ?? 'warga';
        g.putIfAbsent(r, () => []).add(u);
      }
      setState(() => grouped = g);
    } catch (_) {
      _snack('Gagal memuat pengguna.', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _simpan() async {
    if (namaCtrl.text.trim().isEmpty || passCtrl.text.isEmpty) {
      _snack('Nama dan password wajib diisi.', isError: true); return;
    }
    if (passCtrl.text != konfCtrl.text) {
      _snack('Konfirmasi password tidak cocok.', isError: true); return;
    }
    if (role == 'warga' && nikCtrl.text.trim().length != 16) {
      _snack('NIK harus 16 digit.', isError: true); return;
    }
    if (role != 'warga' && emailCtrl.text.trim().isEmpty) {
      _snack('Email wajib diisi.', isError: true); return;
    }
    if ((role == 'petugas' || role == 'kasi') && seksiId == null) {
      _snack('Pilih seksi.', isError: true); return;
    }

    setState(() => isSaving = true);
    try {
      final body = <String, dynamic>{
        'name'                 : namaCtrl.text.trim(),
        'role'                 : role,
        'password'             : passCtrl.text,
        'password_confirmation': konfCtrl.text,
        'no_hp'                : hpCtrl.text.trim(),
      };
      if (role == 'warga') body['nik']   = nikCtrl.text.trim();
      else                 body['email'] = emailCtrl.text.trim();
      if (role == 'petugas' || role == 'kasi') body['seksi_id'] = seksiId;

      await _api.createUser(body);
      _snack('Akun berhasil dibuat.');
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
        title: const Text('Hapus Akun',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Akun "$nama" akan dihapus secara permanen.',
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
      await _api.deleteUser(id);
      _snack('Akun dihapus.');
      await _load();
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    }
  }

  void _resetForm() {
    namaCtrl.clear(); nikCtrl.clear(); emailCtrl.clear();
    hpCtrl.clear(); passCtrl.clear(); konfCtrl.clear();
    setState(() { role = 'warga'; seksiId = null; showForm = false; });
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── SUMMARY HEADER ─────────────────────────────────────────────────────────
  int get _totalUsers =>
      grouped.values.fold(0, (sum, list) => sum + list.length);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _kBg,
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── SUMMARY CARD ──────────────────────────────────────────────
                _summaryCard(),
                const SizedBox(height: 20),

                // ── TOMBOL TAMBAH ─────────────────────────────────────────────
                _addButton(),

                // ── FORM ──────────────────────────────────────────────────────
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
                  const Text('Daftar Pengguna',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2433))),
                  const Spacer(),
                  GestureDetector(
                    onTap: _load,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2)),
                          ]),
                      child: const Icon(Icons.refresh_rounded,
                          color: _kPrimary, size: 18),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),

                // ── ROLE GROUPS ───────────────────────────────────────────────
                if (_totalUsers == 0)
                  _emptyState()
                else
                  ...roleOrder.map((r) {
                    final list = grouped[r];
                    if (list == null || list.isEmpty) return const SizedBox();
                    return _roleGroup(r, list);
                  }),
              ]),
            ),
    );
  }

  // ── SUMMARY CARD ──────────────────────────────────────────────────────────
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kGradStart, _kGradEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _kGradEnd.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.group_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Pengguna',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text('$_totalUsers Akun',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
          // mini breakdown
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            ...roleOrder.where((r) => grouped[r] != null).map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '${roleLabel[r]}: ${grouped[r]!.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            )),
          ]),
        ],
      ),
    );
  }

  // ── ADD BUTTON ────────────────────────────────────────────────────────────
  Widget _addButton() {
    return GestureDetector(
      onTap: () => setState(() { if (showForm) _resetForm(); else showForm = true; }),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: showForm ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: showForm ? [] : [
            BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(showForm ? Icons.close_rounded : Icons.person_add_rounded,
              color: showForm ? const Color(0xFF1B2433) : _kPrimary, size: 20),
          const SizedBox(width: 8),
          Text(showForm ? 'Tutup Form' : 'Tambah Pengguna Baru',
              style: TextStyle(
                  color: showForm ? const Color(0xFF1B2433) : _kPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
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
              color: Colors.black.withOpacity(0.08),
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
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.person_add_rounded,
                color: _kPrimary, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Data Pengguna Baru',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1B2433))),
        ]),
        const SizedBox(height: 20),

        // Role selector chips
        _roleSelectorChips(),
        const SizedBox(height: 16),

        _inp(namaCtrl, 'Nama Lengkap', Icons.person_outline),
        if (role == 'warga')
          _inp(nikCtrl, 'NIK (16 digit)', Icons.badge_outlined,
              type: TextInputType.number),
        if (role != 'warga')
          _inp(emailCtrl, 'Email', Icons.email_outlined,
              type: TextInputType.emailAddress),
        if (role == 'petugas' || role == 'kasi') ...[
          _dropdownSeksi(),
          const SizedBox(height: 12),
        ],
        _inp(hpCtrl, 'No HP', Icons.phone_outlined,
            type: TextInputType.phone),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Keamanan',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600)),
            ),
            Expanded(child: Divider()),
          ]),
        ),

        _inp(passCtrl, 'Password', Icons.lock_outline, obscure: true),
        _inp(konfCtrl, 'Konfirmasi Password', Icons.lock_outline, obscure: true),
        const SizedBox(height: 8),

        // Save button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            onPressed: isSaving ? null : _simpan,
            child: isSaving
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Buat Akun',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
          ),
        ),
      ]),
    );
  }

  // ── ROLE SELECTOR CHIPS ────────────────────────────────────────────────────
  Widget _roleSelectorChips() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Role / Jabatan',
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['warga', 'petugas', 'kasi', 'camat', 'admin'].map((r) {
          final selected = role == r;
          final color    = _roleColor(r);
          return GestureDetector(
            onTap: () => setState(() { role = r; seksiId = null; }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? color : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? color : color.withOpacity(0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_roleIcon(r),
                    size: 14,
                    color: selected ? Colors.white : color),
                const SizedBox(width: 6),
                Text(roleLabel[r] ?? r,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : color)),
              ]),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  // ── ROLE GROUP ─────────────────────────────────────────────────────────────
  Widget _roleGroup(String r, List<Map<String, dynamic>> list) {
    final color = _roleColor(r);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          shape: const Border(),
          leading: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(_roleIcon(r), color: color, size: 20),
          ),
          title: Text(roleLabel[r] ?? r,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color)),
          subtitle: Text('${list.length} pengguna',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text('${list.length}',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          children: list.map((u) => _userCard(u, r)).toList(),
        ),
      ),
    );
  }

  // ── USER CARD ──────────────────────────────────────────────────────────────
  Widget _userCard(Map<String, dynamic> u, String r) {
    final nama  = u['name']  ?? '-';
    final sub   = u['email'] ?? u['nik'] ?? '-';
    final seksi = u['seksi']?['nama'] as String?;
    final color = _roleColor(r);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: Text(
            nama.isNotEmpty ? nama[0].toUpperCase() : '?',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(nama,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: Color(0xFF1B2433))),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 12)),
          if (seksi != null) ...[
            const SizedBox(height: 2),
            Text(seksi,
                style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ])),
        GestureDetector(
          onTap: () => _hapus(u['id'], nama),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.delete_outline_rounded,
                color: Colors.red, size: 18),
          ),
        ),
      ]),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text('Belum ada pengguna.',
              style: TextStyle(color: Colors.grey.shade600)),
        ]),
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────
  Color _roleColor(String r) {
    switch (r) {
      case 'admin'  : return const Color(0xFF7C3AED);
      case 'camat'  : return const Color(0xFF1B5FC4);
      case 'kasi'   : return const Color(0xFF2F80ED);
      case 'petugas': return const Color(0xFF0D9488);
      default       : return const Color(0xFFF97316);
    }
  }

  IconData _roleIcon(String r) {
    switch (r) {
      case 'admin'  : return Icons.admin_panel_settings_rounded;
      case 'camat'  : return Icons.account_balance_rounded;
      case 'kasi'   : return Icons.supervisor_account_rounded;
      case 'petugas': return Icons.badge_rounded;
      default       : return Icons.person_rounded;
    }
  }

  Widget _inp(TextEditingController c, String label, IconData icon,
      {bool obscure = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: type,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: Icon(icon, color: _kPrimary, size: 19),
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
        ),
      ),
    );
  }

  Widget _dropdownSeksi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: seksiId,
          isExpanded: true,
          hint: Text('Pilih Seksi',
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