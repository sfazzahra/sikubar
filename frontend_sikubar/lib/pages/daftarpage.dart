import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool obscurePassword = true;
  bool obscureConfirm = true;

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
                  "Registrasi Warga",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Text(
                  "Kantor Kecamatan Kundur Barat",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 30),

                Container(
                  margin: const EdgeInsets.fromLTRB(30, 0, 30, 40), // ⬅️ jarak bawah
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Column(
                    children: [

                      /// Nama Lengkap
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          hintText: "Nama Lengkap",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// NIK
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.badge),
                          hintText: "NIK",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Email
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          hintText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Nomor HP
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone),
                          hintText: "Nomor HP",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Alamat
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on),
                          hintText: "Alamat",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Password
                      TextField(
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

                      const SizedBox(height: 12),

                      /// Konfirmasi Password
                      TextField(
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          hintText: "Konfirmasi Kata Sandi",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// BUTTON DAFTAR
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C4FA1),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "DAFTAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// SUDAH PUNYA AKUN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          const Text("Sudah punya akun? "),

                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Masuk",
                              style: TextStyle(
                                color: Color(0xFF1C4FA1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
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