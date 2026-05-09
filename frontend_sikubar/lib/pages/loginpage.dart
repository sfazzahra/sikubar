import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'daftarpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool obscurePassword = true;
  String? selectedRole;
  bool isLoading = false;

  final TextEditingController identifierController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  Future<void> login() async {

    // VALIDASI ROLE
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih jenis user terlebih dahulu"),
        ),
      );
      return;
    }

    // VALIDASI INPUT
    if (identifierController.text.isEmpty ||
        passwordController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field harus diisi"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.post(

        Uri.parse(
          "http://localhost/SiKubar-PBL/api/login/login.php",
        ),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({
          "identifier": identifierController.text,
          "password": passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        isLoading = false;
      });

      // LOGIN BERHASIL
      if (data['success'] == true) {

        String role = data['role'];

        // VALIDASI ROLE DENGAN DROPDOWN
        if (role != selectedRole) {

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Role tidak sesuai"),
            ),
          );

          return;
        }

        // REDIRECT BERDASARKAN ROLE
        if (role == 'admin') {

          Navigator.pushReplacementNamed(
            context,
            '/admin',
          );

        } else if (role == 'warga') {

          Navigator.pushReplacementNamed(
            context,
            '/beranda',
          );

        } else if (role == 'petugas') {

          Navigator.pushReplacementNamed(
            context,
            '/petugas',
          );

        } else if (role == 'kasi') {

          Navigator.pushReplacementNamed(
            context,
            '/kasi',
          );

        } else if (role == 'camat') {

          Navigator.pushReplacementNamed(
            context,
            '/camat',
          );
        }

      }

      // LOGIN GAGAL
      else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
          ),
        );
      }

    }

    catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(

        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2F80ED),
              Color(0xFF1C4FA1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(

            child: Column(
              children: [

                const Icon(
                  Icons.account_balance,
                  size: 80,
                  color: Colors.white,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Pelayanan Publik",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Text(
                  "Kantor Kecamatan Kundur Barat",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 30),

                Container(

                  margin: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Column(
                    children: [

                      /// DROPDOWN ROLE
                      DropdownButtonFormField<String>(

                        value: selectedRole,

                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person_outline,
                          ),

                          hintText: "Pilih Jenis User",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        items: const [

                          DropdownMenuItem(
                            value: "warga",
                            child: Text("Warga"),
                          ),

                          DropdownMenuItem(
                            value: "petugas",
                            child: Text("Petugas Kecamatan"),
                          ),

                          DropdownMenuItem(
                            value: "kasi",
                            child: Text("Kepala Seksi (kasi)"),
                          ),

                          DropdownMenuItem(
                            value: "camat",
                            child: Text("Camat"),
                          ),

                             DropdownMenuItem(
                            value: "admin",
                            child: Text("Admin"),
                          ),
                        ],

                        onChanged: (value) {

                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      /// IDENTIFIER
                      TextField(

                        controller: identifierController,

                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),

                          hintText: "NIK/Email",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// PASSWORD
                      TextField(

                        controller: passwordController,

                        obscureText: obscurePassword,

                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),

                          hintText: "Kata Sandi",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
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

                      const SizedBox(height: 10),

                      Align(

                        alignment: Alignment.centerRight,

                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Lupa password?"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// BUTTON MASUK
                      SizedBox(

                        width: double.infinity,
                        height: 45,

                        child: ElevatedButton(

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C4FA1),
                          ),

                          onPressed: isLoading
                              ? null
                              : () {
                                  login();
                                },

                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Masuk",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// BELUM PUNYA AKUN
                      Row(

                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          const Text("Belum punya akun? "),

                          GestureDetector(

                            onTap: () {

                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterPage(),
                                ),
                              );
                            },

                            child: const Text(
                              "Daftar di sini",

                              style: TextStyle(
                                color: Color(0xFF1C4FA1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "© Kantor Kecamatan Kundur Barat",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}