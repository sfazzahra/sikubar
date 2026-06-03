import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MonitoringPetugasPage extends StatefulWidget {
  const MonitoringPetugasPage({super.key});

  @override
  State<MonitoringPetugasPage> createState() =>
      _MonitoringPetugasPageState();
}

class _MonitoringPetugasPageState
    extends State<MonitoringPetugasPage> {
  final ApiService _api = ApiService();

  bool isLoading = true;
  String selectedFilter = "Semua";
  List dataMonitoring = [];
  int currentPage = 1;
  int lastPage = 1;

  @override
  void initState() {
    super.initState();
    _loadMonitoring();
  }

  Future<void> _loadMonitoring({bool reset = false}) async {
    if (reset) {
      currentPage = 1;
      dataMonitoring = [];
    }

    setState(() => isLoading = true);

    try {
      final res = await _api.getMonitoringPetugas(
        status: selectedFilter == "Semua" ? null : selectedFilter.toLowerCase(),
        page: currentPage,
      );

      final meta = res['meta'];
      setState(() {
        dataMonitoring = res['data'];
        lastPage = meta['last_page'];
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
        title: const Text("Monitoring Pengajuan"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // FILTER
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
                _buildFilter("Ditolak"),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : dataMonitoring.isEmpty
                    ? const Center(
                        child: Text("Tidak ada data pengajuan"))
                    : RefreshIndicator(
                        onRefresh: () =>
                            _loadMonitoring(reset: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: dataMonitoring.length,
                          itemBuilder: (context, index) {
                            return _buildCard(dataMonitoring[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(String text) {
    final isActive = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = text);
        _loadMonitoring(reset: true);
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

  Widget _buildCard(Map item) {
    final status = item['status'] ?? '-';
    final color = _getStatusColor(status);

    return Container(
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
          const SizedBox(height: 4),
          Text(
            item['jenis'] ?? '-',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['keterangan'] ?? '-',
            style: const TextStyle(
                fontSize: 12, color: Colors.black54),
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
      case 'diverifikasi':
      case 'diteruskan':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}