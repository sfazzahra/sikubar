import 'package:flutter/material.dart';
import '../../widgets/bottom_menuwarga.dart';
import '../../ds.dart';
import '../../model/mprofil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    final profil = DataStore.profil;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2F80ED),
              Color(0xFF56CCF2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              /// HEADER
              SizedBox(
                height: 90,
                child: Stack(
                  children: [

                    if (Navigator.canPop(context))
                      Positioned(
                        left: 16,
                        top: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),

                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Icon(
                            Icons.account_balance,
                            color: Colors.white,
                            size: 32,
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Profil Saya",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

                  child: Column(
                    children: [

                      /// CARD PROFILE
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),

                        decoration: BoxDecoration(
                          color: const Color(0xFF5EB6E7),

                          borderRadius:
                              BorderRadius.circular(30),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [

                            /// FOTO PROFILE
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [

                                Container(
                                  padding:
                                      const EdgeInsets.all(4),

                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,

                                    gradient:
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFF56CCF2),
                                        Color(0xFF2F80ED),
                                      ],
                                    ),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue
                                            .withOpacity(0.4),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),

                                  child: const CircleAvatar(
                                    radius: 52,
                                    backgroundImage: AssetImage(
                                      "assets/profilezahra.png",
                                    ),
                                  ),
                                ),

                                Container(
                                  padding:
                                      const EdgeInsets.all(6),

                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,

                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),

                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Text(
                              profil.nama,
                              textAlign: TextAlign.center,

                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.20),

                                borderRadius:
                                    BorderRadius.circular(30),
                              ),

                              child: const Text(
                                "Warga Aktif",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            profileItem(
                              Icons.badge_outlined,
                              "NIK",
                              profil.nik,
                            ),

                            profileItem(
                              Icons.person_outline,
                              "Nama Lengkap",
                              profil.nama,
                            ),

                            profileItem(
                              Icons.location_on_outlined,
                              "Alamat",
                              profil.alamat,
                            ),

                            profileItem(
                              Icons.phone_outlined,
                              "No HP",
                              profil.noHp,
                            ),

                            const SizedBox(height: 28),

                            /// BUTTON EDIT
                            SizedBox(
                              width: double.infinity,
                              height: 54,

                              child: ElevatedButton.icon(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white,

                                  foregroundColor:
                                      const Color(
                                    0xFF1C4FA1,
                                  ),

                                  elevation: 0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                ),

                                onPressed: () {
                                  _showEditProfileModal(
                                    context,
                                  );
                                },

                                icon: const Icon(
                                  Icons.edit_rounded,
                                ),

                                label: const Text(
                                  "Edit Profil",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// BUTTON PASSWORD
                            SizedBox(
                              width: double.infinity,
                              height: 54,

                              child: ElevatedButton.icon(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white,

                                  foregroundColor:
                                      const Color(
                                    0xFF1C4FA1,
                                  ),

                                  elevation: 0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                ),

                                onPressed: () {
                                  gantiPassword();
                                },

                                icon: const Icon(
                                  Icons.lock_outline,
                                ),

                                label: const Text(
                                  "Ganti Password",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// BUTTON LOGOUT
                            SizedBox(
                              width: double.infinity,
                              height: 54,

                              child: ElevatedButton.icon(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red,

                                  foregroundColor:
                                      Colors.white,

                                  elevation: 0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                ),

                                onPressed: () {
                                  _showLogoutDialog(
                                    context,
                                  );
                                },

                                icon: const Icon(
                                  Icons.logout_rounded,
                                ),

                                label: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar:
          const BottomMenu(currentIndex: 1),
    );
  }

  static Widget profileItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF2F80ED),
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1B1B1B),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal(BuildContext context) {
    final profil = DataStore.profil;

    final namaController =
        TextEditingController(
      text: profil.nama,
    );

    final alamatController =
        TextEditingController(
      text: profil.alamat,
    );

    final hpController =
        TextEditingController(
      text: profil.noHp,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),

      builder: (context) {

        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom,
          ),

          child: Container(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                Container(
                  width: 50,
                  height: 5,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,

                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Edit Profil",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: namaController,

                  decoration: InputDecoration(
                    labelText: "Nama Lengkap",

                    prefixIcon:
                        const Icon(Icons.person),

                    filled: true,
                    fillColor: Colors.grey.shade100,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: alamatController,

                  decoration: InputDecoration(
                    labelText: "Alamat",

                    prefixIcon:
                        const Icon(Icons.location_on),

                    filled: true,
                    fillColor: Colors.grey.shade100,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: hpController,

                  decoration: InputDecoration(
                    labelText: "No HP",

                    prefixIcon:
                        const Icon(Icons.phone),

                    filled: true,
                    fillColor: Colors.grey.shade100,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1C4FA1),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),

                    onPressed: () {

                      DataStore.updateProfil(
                        Profil(
                          nik: profil.nik,
                          nama: namaController.text,
                          alamat:
                              alamatController.text,
                          noHp: hpController.text,
                        ),
                      );

                      setState(() {});

                      Navigator.pop(context);
                    },

                    child: const Text(
                      "Simpan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  /// GANTI PASSWORD
  void gantiPassword() {

    showDialog(
      context: context,

      builder: (_) =>
          const AlertDialog(
        title: Text("Ganti Password"),
        content:
            Text("Fitur belum tersedia"),
      ),
    );
  }

  static void _showLogoutDialog(
    BuildContext context,
  ) {

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),

          title: const Text(
            "Konfirmasi Logout",
          ),

          content: const Text(
            "Apakah Anda yakin ingin logout?",
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(context),

              child: const Text("Batal"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),

              onPressed: () {

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },

              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}