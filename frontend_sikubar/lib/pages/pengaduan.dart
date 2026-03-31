import 'package:flutter/material.dart';
import '../widgets/bottom_menuwarga.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  String? kategoriPengaduan;
  String namaFile = "Upload Bukti";

  final TextEditingController isiController = TextEditingController();

  List<Map<String, String>> pengaduanList = [
    {
      "kategori": "Pelayanan Lambat",
      "isi": "Proses pelayanan terlalu lama",
      "file": "bukti1.jpg",
      "status": "Diproses",
    },
    {
      "kategori": "Petugas Tidak Ramah",
      "isi": "Petugas kurang ramah saat melayani",
      "file": "bukti2.jpg",
      "status": "Selesai",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
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

          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Icon(
                  Icons.report_problem,
                  size: 70,
                  color: Colors.white,
                ),

                const SizedBox(height: 10),

                const Text(
                  "Pengaduan Masyarakat",
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

                const SizedBox(height: 20),

                /// CARD FORM
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// KATEGORI
                      DropdownButtonFormField<String>(
                        value: kategoriPengaduan,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Kategori Pengaduan",
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Pelayanan Lambat",
                            child: Text("Pelayanan Lambat"),
                          ),
                          DropdownMenuItem(
                            value: "Petugas Tidak Ramah",
                            child: Text("Petugas Tidak Ramah"),
                          ),
                          DropdownMenuItem(
                            value: "Fasilitas Kurang",
                            child: Text("Fasilitas Kurang"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            kategoriPengaduan = value;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      /// ISI PENGADUAN
                      TextField(
                        controller: isiController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Isi Pengaduan",
                          prefixIcon: const Icon(Icons.edit_note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// UPLOAD BUKTI
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                        ),
                        onPressed: () {
                          setState(() {
                            namaFile = "bukti_pengaduan.jpg";
                          });
                        },
                        icon: const Icon(Icons.upload_file, color: Colors.black),
                        label: Text(
                          namaFile,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BUTTON KIRIM
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C4FA1),
                          ),
                          onPressed: () {
                            if (kategoriPengaduan != null &&
                                isiController.text.isNotEmpty) {

                              setState(() {
                                pengaduanList.add({
                                  "kategori": kategoriPengaduan ?? "-",
                                  "isi": isiController.text,
                                  "file": namaFile,
                                  "status": "Dikirim",
                                });

                                isiController.clear();
                                namaFile = "Upload Bukti";
                                kategoriPengaduan = null;
                              });
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

                const SizedBox(height: 20),

                /// LIST PENGADUAN
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pengaduanList.length,
                  itemBuilder: (context, index) {
                    final data = pengaduanList[index];
                    String kategori = data["kategori"] ?? "-";

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
                              kategori,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          SizedBox(
                            height: 35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1C4FA1),
                              ),
                              onPressed: () {
                                _showDetail(context, data);
                              },
                              child: const Text(
                                "Detail",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: const BottomMenu(currentIndex: 2),
    );
  }

  void _showDetail(BuildContext context, Map<String, String> data) {
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
              Text("Kategori : ${data["kategori"] ?? "-"}"),
              const SizedBox(height: 10),
              Text("Isi : ${data["isi"] ?? "-"}"),
              const SizedBox(height: 10),
              Text("File : ${data["file"] ?? "-"}"),
              const SizedBox(height: 10),
              Text("Status : ${data["status"] ?? "-"}"),
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