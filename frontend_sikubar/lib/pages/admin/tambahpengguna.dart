import 'package:flutter/material.dart';
import '../../services/api_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// TAB 1 — PENGGUNA
// ══════════════════════════════════════════════════════════════════════════════
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

  String role    = 'warga';
  int?   seksiId;
  bool   showForm  = false;
  bool   isLoading = false;
  bool   isSaving  = false;

  // Dikelompokkan: role → list user
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

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getUsers();
      final list = List<Map<String, dynamic>>.from(
          res['data']['data'] ?? []);
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
        'name'                  : namaCtrl.text.trim(),
        'role'                  : role,
        'password'              : passCtrl.text,
        'password_confirmation' : konfCtrl.text,
        'no_hp'                 : hpCtrl.text.trim(),
      };
      if (role == 'warga') body['nik'] = nikCtrl.text.trim();
      else body['email'] = emailCtrl.text.trim();
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
        title: const Text('Hapus Akun'),
        content: Text('Hapus akun "$nama"?'),
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
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  onPressed: () => setState(() => showForm = !showForm),
                  icon: Icon(showForm ? Icons.close : Icons.person_add,
                      color: Colors.white),
                  label: Text(showForm ? 'Tutup Form' : 'Tambah Pengguna',
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
                    _dropdownRole(),
                    const SizedBox(height: 12),
                    _inp(namaCtrl, 'Nama Lengkap', Icons.person_outline),
                    if (role == 'warga')
                      _inp(nikCtrl, 'NIK (16 digit)', Icons.badge_outlined,
                          type: TextInputType.number),
                    if (role != 'warga')
                      _inp(emailCtrl, 'Email', Icons.email_outlined,
                          type: TextInputType.emailAddress),
                    if (role == 'petugas' || role == 'kasi')
                      _dropdownSeksi(),
                    _inp(hpCtrl, 'No HP', Icons.phone_outlined,
                        type: TextInputType.phone),
                    _inp(passCtrl, 'Password', Icons.lock_outline,
                        obscure: true),
                    _inp(konfCtrl, 'Konfirmasi Password', Icons.lock_outline,
                        obscure: true),
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
                            : const Text('Simpan',
                                style: TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                ),
              ],

              const SizedBox(height: 20),

              // DAFTAR TERKELOMPOK
              Row(children: [
                const Text('Daftar Pengguna',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFF2F80ED))),
              ]),
              const SizedBox(height: 8),

              ...roleOrder.map((r) {
  final list = grouped[r];

  if (list == null || list.isEmpty) {
    return const SizedBox();
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
        ),
      ],
    ),
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      leading: CircleAvatar(
        backgroundColor: _roleColor(r).withOpacity(0.15),
        child: Icon(
          _roleIcon(r),
          color: _roleColor(r),
        ),
      ),
      title: Text(
        roleLabel[r] ?? r,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _roleColor(r),
        ),
      ),
      subtitle: Text('${list.length} pengguna'),
      children: [
        ...list.map((u) => _userCard(u, r)),
      ],
    ),
  );
}),
            ]),
          );
  }

  Widget _userCard(Map<String, dynamic> u, String r) {
    final nama  = u['name'] ?? '-';
    final sub   = u['email'] ?? u['nik'] ?? '-';
    final seksi = u['seksi']?['nama'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: _roleColor(r).withOpacity(0.15),
          child: Text(
            nama.isNotEmpty ? nama[0].toUpperCase() : '?',
            style: TextStyle(
                color: _roleColor(r), fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(nama, style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(
              color: Colors.grey, fontSize: 12)),
          if (seksi != null)
            Text(seksi, style: const TextStyle(
                color: Colors.blueGrey, fontSize: 11)),
        ])),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onPressed: () => _hapus(u['id'], nama),
        ),
      ]),
    );
  }

  Color _roleColor(String r) {
    switch (r) {
      case 'admin'  : return Colors.purple;
      case 'camat'  : return Colors.indigo;
      case 'kasi'   : return Colors.blue;
      case 'petugas': return Colors.teal;
      default       : return Colors.orange;
    }
  }

  IconData _roleIcon(String r) {
    switch (r) {
      case 'admin'  : return Icons.admin_panel_settings;
      case 'camat'  : return Icons.account_balance;
      case 'kasi'   : return Icons.supervisor_account;
      case 'petugas': return Icons.badge;
      default       : return Icons.person;
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

  Widget _dropdownRole() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: role,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'warga',   child: Text('Warga')),
            DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
            DropdownMenuItem(value: 'kasi',    child: Text('Kasi')),
            DropdownMenuItem(value: 'camat',   child: Text('Camat')),
            DropdownMenuItem(value: 'admin',   child: Text('Admin')),
          ],
          onChanged: (v) => setState(() { role = v!; seksiId = null; }),
        ),
      ),
    );
  }

  Widget _dropdownSeksi() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
            color: const Color(0xFFF5F7FB),
            borderRadius: BorderRadius.circular(16)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: seksiId,
            isExpanded: true,
            hint: const Text('Pilih Seksi'),
            items: seksiNama.entries
                .map((e) => DropdownMenuItem(
                    value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => seksiId = v),
          ),
        ),
      ),
    );
  }
}