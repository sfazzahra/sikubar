import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/notification_badge.dart';
import '../../notifications/notifikasi_page.dart';

class ValidasiKasiPage extends StatefulWidget {
  const ValidasiKasiPage({super.key});

  @override
  State<ValidasiKasiPage> createState() => _ValidasiKasiPageState();
}

class _ValidasiKasiPageState extends State<ValidasiKasiPage> {
  final ApiService _api = ApiService();

  bool isLoading = true;
  bool isProcessing = false;
  String selectedTab = "Semua";

  List<Map<String, dynamic>> allPengajuan = [];
  List<Map<String, dynamic>> pengajuanList = [];

 @override
void initState() {
  super.initState();
  _loadPengajuan();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.fetchNotifikasi();
  });
}

  Future<void> _loadPengajuan() async {
    try {
      setState(() => isLoading = true);

      final response = await _api.getPengajuanKasi();

      allPengajuan = List<Map<String, dynamic>>.from(
        response["data"] ?? [],
      );

      _filterData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterData() {
  if (selectedTab == "Semua") {
    pengajuanList = allPengajuan.where((e) {
      final status = (e["status"] ?? "").toString().toLowerCase();

      return status != "ditolak" &&
             status != "selesai";
    }).toList();
  } else {
    pengajuanList = allPengajuan
        .where((e) => e["status"] == selectedTab)
        .toList();
  }

  setState(() {});
}

  // ─── AKSI: Kasi Setujui
  Future<void> _aksiSetujui(Map<String, dynamic> item) async {
    try {
      setState(() => isProcessing = true);
      await _api.approvePengajuanKasi(item["id"]);
      await _loadPengajuan();

      NotificationService.instance.refreshBadge();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengajuan berhasil disetujui, petugas akan diberitahu"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isProcessing = false);
    }
  }

  // ─── AKSI: Kasi Tolak
  Future<void> _aksiTolak(Map<String, dynamic> item, String alasan) async {
    try {
      setState(() => isProcessing = true);
      await _api.tolakPengajuanKasi(item["id"], alasan);
      await _loadPengajuan();

      NotificationService.instance.refreshBadge();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengajuan berhasil ditolak"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isProcessing = false);
    }
  }

  // ─── Buka URL surat PDF
  Future<void> _bukaUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak bisa membuka surat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Dialog konfirmasi tolak + input alasan
  void _showTolakDialog(Map<String, dynamic> item) {
    final alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text("Alasan Penolakan",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: alasanController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Masukkan alasan penolakan",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (alasanController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Alasan penolakan wajib diisi"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _aksiTolak(item, alasanController.text.trim());
              },
              child: const Text("Tolak"),
            ),
          ],
        );
      },
    );
  }

  String _labelStatus(String status) {
    switch (status) {
      case 'menunggu_kasi':
        return 'Menunggu Validasi';
      case 'disetujui_kasi':
        return 'Disetujui';
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu_kasi':
        return Colors.orange;
      case 'disetujui_kasi':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'selesai':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
  centerTitle: true,
  backgroundColor: const Color(0xFF2F80ED),
  foregroundColor: Colors.white,
  title: const Text("Validasi Pengajuan"),
  elevation: 0,
  actions: [
    NotificationBadgeIcon(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NotifikasiPage(),
        ),
      ).then(
        (_) => NotificationService.instance.refreshBadge(),
      ),
    ),
  ],
),
      body: Column(
        children: [
          // ─── TAB FILTER
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTab("Semua"),
                _buildTab("menunggu_kasi"),
                _buildTab("disetujui_kasi"),
                _buildTab("selesai"),
                _buildTab("ditolak"),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : pengajuanList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              "Tidak ada pengajuan",
                              style:
                                  TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPengajuan,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: pengajuanList.length,
                          itemBuilder: (context, index) {
                            return _buildCard(pengajuanList[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    final active = selectedTab == text;
    final label =
        text == "Semua" ? "SEMUA" : _labelStatus(text).toUpperCase();

    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = text);
        _filterData();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2F80ED) : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final status = item["status"] ?? "";
    final color = _getStatusColor(status);

    return GestureDetector(
      onTap: () => _showDetailSheet(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(Icons.description, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["warga"]?["nama"] ?? '-',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item["jenis_surat"]?["nama"] ?? '-',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item["nomor_pengajuan"] ?? '-',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.8), color],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _labelStatus(status).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Badge indikator surat sudah ada
                if (status == 'selesai' && item["surat_path"] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: const Text(
                      'Ada Surat',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(Map<String, dynamic> item) {
    final status = item["status"] ?? "";
    final color = _getStatusColor(status);
    final berkas = item["berkas"] as List? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Detail Pengajuan",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                _detailItem("Nomor", item["nomor_pengajuan"] ?? "-"),
                _detailItem("Nama", item["warga"]?["nama"] ?? "-"),
                _detailItem("NIK", item["warga"]?["nik"] ?? "-"),
                _detailItem(
                    "Jenis Surat", item["jenis_surat"]?["nama"] ?? "-"),
                _detailItem("Tujuan", item["tujuan"] ?? "-"),
                _detailItem(
                  "Status",
                  _labelStatus(status),
                  valueColor: color,
                ),

                if (item["catatan"] != null &&
                    item["catatan"].toString().isNotEmpty)
                  _detailItem("Catatan Petugas", item["catatan"]),

                if (item["alasan_penolakan"] != null &&
                    item["alasan_penolakan"].toString().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Alasan Penolakan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(item["alasan_penolakan"].toString()),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                const Text(
                  "Berkas",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ...berkas.map((b) {
  final fileUrl = b["url"];

  return GestureDetector(
    onTap: fileUrl != null
        ? () => _bukaUrl(fileUrl)
        : null,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b["nama_berkas"] ?? "-",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Klik untuk melihat berkas",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.open_in_new,
            color: Colors.blue,
            size: 18,
          ),
        ],
      ),
    ),
  );
}).toList(),


                const SizedBox(height: 20),

                // ═══════════════════════════════════════════════════
                // AKSI: status == 'menunggu_kasi' → Setujui / Tolak
                // ═══════════════════════════════════════════════════
                if (status == "menunggu_kasi") ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text("Tolak"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                          onPressed: isProcessing
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _showTolakDialog(item);
                                },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text("Setujui"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                          onPressed: isProcessing
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _aksiSetujui(item);
                                },
                        ),
                      ),
                    ],
                  ),
                ],

                // ═══════════════════════════════════════════════════
                // INFO: status == 'disetujui_kasi' → menunggu petugas
                // ═══════════════════════════════════════════════════
                if (status == "disetujui_kasi")
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Pengajuan sudah disetujui. Petugas sedang memproses pembuatan surat.",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ═══════════════════════════════════════════════════
                // INFO + TOMBOL: status == 'selesai' → lihat surat
                // ═══════════════════════════════════════════════════
                if (status == "selesai") ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf,
                            color: Colors.teal.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item["surat_path"] != null
                                ? "Surat sudah diupload oleh petugas."
                                : "Pengajuan selesai, surat belum diupload.",
                            style:
                                TextStyle(color: Colors.teal.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item["surat_path"] != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text("Lihat Surat"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () =>
                            _bukaUrl(item["surat_path"]),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailItem(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}