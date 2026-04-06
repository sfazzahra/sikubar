import 'package:flutter/material.dart';
import '../widgets/bottom_menuwarga.dart';
import '../ds.dart';
import '../model/mprofil.dart';

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

        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),

                child: Column(
                  children: [

                    const SizedBox(height: 20),

                    const Icon(
                      Icons.account_balance,
                      size: 70,
                      color: Colors.white,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Profil Saya",
                      style: TextStyle(
                        fontSize: 22,
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

                    const SizedBox(height: 15),

                    /// CARD PROFIL
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          const CircleAvatar(
                            radius: 45,
                            backgroundImage:
                                AssetImage("assets/profilezahra.png"),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            profil.nama, // ✅ dari DataStore
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          profileItem(Icons.badge, "NIK", profil.nik),
                          profileItem(Icons.person, "Nama Lengkap", profil.nama),
                          profileItem(Icons.location_on, "Alamat", profil.alamat),
                          profileItem(Icons.phone, "No HP", profil.noHp),

                          const SizedBox(height: 20),

                          /// BUTTON EDIT PROFIL
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1C4FA1),
                              ),
                              onPressed: () {
                                _showEditProfileModal(context);
                              },
                              child: const Text(
                                "Edit Profil",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// BUTTON LOGOUT (TETAP)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                _showLogoutDialog(context);
                              },
                              child: const Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
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
            );
          },
        ),
      ),

      bottomNavigationBar: const BottomMenu(currentIndex: 4),
    );
  }

  /// WIDGET DATA PROFIL (TETAP)
  static Widget profileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            "$title : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// 🔥 EDIT PROFIL (SUDAH NYAMBUNG DATASTORE)
  void _showEditProfileModal(BuildContext context) {
    final profil = DataStore.profil;

    final namaController = TextEditingController(text: profil.nama);
    final alamatController = TextEditingController(text: profil.alamat);
    final hpController = TextEditingController(text: profil.noHp);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "Edit Profil",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: alamatController,
                  decoration: InputDecoration(
                    labelText: "Alamat",
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: hpController,
                  decoration: InputDecoration(
                    labelText: "No HP",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C4FA1),
                    ),
                    onPressed: () {
                      DataStore.updateProfil(
                        Profil(
                          nik: profil.nik,
                          nama: namaController.text,
                          alamat: alamatController.text,
                          noHp: hpController.text,
                        ),
                      );

                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  /// LOGOUT (TETAP)
  static void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}