import 'package:flutter/material.dart';
import '../../services/api_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// TAB 3 — PROFIL ADMIN
// ══════════════════════════════════════════════════════════════════════════════
class AdminProfilTab extends StatefulWidget {
  const AdminProfilTab({super.key});

  @override
  State<AdminProfilTab> createState() => _AdminProfilTabState();
}

class _AdminProfilTabState extends State<AdminProfilTab> {
  final _api = ApiService();

  Map<String, dynamic>? profil;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getProfilAdmin();
      setState(() => profil = res['data']);
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    } catch (_) {
      _snack('Gagal memuat profil.', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Menerima alamat sebagai parameter tambahan
  Future<void> _simpanProfil(
      String nama, String email, String noHp, String alamat) async {
    try {
      final res = await _api.updateProfilAdmin({
        'name'   : nama,
        'email'  : email,
        'no_hp'  : noHp,
        'alamat' : alamat,
      });
      setState(() => profil = res['data']);
      _snack('Profil berhasil diperbarui.');
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    }
  }

  Future<void> _gantiPassword(
      String lama, String baru, String konf) async {
    if (baru != konf) {
      _snack('Konfirmasi password tidak cocok.', isError: true);
      return;
    }
    try {
      await _api.updatePasswordAdmin(lama, baru, konf);
      _snack('Password berhasil diganti.');
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    }
  }

  Future<void> _logout() async {
    await _api.logout(isWarga: false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (profil == null) {
      return const Center(child: Text('Gagal memuat profil.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Avatar + nama
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)]),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              child: Text(
                (profil!['name'] ?? '?').toString().isNotEmpty
                    ? (profil!['name'] as String)[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 32, color: Color(0xFF2F80ED),
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),
            Text(profil!['name'] ?? '-',
                style: const TextStyle(
                    fontSize: 20, color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('Administrator',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ]),
        ),

        const SizedBox(height: 20),

        // Info profil
        _infoCard(Icons.email_outlined, 'Email',
            profil!['email'] ?? '-'),
        _infoCard(Icons.phone_outlined, 'No HP',
            profil!['no_hp'] ?? '-'),
        _infoCard(Icons.location_on_outlined, 'Alamat',
            profil!['alamat'] ?? '-'),

        const SizedBox(height: 20),

        _actionBtn(Icons.edit_rounded, 'Edit Profil',
            const Color(0xFF2F80ED), Colors.white,
            () => _showEditModal()),
        const SizedBox(height: 10),
        _actionBtn(Icons.lock_outline, 'Ganti Password',
            const Color(0xFF1C4FA1), Colors.white,
            () => _showPasswordModal()),
        const SizedBox(height: 10),
        _actionBtn(Icons.logout_rounded, 'Logout',
            Colors.red, Colors.white,
            () => _showLogoutDialog()),
      ]),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF2F80ED), size: 20),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color bg, Color fg,
      VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: bg, foregroundColor: fg,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16))),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showEditModal() {
    final namaCtrl   = TextEditingController(text: profil!['name'] ?? '');
    final emailCtrl  = TextEditingController(text: profil!['email'] ?? '');
    final hpCtrl     = TextEditingController(text: profil!['no_hp'] ?? '');
    final alamatCtrl = TextEditingController(text: profil!['alamat'] ?? '');

    _bottomSheet('Edit Profil', [
      _modalInp(namaCtrl,  'Nama Lengkap', Icons.person),
      const SizedBox(height: 12),
      _modalInp(emailCtrl, 'Email', Icons.email,
          type: TextInputType.emailAddress),
      const SizedBox(height: 12),
      _modalInp(hpCtrl,    'No HP', Icons.phone,
          type: TextInputType.phone),
      const SizedBox(height: 12),
      _modalInp(alamatCtrl, 'Alamat', Icons.location_on_outlined,
          maxLines: 3),
    ], onSave: () {
      Navigator.pop(context);
      _simpanProfil(
          namaCtrl.text, emailCtrl.text, hpCtrl.text, alamatCtrl.text);
    });
  }

  void _showPasswordModal() {
    final lamaCtrl = TextEditingController();
    final baruCtrl = TextEditingController();
    final konfCtrl = TextEditingController();
    _bottomSheet('Ganti Password', [
      _modalInp(lamaCtrl, 'Password Lama', Icons.lock_outline,
          obscure: true),
      const SizedBox(height: 12),
      _modalInp(baruCtrl, 'Password Baru', Icons.lock, obscure: true),
      const SizedBox(height: 12),
      _modalInp(konfCtrl, 'Konfirmasi Password Baru', Icons.lock,
          obscure: true),
    ], onSave: () {
      Navigator.pop(context);
      _gantiPassword(lamaCtrl.text, baruCtrl.text, konfCtrl.text);
    });
  }

  void _bottomSheet(String title, List<Widget> fields,
      {required VoidCallback onSave}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 44, height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...fields,
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C4FA1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                onPressed: onSave,
                child: const Text('Simpan',
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _modalInp(TextEditingController ctrl, String label, IconData icon,
      {bool obscure = false, TextInputType type = TextInputType.text,
       int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      maxLines: obscure ? 1 : maxLines,
      minLines: 1,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true, fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Yakin ingin logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () { Navigator.pop(context); _logout(); },
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}