import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';

class VerifikasiPetugasPage extends StatefulWidget {
  const VerifikasiPetugasPage({super.key});

  @override
  State<VerifikasiPetugasPage> createState() => _VerifikasiPetugasPageState();
}

class _VerifikasiPetugasPageState extends State<VerifikasiPetugasPage> {
  final ApiService _api = ApiService();

  bool isLoading = true;
  bool isProcessingAction = false;
  String selectedTab = "Semua";
  List pengajuanList = [];
  int currentPage = 1;
  int lastPage = 1;

  @override
  void initState() {
    super.initState();
    _loadPengajuan();
  }

  Future<void> _loadPengajuan({bool reset = false}) async {
    if (reset) {
      currentPage = 1;
      pengajuanList = [];
    }

    setState(() => isLoading = true);

    try {
      final res = await _api.getPengajuanPetugas(
        status: selectedTab == "Semua" ? null : selectedTab,
        page: currentPage,
      );

      final meta = res['meta'];
      setState(() {
  pengajuanList = selectedTab == "Semua"
      ? res['data'].where((item) {
          final status =
              (item['status'] ?? '').toString().toLowerCase();

          return status != 'selesai' &&
                 status != 'ditolak';
        }).toList()
      : res['data'];

  lastPage = meta['last_page'];
  isLoading = false;
});
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _namaFileFromPath(String path) {
    return path.split('/').last.split('?').first;
  }

  String? _getSuratUrl(Map item) {
    for (final key in ['surat_url', 'surat_path', 'file_surat']) {
      final val = item[key];
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString();
      }
    }
    return null;
  }

  Future<void> _aksiVerifikasi(Map item, String action, String catatan) async {
    setState(() => isProcessingAction = true);
    try {
      await _api.verifikasiPengajuan(
        item['id'],
        action: action,
        catatan: catatan.isNotEmpty ? catatan : null,
      );
      await _loadPengajuan(reset: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'verifikasi'
                ? 'Berkas berhasil diverifikasi'
                : 'Berkas ditolak'),
            backgroundColor: action == 'verifikasi' ? Colors.green : Colors.red,
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
      setState(() => isProcessingAction = false);
    }
  }

  Future<void> _aksiTeruskan(Map item, String catatan) async {
    setState(() => isProcessingAction = true);
    try {
      await _api.teruskanPengajuan(
        item['id'],
        catatan: catatan.isNotEmpty ? catatan : null,
      );
      await _loadPengajuan(reset: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan berhasil diteruskan ke Kasi'),
            backgroundColor: Colors.blue,
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
      setState(() => isProcessingAction = false);
    }
  }

  Future<void> _aksiUploadSurat(Map item) async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _showUploadSuratSheet(item);
  }

  void _showUploadSuratSheet(Map item) {
    PlatformFile? selectedFile;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.upload_file, color: Colors.purple.shade700),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Upload Surat",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Format: PDF (maks. 5MB)",
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _uploadInfoRow(Icons.person_outline, "Nama",
                            item['user']?['nama'] ?? '-'),
                        const SizedBox(height: 8),
                        _uploadInfoRow(Icons.description_outlined, "Jenis Surat",
                            item['jenis_surat']?['nama'] ?? '-'),
                        const SizedBox(height: 8),
                        _uploadInfoRow(Icons.tag, "Nomor", item['nomor_pengajuan'] ?? '-'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: isUploading
                        ? null
                        : () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                              withData: true,
                              withReadStream: false,
                            );
                            if (result != null) {
                              final file = result.files.first;
                              if (file.size > 5 * 1024 * 1024) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ukuran file melebihi 5MB'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }
                              setSheetState(() => selectedFile = file);
                            }
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: selectedFile != null
                            ? Colors.purple.shade50
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedFile != null
                              ? Colors.purple.shade300
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: selectedFile == null
                          ? Column(
                              children: [
                                Icon(Icons.picture_as_pdf,
                                    size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  "Ketuk untuk pilih file PDF",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.picture_as_pdf,
                                    color: Colors.purple.shade700, size: 28),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    selectedFile!.name,
                                    style: TextStyle(
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () =>
                                      setSheetState(() => selectedFile = null),
                                  child: Icon(Icons.close,
                                      color: Colors.grey.shade500, size: 20),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.upload),
                      label: Text(isUploading ? "Mengunggah..." : "Upload Surat"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedFile != null
                            ? Colors.purple
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: (selectedFile == null || isUploading)
                          ? null
                          : () async {
                              setSheetState(() => isUploading = true);
                              try {
                                await _api.uploadSurat(item['id'], selectedFile!);
                                if (mounted) {
                                  Navigator.pop(ctx);
                                  _loadPengajuan(reset: true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Surat berhasil diupload'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setSheetState(() => isUploading = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _uploadInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text("$label: ", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("Verifikasi Berkas"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTab("Semua"),
                _buildTab("diproses"),
                _buildTab("diverifikasi"),
                _buildTab("menunggu_kasi"),
                _buildTab("disetujui_kasi"),
                _buildTab("ditolak"),
                _buildTab("selesai"),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : pengajuanList.isEmpty
                    ? const Center(child: Text("Belum ada pengajuan"))
                    : RefreshIndicator(
                        onRefresh: () => _loadPengajuan(reset: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: pengajuanList.length,
                          itemBuilder: (context, index) =>
                              _buildCard(pengajuanList[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    final active = selectedTab == text;
    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = text);
        _loadPengajuan(reset: true);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2F80ED) : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          _labelTab(text),
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _labelTab(String key) {
    switch (key) {
      case 'Semua':          return 'SEMUA';
      case 'menunggu':       return 'MENUNGGU';
      case 'diproses':       return 'DIPROSES';
      case 'diverifikasi':   return 'DIVERIFIKASI';
      case 'menunggu_kasi':  return 'MENUNGGU KASI';
      case 'disetujui_kasi': return 'DISETUJUI KASI';
      case 'ditolak':        return 'DITOLAK';
      case 'selesai':        return 'SELESAI';
      default:               return key.toUpperCase();
    }
  }

  Widget _buildCard(Map item) {
    final status = (item['status'] ?? '').toString().toLowerCase().trim();
    final color = _getStatusColor(status);
    final suratUrl = _getSuratUrl(item);

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
                      Text(item['user']?['nama'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(item['jenis_surat']?['nama'] ?? '-',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(item['nomor_pengajuan'] ?? '-',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(item['tanggal'] ?? '-',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(_labelTab(status),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                if (status == 'disetujui_kasi')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: const Text('Upload Surat',
                        style: TextStyle(
                            color: Colors.purple,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                if (status == 'selesai' && suratUrl != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.picture_as_pdf,
                            size: 13, color: Colors.purple.shade700),
                        const SizedBox(width: 4),
                        Text('Surat tersedia',
                            style: TextStyle(
                                color: Colors.purple.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(Map itemFromList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return _DetailSheetContent(
          api: _api,
          itemId: itemFromList['id'],
          isProcessingAction: isProcessingAction,
          onVerifikasi: _aksiVerifikasi,
          onTeruskan: _aksiTeruskan,
          onUploadSurat: _aksiUploadSurat,
          labelTab: _labelTab,
          getStatusColor: _getStatusColor,
          getSuratUrl: _getSuratUrl,
          namaFileFromPath: _namaFileFromPath,
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu':       return Colors.grey;
      case 'diproses':       return Colors.orange;
      case 'diverifikasi':   return Colors.blue;
      case 'menunggu_kasi':  return Colors.amber.shade700;
      case 'disetujui_kasi': return const Color.fromARGB(255, 85, 136, 244);
      case 'ditolak':        return Colors.red;
      case 'selesai':        return Colors.green;
      default:               return Colors.grey;
    }
  }
}

class _DetailSheetContent extends StatefulWidget {
  final ApiService api;
  final int itemId;
  final bool isProcessingAction;
  final Function(Map, String, String) onVerifikasi;
  final Function(Map, String) onTeruskan;
  final Function(Map) onUploadSurat;
  final String Function(String) labelTab;
  final Color Function(String) getStatusColor;
  final String? Function(Map) getSuratUrl;
  final String Function(String) namaFileFromPath;

  const _DetailSheetContent({
    required this.api,
    required this.itemId,
    required this.isProcessingAction,
    required this.onVerifikasi,
    required this.onTeruskan,
    required this.onUploadSurat,
    required this.labelTab,
    required this.getStatusColor,
    required this.getSuratUrl,
    required this.namaFileFromPath,
  });

  @override
  State<_DetailSheetContent> createState() => _DetailSheetContentState();
}

class _DetailSheetContentState extends State<_DetailSheetContent> {
  bool _loading = true;
  Map? _item;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final res = await widget.api.getDetailPengajuanPetugas(widget.itemId);
      setState(() {
        _item = res['data'] as Map;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ─── Buka surat di tab baru (works di web & mobile)
  Future<void> _bukaSurat(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }
  Future<void> _bukaBerkas(String url) async {
  final uri = Uri.parse(url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Tidak dapat membuka file');
  }
}

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final item = _item!;
    final status = (item['status'] ?? '').toString().toLowerCase().trim();
    final color = widget.getStatusColor(status);
    final alasanController = TextEditingController(text: item['catatan'] ?? '');
    final berkas = item['berkas'] as List? ?? [];
    final suratUrl = widget.getSuratUrl(item);

    Widget tombolVerifikasi() => Column(
          children: [
            TextField(
              controller: alasanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Catatan / alasan (opsional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text("Tolak"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: widget.isProcessingAction
                        ? null
                        : () {
                            Navigator.pop(context);
                            widget.onVerifikasi(item, 'tolak', alasanController.text);
                          },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Verifikasi"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: widget.isProcessingAction
                        ? null
                        : () async {
                            Navigator.pop(context);
                            await widget.onVerifikasi(
                                item, 'verifikasi', alasanController.text);
                          },
                  ),
                ),
              ],
            ),
          ],
        );

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
            const Text("Detail Pengajuan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _detailItem("Nama", item['user']?['nama'] ?? '-'),
            _detailItem("Jenis", item['jenis_surat']?['nama'] ?? '-'),
            _detailItem("Nomor", item['nomor_pengajuan'] ?? '-'),
            _detailItem("Tanggal", item['tanggal'] ?? '-'),
            _detailItem("Tujuan", item['tujuan'] ?? '-'),
            _detailItem("Status", widget.labelTab(status), valueColor: color),

            if (item['catatan'] != null && item['catatan'].toString().isNotEmpty)
              _detailItem("Catatan Petugas", item['catatan']),

            if (item['alasan_penolakan'] != null)
              _detailItem("Alasan Penolakan", item['alasan_penolakan'],
                  valueColor: Colors.red),

            const SizedBox(height: 10),

            // ─── Berkas persyaratan
            const Text("Berkas", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...berkas.map((b) {
  final fileUrl = b['url'];

  return GestureDetector(
    onTap: fileUrl != null
        ? () => _bukaBerkas(fileUrl)
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
                  b['nama_berkas'] ?? '-',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Klik untuk melihat berkas',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.open_in_new,
            size: 18,
            color: Colors.blue,
          ),
        ],
      ),
    ),
  );
}).toList(),

if (status == 'selesai' && suratUrl != null) ...[
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
        Icon(
          Icons.picture_as_pdf,
          color: Colors.green.shade700,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "Surat berhasil diupload dan siap dilihat.",
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    ),
  ),

  const SizedBox(height: 12),

  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      icon: const Icon(Icons.open_in_new),
      label: const Text("Lihat Surat"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: () => _bukaSurat(suratUrl),
    ),
  ),
],

            const SizedBox(height: 20),

            // ─── AKSI berdasarkan status
            if (status == 'menunggu') tombolVerifikasi(),
            if (status == 'diproses') tombolVerifikasi(),

            if (status == 'diverifikasi') ...[
              TextField(
                controller: alasanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Catatan tambahan (opsional)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("Teruskan ke Kasi"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      foregroundColor: Colors.white),
                  onPressed: widget.isProcessingAction
                      ? null
                      : () {
                          Navigator.pop(context);
                          widget.onTeruskan(item, alasanController.text);
                        },
                ),
              ),
            ],

            if (status == 'menunggu_kasi') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                          "Pengajuan sedang menunggu validasi dari Kasi",
                          style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              ),
            ],

            if (status == 'disetujui_kasi') ...[
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
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                          "Kasi telah menyetujui pengajuan ini. Silakan upload surat.",
                          style: TextStyle(color: Colors.green)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Surat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: widget.isProcessingAction
                      ? null
                      : () => widget.onUploadSurat(item),
                ),
              ),
            ],

            const SizedBox(height: 10),
          ],
        ),
      ),
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
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}