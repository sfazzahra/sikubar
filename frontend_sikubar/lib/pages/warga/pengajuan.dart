import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../widgets/bottom_menuwarga.dart';

class PengajuanPage extends StatefulWidget {
  const PengajuanPage({super.key});

  @override
  State<PengajuanPage> createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  String? jenisSurat;
  String? tujuanSelected;
  bool isLainnya = false;

  final TextEditingController tujuanManualController =
      TextEditingController();

  List pengajuanList = [];

  final String baseUrl = "http://192.168.110.177/SiKubar-PBL/api";

  List<String> berkasWajib = [];
  Map<String, String> fileUploads = {};

  /// ================= DATA =================

  final Map<String, List<String>> tujuanMap = {
    "Rekomendasi BBM": ["Untuk usaha", "Untuk nelayan", "Lainnya"],
    "Ahli Waris": ["Pengurusan warisan", "Lainnya"],
    "Dispensasi Nikah": ["Usia belum cukup", "Keadaan mendesak", "Lainnya"],
    "Pembuatan KK": ["KK baru", "Perubahan data", "Lainnya"],
    "Pembuatan KTP-el": ["KTP baru", "KTP hilang", "Lainnya"],
  };

  final Map<String, List<String>> berkasMap = {
    "Dispensasi Nikah": [
      "FC KK Catin",
      "FC KTP Catin",
      "FC Akta Kelahiran",
      "FC Ijazah",
      "FC Pengantar Lurah",
      "FC Pengantar KUA",
    ],
    "Pembuatan KK": [
      "Formulir Desa",
      "KK Asli",
      "FC KK",
      "FC Akta Kelahiran",
      "FC Ijazah",
      "FC Buku Nikah",
    ],
    "Pembuatan KTP-el": [
      "Formulir Desa",
      "FC KK",
      "FC KTP",
    ],
    "Ahli Waris": [
      "FC Akta Kematian",
      "FC KTP Meninggal",
      "FC KK Lama & Baru",
      "FC KTP Ahli Waris",
      "FC KTP Anak + KK",
      "FC KTP Saksi",
    ],
    "Rekomendasi BBM": [
      "FC KTP",
      "FC NIB",
      "FC Pajak Tahun Lalu",
    ],
  };

  @override
  void initState() {
    super.initState();
    getData();
  }

  /// ================= GET =================
  Future<void> getData() async {
    try {
      var response = await http.get(Uri.parse("$baseUrl/getdata.php"));
      var data = json.decode(response.body);

      setState(() {
        pengajuanList = data is List ? data : [];
      });
    } catch (e) {
      print("ERROR GET DATA: $e");
    }
  }

  /// ================= TAMBAH =================
  Future<void> tambahData() async {
    try {
      await http.post(
        Uri.parse("$baseUrl/tambah.php"),
        body: {
          "jenis_surat": jenisSurat ?? "",
          "alasan": tujuanSelected == "Lainnya"
              ? tujuanManualController.text
              : tujuanSelected ?? "",
          "file": jsonEncode(fileUploads),
        },
      );

      await getData();
    } catch (e) {
      print("ERROR TAMBAH: $e");
    }
  }

  /// ================= HAPUS =================
  Future<void> hapusData(String id) async {
    await http.post(
      Uri.parse("$baseUrl/hapus.php"),
      body: {"id": id},
    );

    await getData();
  }

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
                              "Pengajuan Surat",
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

                              /// JENIS SURAT
                              DropdownButtonFormField<String>(
                                value: jenisSurat,
                                decoration: InputDecoration(
                                  labelText: "Jenis Surat",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: "Rekomendasi BBM", child: Text("Rekomendasi BBM")),
                                  DropdownMenuItem(value: "Ahli Waris", child: Text("Ahli Waris")),
                                  DropdownMenuItem(value: "Dispensasi Nikah", child: Text("Dispensasi Nikah")),
                                  DropdownMenuItem(value: "Pembuatan KK", child: Text("Pembuatan KK")),
                                  DropdownMenuItem(value: "Pembuatan KTP-el", child: Text("Pembuatan KTP-el")),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    jenisSurat = value;
                                    tujuanSelected = null;
                                    isLainnya = false;
                                    tujuanManualController.clear();
                                    fileUploads.clear();
                                    berkasWajib = berkasMap[value] ?? [];
                                  });
                                },
                              ),

                              const SizedBox(height: 15),

                              /// TUJUAN
                              DropdownButtonFormField<String>(
                                value: (tujuanMap[jenisSurat]
                                            ?.contains(tujuanSelected) ??
                                        false)
                                    ? tujuanSelected
                                    : null,
                                decoration: InputDecoration(
                                  labelText: "Tujuan Pengajuan",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: (tujuanMap[jenisSurat] ?? [])
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    tujuanSelected = value;
                                    isLainnya = value == "Lainnya";
                                  });
                                },
                              ),

                              if (isLainnya)
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextField(
                                    controller: tujuanManualController,
                                    decoration: InputDecoration(
                                      labelText: "Masukkan tujuan",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 15),

                              /// BERKAS
                              if (berkasWajib.isNotEmpty)
                                Column(
                                  children: berkasWajib.map((b) {
                                    bool sudahUpload =
                                        fileUploads.containsKey(b);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            sudahUpload
                                                ? Icons.check_circle
                                                : Icons.insert_drive_file,
                                            color: sudahUpload
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(b),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var result =
                                                  await FilePicker.platform
                                                      .pickFiles();
                                              if (result != null) {
                                                setState(() {
                                                  fileUploads[b] =
                                                      result.files.first.name;
                                                });
                                              }
                                            },
                                            child: Text(
                                                sudahUpload ? "Ganti" : "Unggah"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),

                              const SizedBox(height: 20),

                              /// SUBMIT
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF1C4FA1),
                                  ),
                                  onPressed: () async {
                                    if (jenisSurat == null ||
                                        tujuanSelected == null) return;

                                    if (tujuanSelected == "Lainnya" &&
                                        tujuanManualController.text.isEmpty)
                                      return;

                                    if (fileUploads.length !=
                                        berkasWajib.length) return;

                                    await tambahData();

                                    setState(() {
                                      jenisSurat = null;
                                      tujuanSelected = null;
                                      isLainnya = false;
                                      tujuanManualController.clear();
                                      fileUploads.clear();
                                      berkasWajib = [];
                                    });
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

                      /// ================= LIST =================
                      ListView.builder(
                        itemCount: pengajuanList.length,
                        itemBuilder: (context, index) {
                          final item = pengajuanList[index];

                          return ListTile(
                            title: Text(item['jenis_surat'] ?? '-'),
                            subtitle: Text(item['status'] ?? '-'),
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
            const BottomMenu(currentIndex: 2),
      ),
    );
  }
}