import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/bottom_menuwarga.dart';
import '../ds.dart';
import '../model/mpengajuan.dart';

class PengajuanPage extends StatefulWidget {
  const PengajuanPage({super.key});

  @override
  State<PengajuanPage> createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  String? jenisSurat;
  final TextEditingController alasanController = TextEditingController();

  String namaFile = "Upload Berkas";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2F80ED), Color(0xFF1C4FA1)],
              ),
            ),
            child: Column(
              children: [
                /// 🔔 NOTIF
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifikasi');
                        },
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.account_balance,
                    size: 70, color: Colors.white),

                const SizedBox(height: 10),

                const Text(
                  "Pengajuan Surat",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Text(
                  "Kantor Kecamatan Kundur Barat",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 15),

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
                    indicatorPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.white,
                    tabs: [
                      Tab(text: "Form Pengajuan"),
                      Tab(text: "Daftar Pengajuan"),
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
                                value: jenisSurat,
                                decoration: InputDecoration(
                                  labelText: "Jenis Surat",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: "Surat Domisili",
                                      child: Text("Surat Domisili")),
                                  DropdownMenuItem(
                                      value: "Surat Usaha",
                                      child: Text("Surat Usaha")),
                                  DropdownMenuItem(
                                      value: "Surat Tidak Mampu",
                                      child:
                                          Text("Surat Tidak Mampu")),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    jenisSurat = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 15),

                              TextField(
                                controller: alasanController,
                                decoration: InputDecoration(
                                  labelText: "Alasan",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              /// 🔥 UPLOAD FILE (ANTI ERROR)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                ),
                                onPressed: () async {
                                  try {
                                    FilePickerResult? result;

                                    if (kIsWeb) {
                                      result = await FilePicker.platform.pickFiles(
                                        withData: true,
                                      );
                                    } else {
                                      result = await FilePicker.platform.pickFiles();
                                    }

                                    if (!mounted) return;

                                    if (result != null &&
                                        result.files.isNotEmpty) {
                                      setState(() {
                                        namaFile =
                                            result!.files.first.name;
                                      });
                                    }
                                  } catch (e) {
                                    debugPrint("ERROR PICK FILE: $e");

                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text("Gagal upload file"),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.upload_file,
                                    color: Colors.black),
                                label: Text(
                                  namaFile,
                                  style: const TextStyle(
                                      color: Colors.black),
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
                                    if (jenisSurat != null &&
                                        alasanController.text.isNotEmpty) {
                                      final data = Pengajuan(
                                        id: DateTime.now().toString(),
                                        judul: jenisSurat!,
                                        deskripsi:
                                            alasanController.text,
                                        tanggal: DateTime.now(),
                                        file: namaFile,
                                      );

                                      setState(() {
                                        DataStore.tambahPengajuan(data);
                                      });

                                      alasanController.clear();
                                      jenisSurat = null;
                                      namaFile = "Upload Berkas";

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Pengajuan berhasil ditambahkan"),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    "Ajukan",
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
                        itemCount: DataStore.pengajuanList.length,
                        itemBuilder: (context, index) {
                          final item =
                              DataStore.pengajuanList[index];

                          Color warnaStatus = Colors.orange;
                          if (item.status == "Disetujui") {
                            warnaStatus = Colors.green;
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.judul,
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold),
                                  ),
                                ),
                                Text(item.status,
                                    style: TextStyle(
                                        color: warnaStatus)),
                                const SizedBox(width: 10),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF1C4FA1),
                                  ),
                                  onPressed: () {
                                    _showDetail(
                                      context,
                                      item.judul,
                                      item.status,
                                      item.deskripsi,
                                      item.file,
                                      warnaStatus,
                                    );
                                  },
                                  child: const Text("Detail",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white)),
                                ),

                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      DataStore.hapusPengajuan(index);
                                    });
                                  },
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
        bottomNavigationBar:
            const BottomMenu(currentIndex: 1),
      ),
    );
  }

  /// 🔥 FIX ERROR (DETAIL FUNCTION)
  void _showDetail(
    BuildContext context,
    String jenis,
    String status,
    String alasan,
    String file,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Detail Pengajuan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Jenis Surat : $jenis"),
              const SizedBox(height: 8),
              Text("Alasan : $alasan"),
              const SizedBox(height: 8),
              Text("File : $file"),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Status : "),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }
}