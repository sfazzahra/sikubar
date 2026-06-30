import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;
  String? selectedRole;
  bool isLoading = false;

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  static const Color primaryDark = Color(0xFF0B2B5C);
  static const Color primary = Color(0xFF1C4FA1);
  static const Color primaryLight = Color(0xFF2F80ED);
  static const Color ink = Color(0xFF0F1B33);

  // ── HELPER: apakah role yang dipilih warga? ─────────────────────────────
  bool get _isWarga => selectedRole == 'warga';

  Future<void> login() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar("Pilih jenis user terlebih dahulu"),
      );
      return;
    }

    if (identifierController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar("Semua field harus diisi"),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String endpoint = selectedRole == 'warga'
          ? "http://127.0.0.1:8000/api/warga/login"
          : "http://127.0.0.1:8000/api/staff/login";

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(
          selectedRole == 'warga'
              ? {
                  "nik": identifierController.text,
                  "password": passwordController.text,
                }
              : {
                  "email": identifierController.text,
                  "password": passwordController.text,
                },
        ),
      );

      final data = jsonDecode(response.body);
      print(data);

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        String role = data['data']?['user']?['role']?.toString() ?? '';
        final token = data['data']?['token']?.toString() ?? '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (role != selectedRole) {
          ScaffoldMessenger.of(context).showSnackBar(
            _buildSnackBar("Role tidak sesuai"),
          );
          return;
        }

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (role == 'warga') {
          Navigator.pushReplacementNamed(context, '/beranda');
        } else if (role == 'petugas') {
          Navigator.pushReplacementNamed(context, '/petugas');
        } else if (role == 'kasi') {
          Navigator.pushReplacementNamed(context, '/kasi');
        } else if (role == 'camat') {
          Navigator.pushReplacementNamed(context, '/camat');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar(data['message'] ?? 'Login gagal'),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar("Terjadi kesalahan: $e"),
      );
    }
  }

  SnackBar _buildSnackBar(String message) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      content: Text(message, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      body: Stack(
        children: [
          // ── BACKGROUND dari kode 2 ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryDark, primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -90,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  gradient: LinearGradient(
                    colors: [
                      primaryLight.withOpacity(0.35),
                      primaryLight.withOpacity(0.0),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 40,
                ),
              ),
            ),
          ),

          // ── KONTEN ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  children: [
                    // Logo + nama instansi
                    Image.asset(
                      'assets/images/LogoSiKubar.png',
                      width: 90,
                      height: 90,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Pelayanan Publik",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Kantor Kecamatan Kundur Barat",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── CARD / KOTAK PUTIH (dari kode 1) ──
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dropdown role
                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_outline),
                              hintText: "Pilih Jenis User",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: "warga", child: Text("Warga")),
                              DropdownMenuItem(value: "petugas", child: Text("Petugas Kecamatan")),
                              DropdownMenuItem(value: "kasi", child: Text("Kepala Seksi (Kasi)")),
                              DropdownMenuItem(value: "camat", child: Text("Camat")),
                              DropdownMenuItem(value: "admin", child: Text("Admin")),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value;
                                // reset input identifier setiap ganti role,
                                // karena format NIK vs Email berbeda
                                identifierController.clear();
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── NIK (warga) / Email (staff) — menyesuaikan role ──
                          TextField(
                            controller: identifierController,
                            enabled: selectedRole != null,
                            keyboardType: selectedRole == null
                                ? TextInputType.text
                                : (_isWarga
                                    ? TextInputType.number
                                    : TextInputType.emailAddress),
                            inputFormatters: null,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                selectedRole == null
                                    ? Icons.person
                                    : (_isWarga
                                        ? Icons.badge_outlined
                                        : Icons.email_outlined),
                              ),
                              hintText: selectedRole == null
                                  ? "Pilih jenis user dahulu"
                                  : (_isWarga ? "NIK (16 digit)" : "Email"),
                              labelText: selectedRole == null
                                  ? null
                                  : (_isWarga ? "NIK" : "Email"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            enabled: selectedRole != null,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              hintText: "Kata Sandi",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: primary,
                                  width: 2,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tombol Masuk
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : login,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : const Text(
                                      "Masuk",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Center(
                            child: Text(
                              "© Kantor Kecamatan Kundur Barat",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}