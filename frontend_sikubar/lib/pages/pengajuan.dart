import 'package:flutter/material.dart';
import '../widgets/bottom_menuwarga.dart';

class PengajuanPage extends StatefulWidget {
  const PengajuanPage({super.key});

  @override
  State<PengajuanPage> createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  String? jenisSurat;
  String namaFile = "Upload Berkas";

  final TextEditingController alasanController = TextEditingController();

  List<Map<String, String>> pengajuanList = [
    {
      "jenis": "Surat Keterangan Domisili",
      "alasan": "Untuk keperluan pendaftaran sekolah",
      "file": "berkas_domisili.pdf",
      "status": "Menunggu Verifikasi",
    },
    {
      "jenis": "Surat Keterangan Usaha",
      "alasan": "Pengajuan bantuan UMKM",
      "file": "berkas_usaha.pdf",
      "status": "Diproses",
    },
    {
      "jenis": "Surat Keterangan Tidak Mampu",
      "alasan": "Persyaratan beasiswa",
      "file": "berkas_sktm.pdf",
      "status": "Disetujui",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarSiKubar(
        title: "",
      ),

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
                  Icons.account_balance,
                  size: 70,
                  color: Colors.white,
                ),

                const SizedBox(height: 10),

                const Text(
                  "Pelayanan Publik",
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

                const Text(
                  "Pengajuan Surat",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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

                      /// JENIS SURAT
                      DropdownButtonFormField<String>(
                        value: jenisSurat,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Jenis Surat",
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        items: const [

                          DropdownMenuItem(
                            value: "Surat Keterangan Domisili",
                            child: Text(
                              "Surat Keterangan Domisili",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          DropdownMenuItem(
                            value: "Surat Keterangan Usaha",
                            child: Text(
                              "Surat Keterangan Usaha",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          DropdownMenuItem(
                            value: "Surat Keterangan Tidak Mampu",
                            child: Text(
                              "Surat Keterangan Tidak Mampu",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],

                        onChanged: (value) {
                          setState(() {
                            jenisSurat = value;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      /// ALASAN
                      TextField(
                        controller: alasanController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: "Alasan Pengajuan",
                          prefixIcon: const Icon(Icons.edit_note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// UPLOAD
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                        ),
                        onPressed: () {
                          setState(() {
                            namaFile = "berkas_pengajuan.pdf";
                          });
                        },
                        icon: const Icon(Icons.upload_file, color: Colors.black),
                        label: Text(
                          namaFile,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BUTTON AJUKAN
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C4FA1),
                          ),

                          onPressed: () {
                            if (jenisSurat != null &&
                                alasanController.text.isNotEmpty) {

                              setState(() {

                                pengajuanList.add({
                                  "jenis": jenisSurat ?? "-",
                                  "alasan": alasanController.text,
                                  "file": namaFile,
                                  "status": "Menunggu Verifikasi",
                                });

                                alasanController.clear();
                                namaFile = "Upload Berkas";
                                jenisSurat = null;

                              });
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

                const SizedBox(height: 20),

                /// LIST PENGAJUAN
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pengajuanList.length,

                  itemBuilder: (context, index) {

                    final data = pengajuanList[index];
                    String jenis = data["jenis"] ?? "-";

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
                              jenis,
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
                                padding: const EdgeInsets.symmetric(horizontal: 12),
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

      bottomNavigationBar: const BottomMenu(
        currentIndex: 1,
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Menunggu Verifikasi":
        return Colors.orange;
      case "Diproses":
        return Colors.blue;
      case "Disetujui":
        return Colors.green;
      case "Ditolak":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDetail(BuildContext context, Map<String, String> data) {

    String status = data["status"] ?? "-";
    Color statusColor = getStatusColor(status);

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text("Detail Pengajuan"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text("Jenis Surat : ${data["jenis"] ?? "-"}"),
              const SizedBox(height: 10),

              Text("Alasan : ${data["alasan"] ?? "-"}"),
              const SizedBox(height: 10),

              Text("File Berkas : ${data["file"] ?? "-"}"),
              const SizedBox(height: 15),

              Row(
                children: [

                  const Text("Status : "),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),

                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }
}