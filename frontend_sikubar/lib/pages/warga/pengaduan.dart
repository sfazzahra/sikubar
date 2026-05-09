import 'package:flutter/material.dart';
import '../../widgets/bottom_menuwarga.dart';
import '../../ds.dart';
import '../../model/mpengaduan.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  String? kategoriPengaduan;
  String namaFile = "Upload Bukti";

  final TextEditingController isiController = TextEditingController();

   @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(

        /// 🔥 BODY + BACKGROUND
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),

          child: SafeArea(
            child: Column(
              children: [

                /// 🔥 HEADER CUSTOM
                SizedBox(
                  height: 90,
                  child: Stack(
                    children: [

                      /// BACK
                      if (Navigator.canPop(context))
                        Positioned(
                          left: 16,
                          top: 10,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 26),
                          ),
                        ),

                      /// NOTIF
                      Positioned(
                        right: 10,
                        top: 10,
                        child: IconButton(
                          icon: const Icon(Icons.notifications,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.pushNamed(context, '/notifikasi');
                          },
                        ),
                      ),

                      /// TITLE
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.account_balance,
                                color: Colors.white, size: 32),
                            SizedBox(height: 4),
                            Text(
                              "Pengaduan Layanan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                /// TAB
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                    ),
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.white,
                    tabs: [
                      Tab(text: "Form Pengaduan"),
                      Tab(text: "Daftar Pengaduan"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: TabBarView(
                    children: [
                      /// ================= FORM =================
                      SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [

                              DropdownButtonFormField<String>(
                                value: kategoriPengaduan,
                                decoration: InputDecoration(
                                  labelText: "Kategori Pengaduan",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: "Pelayanan Lambat",
                                      child: Text("Pelayanan Lambat")),
                                  DropdownMenuItem(
                                      value: "Petugas Tidak Ramah",
                                      child: Text("Petugas Tidak Ramah")),
                                  DropdownMenuItem(
                                      value: "Fasilitas Kurang",
                                      child: Text("Fasilitas Kurang")),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    kategoriPengaduan = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 15),

                              /// 🔥 TEXTFIELD DIPERKECIL
                              TextField(
                                controller: isiController,
                                maxLines: 1, 
                                decoration: InputDecoration(
                                  labelText: "Isi Pengaduan",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                ),
                                onPressed: () {
                                  setState(() {
                                    namaFile = "bukti_pengaduan.jpg";
                                  });
                                },
                                icon: const Icon(Icons.upload_file,
                                    color: Colors.black),
                                label: Text(
                                  namaFile,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF1C4FA1),
                                  ),
                                  onPressed: () {
                                    if (kategoriPengaduan != null &&
                                        isiController.text.isNotEmpty) {
                                      final data = Pengaduan(
                                        id: DateTime.now().toString(),
                                        kategori: kategoriPengaduan!,
                                        isi: isiController.text,
                                        file: namaFile,
                                        tanggal: DateTime.now(),
                                      );

                                      setState(() {
                                        DataStore.pengaduanList.add(data);
                                      });

                                      isiController.clear();
                                      namaFile = "Upload Bukti";
                                      kategoriPengaduan = null;

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Pengaduan berhasil dikirim"),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    "Kirim Pengaduan",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// ================= DAFTAR =================
                      ListView.builder(
                        itemCount: DataStore.pengaduanList.length,
                        itemBuilder: (context, index) {
                          final data =
                              DataStore.pengaduanList[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    data.kategori,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF1C4FA1),
                                  ),
                                  onPressed: () {
                                    _showDetail(context, data);
                                  },
                                  child: const Text(
                                    "Detail",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white),
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
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomMenu(currentIndex: 4),
      ),
    );
  }

  void _showDetail(BuildContext context, Pengaduan data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Detail Pengaduan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kategori : ${data.kategori}"),
              const SizedBox(height: 8),
              Text("Isi : ${data.isi}"),
              const SizedBox(height: 8),
              Text("File : ${data.file}"),
              const SizedBox(height: 8),
              Text("Status : ${data.status}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            )
          ],
        );
      },
    );
  }
}