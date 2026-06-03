import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PengaduanPetugasPage extends StatefulWidget {
  const PengaduanPetugasPage({super.key});

  @override
  State<PengaduanPetugasPage> createState() =>
      _PengaduanPetugasPageState();
}

class _PengaduanPetugasPageState extends State<PengaduanPetugasPage> {
  final ApiService _api = ApiService();

  bool isLoading = true;
  String selectedFilter = "Semua";
  List dataPengaduan = [];

  @override
  void initState() {
    super.initState();
    _loadPengaduan();
  }

  Future<void> _loadPengaduan() async {
    setState(() => isLoading = true);

    try {
      final res = await _api.getPengaduanPetugas(
        status: selectedFilter == "Semua"
            ? null
            : selectedFilter.toLowerCase(),
      );

      setState(() {
        dataPengaduan = res['data'];
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("Pengaduan Petugas"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          /// FILTER
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilter("Semua"),
                _buildFilter("Diproses"),
                _buildFilter("Selesai"),
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : dataPengaduan.isEmpty
                    ? const Center(child: Text("Tidak ada pengaduan"))
                    : RefreshIndicator(
                        onRefresh: _loadPengaduan,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: dataPengaduan.length,
                          itemBuilder: (context, index) {
                            return _buildCard(dataPengaduan[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// FILTER BUTTON
  Widget _buildFilter(String text) {
    final isActive = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = text);
        _loadPengaduan();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF2F80ED)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// CARD
  Widget _buildCard(Map item) {
    final status = (item['status'] ?? '-').toString();
    final color = _getStatusColor(status);

    return GestureDetector(
      onTap: () => _showDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['nama'] ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              item['judul'] ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Text(
              item['isi'] ?? '-',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: Colors.black54),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                item['tanggal'] ?? '-',
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// DETAIL + TANGGAPAN (CONNECT API)
  void _showDetail(Map item) {
    TextEditingController balasanCtrl =
        TextEditingController(text: item['balasan'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detail Pengaduan",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text("Nama: ${item['nama'] ?? '-'}"),
              Text("Judul: ${item['judul'] ?? '-'}"),
              Text("Isi: ${item['isi'] ?? '-'}"),

              const SizedBox(height: 10),

              TextField(
                controller: balasanCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Tanggapan",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    try {
                      await _api.tanggapiPengaduan(
                        item['id'],
                        balasanCtrl.text,
                      );

                      Navigator.pop(context);
                      _loadPengaduan();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Tanggapan berhasil dikirim"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: const Text("Kirim"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}