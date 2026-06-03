import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProfileKasiPage extends StatefulWidget {
  const ProfileKasiPage({super.key});

  @override
  State<ProfileKasiPage> createState() => _ProfileKasiPageState();
}

class _ProfileKasiPageState extends State<ProfileKasiPage> {
  final _api = ApiService();

  Map<String, dynamic>? profil;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.getProfilKasi();
      setState(() => profil = res['data']);
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    } catch (_) {
      _snack('Gagal memuat profil.', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _simpanProfil(String nama, String alamat, String noHp) async {
    try {
      final res = await _api.updateProfilKasi({
        'name'  : nama,
        'alamat': alamat,
        'no_hp' : noHp,
      });
      setState(() => profil = res['data']);
      _snack('Profil berhasil diperbarui.');
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    }
  }

  Future<void> _gantiPassword(
      String lama, String baru, String konfirmasi) async {
    if (baru != konfirmasi) {
      _snack('Konfirmasi password tidak cocok.', isError: true);
      return;
    }
    try {
      await _api.updateProfilKasiPassword(lama, baru, konfirmasi);
      _snack('Password berhasil diganti.');
    } on ApiException catch (e) {
      _snack(e.message, isError: true);
    }
  }

  Future<void> _logout() async {
    await _api.logoutKasi();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  // ── TEMA WARNA SAMA DENGAN PETUGAS ──────────────────────
static const Color _gradientStart = Color(0xFF2F80ED);
static const Color _gradientEnd   = Color(0xFF56CCF2);
static const Color _cardColor     = Color(0xFF5EB6E7);
static const Color _accentColor   = Color(0xFF1C4FA1);
static const Color _iconBgColor   = Color(0xFFEAF4FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradientStart, _gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // HEADER
            SizedBox(
              height: 90,
              child: Stack(children: [
                if (Navigator.canPop(context))
                  Positioned(
                    left: 16, top: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 26),
                    ),
                  ),
                const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.account_balance, color: Colors.white, size: 32),
                    SizedBox(height: 6),
                    Text('Profil Kasi',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),
            ),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : profil == null
                      ? const Center(
                          child: Text('Gagal memuat profil.',
                              style: TextStyle(color: Colors.white)))
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: _cardColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8))
                                ],
                              ),
                              child: Column(children: [
                                // AVATAR
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [
                                      _gradientEnd,
                                      _gradientStart,
                                    ]),
                                  ),
                                  child: CircleAvatar(
                                    radius: 52,
                                    backgroundColor: _gradientStart,
                                    child: Text(
                                      (profil!['name']?.toString() ?? '').isNotEmpty
                                          ? (profil!['name']?.toString() ?? '')[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 36, color: Colors.white),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Text(profil!['name']?.toString() ?? '-',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),

                                const SizedBox(height: 6),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.20),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text('Kasi Aktif',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                ),

                                const SizedBox(height: 24),

                                _profileItem(Icons.person_outline,       'Nama Lengkap',
                                    profil!['name']?.toString() ?? '-'),
                                _profileItem(Icons.email_outlined,       'Email',
                                    profil!['email']?.toString() ?? '-'),
                                _profileItem(Icons.location_on_outlined, 'Alamat',
                                    profil!['alamat']?.toString() ?? '-'),
                                _profileItem(Icons.phone_outlined,       'No HP',
                                    profil!['no_hp']?.toString() ?? '-'),

                                const SizedBox(height: 24),

                                _actionButton(
                                  Icons.edit_rounded,
                                  'Edit Profil',
                                  Colors.white,
                                  _accentColor,
                                  () => _showEditModal(),
                                ),
                                const SizedBox(height: 10),
                                _actionButton(
                                  Icons.lock_outline,
                                  'Ganti Password',
                                  Colors.white,
                                  _accentColor,
                                  () => _showPasswordModal(),
                                ),
                                const SizedBox(height: 10),
                                _actionButton(
                                  Icons.logout_rounded,
                                  'Logout',
                                  Colors.red,
                                  Colors.white,
                                  () => _showLogoutDialog(),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 40),
                          ]),
                        ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── WIDGETS ──────────────────────────────────────────────────────────────

  static Widget _profileItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: _iconBgColor,
              borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: _gradientStart, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1B1B1B))),
          ]),
        ),
      ]),
    );
  }

  Widget _actionButton(IconData icon, String label, Color bgColor,
      Color fgColor, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── MODAL EDIT PROFIL ────────────────────────────────────────────────────
  void _showEditModal() {
    final namaCtrl   = TextEditingController(text: profil!['name']?.toString() ?? '');
    final alamatCtrl = TextEditingController(text: profil!['alamat']?.toString() ?? '');
    final hpCtrl     = TextEditingController(text: profil!['no_hp']?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 50, height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20)),
            ),
            const SizedBox(height: 20),
            const Text('Edit Profil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _modalInput(namaCtrl,   'Nama Lengkap', Icons.person),
            const SizedBox(height: 14),
            _modalInput(alamatCtrl, 'Alamat',       Icons.location_on),
            const SizedBox(height: 14),
            _modalInput(hpCtrl,     'No HP',        Icons.phone,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18))),
                onPressed: () {
                  Navigator.pop(ctx);
                  _simpanProfil(
                      namaCtrl.text, alamatCtrl.text, hpCtrl.text);
                },
                child: const Text('Simpan',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }

  // ── MODAL GANTI PASSWORD ─────────────────────────────────────────────────
  void _showPasswordModal() {
    final lamaCtrl = TextEditingController();
    final baruCtrl = TextEditingController();
    final konfCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 50, height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20)),
            ),
            const SizedBox(height: 20),
            const Text('Ganti Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _modalInput(lamaCtrl, 'Password Lama', Icons.lock_outline,
                obscure: true),
            const SizedBox(height: 14),
            _modalInput(baruCtrl, 'Password Baru', Icons.lock, obscure: true),
            const SizedBox(height: 14),
            _modalInput(konfCtrl, 'Konfirmasi Password Baru', Icons.lock,
                obscure: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18))),
                onPressed: () {
                  Navigator.pop(ctx);
                  _gantiPassword(
                      lamaCtrl.text, baruCtrl.text, konfCtrl.text);
                },
                child: const Text('Simpan',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }

  Widget _modalInput(TextEditingController ctrl, String label, IconData icon,
      {bool obscure = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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