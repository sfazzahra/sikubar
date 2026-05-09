import 'package:flutter/material.dart';
import '../../widgets/bottom_menucamat.dart';

class ProfilCamatPage extends StatefulWidget {
  const ProfilCamatPage({super.key});

  @override
  State<ProfilCamatPage> createState() =>
      _ProfilCamatPageState();
}

class _ProfilCamatPageState
    extends State<ProfilCamatPage> {

  /// DATA CAMAT
  String nama = "Drs. Ahmad Fauzi";
  String email = "camat.kundur@gmail.com";
  String kecamatan = "Kundur Barat";
  String nip = "19781212 200501 1 001";
  String jabatan = "Camat";

  @override
  Widget build(BuildContext context) {

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
                          onTap: () =>
                              Navigator.pop(context),

                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),

                    const Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [

                          Icon(
                            Icons.account_balance,
                            color: Colors.white,
                            size: 32,
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Profil Camat",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
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
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

                  child: Column(
                    children: [

                      /// CARD PROFILE
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(24),

                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF5EB6E7),

                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.12),

                              blurRadius: 20,

                              offset:
                                  const Offset(0, 8),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [

                            /// FOTO PROFILE
                            Stack(
                              alignment:
                                  Alignment.bottomRight,

                              children: [

                                Container(
                                  padding:
                                      const EdgeInsets
                                          .all(4),

                                  decoration:
                                      BoxDecoration(
                                    shape:
                                        BoxShape.circle,

                                    gradient:
                                        const LinearGradient(
                                      colors: [
                                        Color(
                                          0xFF56CCF2,
                                        ),
                                        Color(
                                          0xFF2F80ED,
                                        ),
                                      ],
                                    ),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .blue
                                            .withOpacity(
                                          0.4,
                                        ),

                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),

                                  child:
                                      const CircleAvatar(
                                    radius: 52,

                                    backgroundImage:
                                        AssetImage(
                                      "assets/images/fotoprofile.png",
                                    ),
                                  ),
                                ),

                                Container(
                                  padding:
                                      const EdgeInsets
                                          .all(6),

                                  decoration:
                                      BoxDecoration(
                                    color: Colors.green,

                                    shape:
                                        BoxShape.circle,

                                    border: Border.all(
                                      color:
                                          Colors.white,
                                      width: 2,
                                    ),
                                  ),

                                  child: const Icon(
                                    Icons.check,
                                    color:
                                        Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            Text(
                              nama,
                              textAlign:
                                  TextAlign.center,

                              style:
                                  const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),

                              decoration:
                                  BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.20),

                                borderRadius:
                                    BorderRadius
                                        .circular(30),
                              ),

                              child: Text(
                                jabatan,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            profileItem(
                              Icons.person_outline,
                              "Nama",
                              nama,
                            ),

                            profileItem(
                              Icons.badge_outlined,
                              "NIP",
                              nip,
                            ),

                            profileItem(
                              Icons.email_outlined,
                              "Email",
                              email,
                            ),

                            profileItem(
                              Icons.location_city_outlined,
                              "Kecamatan",
                              kecamatan,
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            /// BUTTON EDIT
                            SizedBox(
                              width:
                                  double.infinity,
                              height: 54,

                              child:
                                  ElevatedButton.icon(
                                style:
                                    ElevatedButton
                                        .styleFrom(
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
                                        BorderRadius
                                            .circular(
                                      18,
                                    ),
                                  ),
                                ),

                                onPressed:
                                    editProfil,

                                icon: const Icon(
                                  Icons.edit_rounded,
                                ),

                                label: const Text(
                                  "Edit Profil",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            /// BUTTON PASSWORD
                            SizedBox(
                              width:
                                  double.infinity,
                              height: 54,

                              child:
                                  ElevatedButton.icon(
                                style:
                                    ElevatedButton
                                        .styleFrom(
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
                                        BorderRadius
                                            .circular(
                                      18,
                                    ),
                                  ),
                                ),

                                onPressed:
                                    gantiPassword,

                                icon: const Icon(
                                  Icons.lock_outline,
                                ),

                                label: const Text(
                                  "Ganti Password",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            /// BUTTON LOGOUT
                            SizedBox(
                              width:
                                  double.infinity,
                              height: 54,

                              child:
                                  ElevatedButton.icon(
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors.red,

                                  foregroundColor:
                                      Colors.white,

                                  elevation: 0,

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
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
                                        FontWeight
                                            .bold,
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
          const BottomMenuCamat(
        currentIndex: 1,
      ),
    );
  }

  static Widget profileItem(
    IconData icon,
    String title,
    String value,
  ) {

    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),

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
              color:
                  const Color(0xFFEAF4FF),

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Icon(
              icon,
              color:
                  const Color(0xFF2F80ED),
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
                    color:
                        Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    color:
                        Color(0xFF1B1B1B),
                    fontWeight:
                        FontWeight.bold,
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

  /// EDIT PROFIL
  void editProfil() {

    showDialog(
      context: context,

      builder: (_) =>
          const AlertDialog(
        title: Text("Edit Profil"),
        content:
            Text("Fitur belum terhubung"),
      ),
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

  /// LOGOUT
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
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
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