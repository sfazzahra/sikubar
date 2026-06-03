import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';

class BerandaPetugasPage extends StatefulWidget {
  const BerandaPetugasPage({super.key});

  @override
  State<BerandaPetugasPage> createState() =>
      _BerandaPetugasPageState();
}

class _BerandaPetugasPageState
    extends State<BerandaPetugasPage> {
  final ApiService _api = ApiService();

  bool isLoading = true;
  String namaPetugas = '';

  // Statistik
  int total = 0;
  int diproses = 0;
  int selesai = 0;

  // Perlu perhatian
  int belumVerifikasi = 0;
  int pengaduanBaru = 0;

  // Ringkasan hari ini
  int diverifikasiHariIni = 0;
  int pengaduanDitanggapi = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Load statistik dan profil sekaligus
      final results = await Future.wait([
        _api.getStatistikPetugas(),
        _api.getProfilPetugas(),
      ]);

      final statistik = results[0]['data'];
      final profil = results[1]['data'];

      setState(() {
        // Profil
        namaPetugas = profil['nama'] ?? 'Petugas';

        // Statistik
        total    = statistik['total'] ?? 0;
        diproses = statistik['diproses'] ?? 0;
        selesai  = statistik['selesai'] ?? 0;

        // Perlu perhatian
        belumVerifikasi =
            statistik['perlu_perhatian']?['belum_verifikasi'] ?? 0;
        pengaduanBaru =
            statistik['perlu_perhatian']?['pengaduan_baru'] ?? 0;

        // Ringkasan hari ini
        diverifikasiHariIni =
            statistik['ringkasan_hari_ini']?['diverifikasi'] ?? 0;
        pengaduanDitanggapi =
            statistik['ringkasan_hari_ini']?['pengaduan_ditanggapi'] ?? 0;

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Dashboard Petugas",
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Selamat Datang",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              namaPetugas,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // STATISTIK
                  Row(
                    children: [
                      _stat(total.toString(), "Total",
                          Colors.blue),
                      const SizedBox(width: 8),
                      _stat(diproses.toString(), "Diproses",
                          Colors.orange),
                      const SizedBox(width: 8),
                      _stat(selesai.toString(), "Selesai",
                          Colors.green),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Perlu Perhatian",
                    style:
                        TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  if (belumVerifikasi > 0)
                    _warning(
                      "$belumVerifikasi berkas belum diverifikasi",
                      Colors.orange,
                    ),

                  if (pengaduanBaru > 0)
                    _warning(
                      "$pengaduanBaru pengaduan baru masuk",
                      Colors.red,
                    ),

                  if (belumVerifikasi == 0 && pengaduanBaru == 0)
                    _warning(
                      "Tidak ada item yang perlu perhatian",
                      Colors.green,
                    ),

                  const SizedBox(height: 20),

                  const Text(
                    "Ringkasan Hari Ini",
                    style:
                        TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  _summary("Berkas diverifikasi",
                      diverifikasiHariIni.toString()),
                  _summary("Pengaduan ditanggapi",
                      pengaduanDitanggapi.toString()),
                ],
              ),
            ),
    );
  }

  Widget _stat(String value, String title, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _warning(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _summary(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}