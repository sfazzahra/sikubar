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

  static const Color _kPrimary     = Color(0xFF2F80ED);
  static const Color _kPrimaryDark = Color(0xFF1B5FC4);
  static const Color _kIconBg      = Color(0xFFEAF4FF);
  static const Color _kTextDark    = Color(0xFF1B2433);

  String _str(String key) => profil![key]?.toString() ?? '-';

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

  Future<void> _simpanProfil(
      String nama, String email, String noHp, String alamat) async {
    try {
      final res = await _api.updateProfilAdmin({
        'name'  : nama,
        'email' : email,
        'no_hp' : noHp,
        'alamat': alamat,
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
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _kPrimary));
    }
    if (profil == null) {
      return const Center(
          child: Text('Gagal memuat profil.',
              style: TextStyle(color: Colors.grey)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _profileSummaryCard(),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _sectionLabel('Informasi Pribadi'),
                const SizedBox(height: 10),
                _infoCard([
                  _infoRow(Icons.person_outline,      'Nama Lengkap', _str('name')),
                  _divider(),
                  _infoRow(Icons.email_outlined,      'Email',        _str('email')),
                  _divider(),
                  _infoRow(Icons.phone_outlined,      'No HP',        _str('no_hp')),
                  _divider(),
                  _infoRow(Icons.location_on_outlined,'Alamat',       _str('alamat')),
                ]),
                const SizedBox(height: 24),
                _sectionLabel('Pengaturan Akun'),
                const SizedBox(height: 10),
                _settingsCard([
                  _settingsRow(
                    icon: Icons.edit_outlined,
                    label: 'Edit Profil',
                    onTap: _showEditModal,
                  ),
                  _divider(),
                  _settingsRow(
                    icon: Icons.lock_outline,
                    label: 'Ganti Password',
                    onTap: _showPasswordModal,
                  ),
                ]),
                const SizedBox(height: 24),
                _logoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PROFILE SUMMARY CARD ───────────────────────────────────────────────────
  Widget _profileSummaryCard() {
    final name    = profil!['name']?.toString() ?? '-';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_kPrimary, _kPrimaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kTextDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kIconBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Administrator',
                    style: TextStyle(
                      color: _kPrimaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _str('email'),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTION LABEL ──────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  // ─── INFO CARD ──────────────────────────────────────────────────────────────
  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _kIconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _kPrimary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _kTextDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SETTINGS CARD ──────────────────────────────────────────────────────────
  Widget _settingsCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _kIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _kPrimary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _kTextDark)),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        thickness: 1,
        indent: 16,
        endIndent: 16,
        color: Colors.grey.shade100,
      );

  // ─── LOGOUT BUTTON ──────────────────────────────────────────────────────────
  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.red.withOpacity(0.4)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
        label: const Text('Logout',
            style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ),
    );
  }

  // ─── MODAL: EDIT PROFIL ─────────────────────────────────────────────────────
  void _showEditModal() {
    final namaCtrl   = TextEditingController(text: profil!['name']?.toString()   ?? '');
    final emailCtrl  = TextEditingController(text: profil!['email']?.toString()  ?? '');
    final hpCtrl     = TextEditingController(text: profil!['no_hp']?.toString()  ?? '');
    final alamatCtrl = TextEditingController(text: profil!['alamat']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _modalHandle(),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Edit Profil',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _kTextDark)),
                ),
                const SizedBox(height: 18),
                _modalInput(namaCtrl,  'Nama Lengkap', Icons.person_outline),
                const SizedBox(height: 12),
                _modalInput(emailCtrl, 'Email', Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _modalInput(hpCtrl, 'No HP', Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _modalInput(alamatCtrl, 'Alamat', Icons.location_on_outlined),
                const SizedBox(height: 22),
                _modalSaveButton(() {
                  Navigator.pop(ctx);
                  _simpanProfil(namaCtrl.text, emailCtrl.text,
                      hpCtrl.text, alamatCtrl.text);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── MODAL: GANTI PASSWORD ──────────────────────────────────────────────────
  void _showPasswordModal() {
    final lamaCtrl = TextEditingController();
    final baruCtrl = TextEditingController();
    final konfCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _modalHandle(),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Ganti Password',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _kTextDark)),
                ),
                const SizedBox(height: 18),
                _modalInput(lamaCtrl, 'Password Lama',           Icons.lock_outline, obscure: true),
                const SizedBox(height: 12),
                _modalInput(baruCtrl, 'Password Baru',           Icons.lock_outline, obscure: true),
                const SizedBox(height: 12),
                _modalInput(konfCtrl, 'Konfirmasi Password Baru',Icons.lock_outline, obscure: true),
                const SizedBox(height: 22),
                _modalSaveButton(() {
                  Navigator.pop(ctx);
                  _gantiPassword(lamaCtrl.text, baruCtrl.text, konfCtrl.text);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── MODAL HELPERS ──────────────────────────────────────────────────────────
  Widget _modalHandle() {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _modalInput(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, size: 19, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.4),
        ),
      ),
    );
  }

  Widget _modalSaveButton(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: const Text('Simpan',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ─── DIALOG: LOGOUT ─────────────────────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('Konfirmasi Logout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin logout?',
            style: TextStyle(fontSize: 13.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}