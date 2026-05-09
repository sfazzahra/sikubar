import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final emailController = TextEditingController();
  final hpController = TextEditingController();
  final passwordController = TextEditingController();

  /// DEFAULT ROLE HARUS SAMA DENGAN VALUE DROPDOWN
  String role = "warga";

  bool showForm = false;

  List<Map<String, String>> users = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,

        title: const Text(
          "Dashboard Admin",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// CARD WELCOME
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2F80ED),
                    Color(0xFF56CCF2),
                  ],
                ),

                borderRadius: BorderRadius.circular(25),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Selamat Datang Admin 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Kelola akun user dengan mudah",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// BUTTON TAMBAH USER
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2F80ED),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),

                onPressed: () {

                  setState(() {
                    showForm = !showForm;
                  });
                },

                icon: const Icon(
                  Icons.person_add,
                  color: Colors.white,
                ),

                label: Text(
                  showForm
                      ? "Tutup Form"
                      : "Tambah User",

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// FORM TAMBAH USER
            if (showForm)
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(25),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    buildInput(
                      controller: namaController,
                      label: "Nama Lengkap",
                      icon: Icons.person_outline,
                    ),

                    buildInput(
                      controller: nikController,
                      label: "NIK",
                      icon: Icons.badge_outlined,
                    ),

                    buildInput(
                      controller: emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                    ),

                    buildInput(
                      controller: hpController,
                      label: "No HP",
                      icon: Icons.phone_outlined,
                    ),

                    buildInput(
                      controller: passwordController,
                      label: "Password",
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),

                    const SizedBox(height: 15),

                    /// DROPDOWN ROLE
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),

                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFF5F7FB),

                        borderRadius:
                            BorderRadius.circular(18),
                      ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: role,
                          isExpanded: true,

                          items: const [

                            DropdownMenuItem(
                              value: "warga",
                              child: Text("Warga"),
                            ),

                            DropdownMenuItem(
                              value: "petugas",
                              child: Text(
                                "Petugas Kecamatan",
                              ),
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
                              role = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// BUTTON SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2F80ED),

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                        ),

                        onPressed: () {

                          /// VALIDASI
                          if (namaController
                                  .text.isEmpty ||
                              emailController
                                  .text.isEmpty ||
                              passwordController
                                  .text.isEmpty) {

                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Semua data wajib diisi",
                                ),
                              ),
                            );

                            return;
                          }

                          /// TAMBAH USER
                          setState(() {

                            users.add({
                              "nama":
                                  namaController.text,
                              "email":
                                  emailController.text,
                              "role": role,
                            });
                          });

                          /// CLEAR FORM
                          namaController.clear();
                          nikController.clear();
                          emailController.clear();
                          hpController.clear();
                          passwordController.clear();

                          /// RESET ROLE
                          role = "warga";

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "User berhasil ditambahkan",
                              ),
                            ),
                          );
                        },

                        child: const Text(
                          "Simpan User",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            /// TITLE USER
            const Text(
              "Daftar User",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            /// LIST USER
            users.isEmpty

                ? Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(30),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: const Center(
                      child: Text(
                        "Belum ada user",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )

                : ListView.builder(
                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount: users.length,

                    itemBuilder: (context, index) {

                      final user = users[index];

                      return Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 15,
                        ),

                        padding:
                            const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),

                              blurRadius: 8,
                            ),
                          ],
                        ),

                        child: Row(
                          children: [

                            /// AVATAR
                            CircleAvatar(
                              backgroundColor:
                                  const Color(
                                0xFF2F80ED,
                              ),

                              child: Text(

                                user["nama"] != null &&
                                        user["nama"]!
                                            .isNotEmpty

                                    ? user["nama"]![0]
                                        .toUpperCase()

                                    : "?",

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(width: 15),

                            /// DATA USER
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(
                                    user["nama"] ??
                                        "-",

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 4),

                                  Text(
                                    user["email"] ??
                                        "-",

                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// ROLE
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),

                              decoration:
                                  BoxDecoration(
                                color: const Color(
                                  0xFFEAF2FF,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  15,
                                ),
                              ),

                              child: Text(
                                user["role"] ?? "-",

                                style:
                                    const TextStyle(
                                  color: Color(
                                    0xFF2F80ED,
                                  ),

                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextField(
        controller: controller,
        obscureText: obscureText,

        decoration: InputDecoration(
          filled: true,

          fillColor:
              const Color(0xFFF5F7FB),

          prefixIcon: Icon(
            icon,
            color: const Color(0xFF2F80ED),
          ),

          labelText: label,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),

            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}