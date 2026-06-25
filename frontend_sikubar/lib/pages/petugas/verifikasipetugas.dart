import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';

// ─── Design tokens (warna & gaya konsisten untuk seluruh halaman) ───
const Color kPrimary = Color(0xFF2F80ED);
const Color kPrimaryDark = Color(0xFF1B5FC4);
const Color kAccent = Color(0xFF7C3AED);
const Color kAccentDark = Color(0xFF6024C4);

Color statusColor(String status) {
  switch (status) {
    case 'menunggu':
      return const Color(0xFF94A3B8);
    case 'diproses':
      return const Color(0xFFF59E0B);
    case 'diverifikasi':
      return kPrimary;
    case 'menunggu_kasi':
      return const Color(0xFFF97316);
    case 'disetujui_kasi':
      return const Color(0xFF6366F1);
    case 'ditolak':
      return const Color(0xFFEF4444);
    case 'selesai':
      return const Color(0xFF10B981);
    default:
      return const Color(0xFF94A3B8);
  }
}

IconData statusIcon(String status) {
  switch (status) {
    case 'menunggu':
      return Icons.schedule_rounded;
    case 'diproses':
      return Icons.autorenew_rounded;
    case 'diverifikasi':
      return Icons.fact_check_rounded;
    case 'menunggu_kasi':
      return Icons.hourglass_top_rounded;
    case 'disetujui_kasi':
      return Icons.verified_rounded;
    case 'ditolak':
      return Icons.cancel_rounded;
    case 'selesai':
      return Icons.task_alt_rounded;
    default:
      return Icons.description_rounded;
  }
}

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

  static const List<String> _tabs = [
    "Semua",
    "diverifikasi",
    "menunggu_kasi",
    "disetujui_kasi",
    "ditolak",
    "selesai",
  ];

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
                final status = (item['status'] ?? '').toString().toLowerCase();

                return status != 'selesai' && status != 'ditolak';
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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kAccent, kAccentDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kAccent.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.upload_file_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Upload Surat",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text("Format PDF, maksimal 5MB",
                                style:
                                    TextStyle(fontSize: 12.5, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _uploadInfoRow(Icons.person_outline, "Nama",
                            item['user']?['nama'] ?? '-'),
                        const SizedBox(height: 10),
                        _uploadInfoRow(Icons.description_outlined, "Jenis Surat",
                            item['jenis_surat']?['nama'] ?? '-'),
                        const SizedBox(height: 10),
                        _uploadInfoRow(
                            Icons.tag_rounded, "Nomor", item['nomor_pengajuan'] ?? '-'),
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
                    child: CustomPaint(
                      painter: _DashedRectPainter(
                        color: selectedFile != null
                            ? kAccent.withOpacity(0.6)
                            : Colors.grey.shade300,
                        radius: 18,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: selectedFile != null
                              ? kAccent.withOpacity(0.05)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: selectedFile == null
                            ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.picture_as_pdf_rounded,
                                        size: 30, color: Colors.grey.shade400),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Ketuk untuk pilih file PDF",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: kAccent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.picture_as_pdf_rounded,
                                        color: kAccent, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      selectedFile!.name,
                                      style: const TextStyle(
                                        color: kAccentDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () =>
                                        setSheetState(() => selectedFile = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close_rounded,
                                          color: Colors.grey.shade600, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: selectedFile != null && !isUploading
                            ? const LinearGradient(
                                colors: [kAccent, kAccentDark],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: (selectedFile == null || isUploading)
                            ? Colors.grey.shade300
                            : null,
                        boxShadow: selectedFile != null && !isUploading
                            ? [
                                BoxShadow(
                                  color: kAccent.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: (selectedFile == null || isUploading)
                              ? null
                              : () async {
                                  setSheetState(() => isUploading = true);
                                  try {
                                    await _api.uploadSurat(item['id'], selectedFile!);

                                    await _loadPengajuan(reset: true);


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
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isUploading)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4, color: Colors.white),
                                  )
                                else
                                  Icon(Icons.upload_rounded,
                                      color: selectedFile != null
                                          ? Colors.white
                                          : Colors.grey.shade500),
                                const SizedBox(width: 10),
                                Text(
                                  isUploading ? "Mengunggah..." : "Upload Surat",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                    color: selectedFile != null
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: kAccent),
        ),
        const SizedBox(width: 10),
        Text("$label  ",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
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
    return AppScaffold(
      title: "Verifikasi Berkas",
      actions: [],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _tabs.map(_buildTab).toList(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: isLoading
                  ? _buildLoadingState()
                  : pengajuanList.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          key: ValueKey('list-$selectedTab'),
                          color: kPrimary,
                          backgroundColor: Colors.white,
                          onRefresh: () => _loadPengajuan(reset: true),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                            itemCount: pengajuanList.length,
                            itemBuilder: (context, index) =>
                                _buildCard(pengajuanList[index]),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      key: ValueKey('loading'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ),
          SizedBox(height: 16),
          Text('Memuat pengajuan...',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_outlined, size: 38, color: Colors.white),
          ),
          const SizedBox(height: 18),
          const Text("Belum ada pengajuan",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.5)),
          const SizedBox(height: 6),
          Text("Pengajuan dengan status ini\nakan muncul di sini",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    final active = selectedTab == text;
    final icon = text == 'Semua' ? Icons.apps_rounded : statusIcon(text);

    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = text);
        _loadPengajuan(reset: true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [kPrimary, kPrimaryDark])
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: active ? Colors.white : Colors.white.withOpacity(0.85)),
            const SizedBox(width: 6),
            Text(
              _labelTab(text),
              style: TextStyle(
                color: active ? Colors.white : Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelTab(String key) {
    switch (key) {
      case 'Semua':
        return 'SEMUA';
      case 'menunggu':
        return 'MENUNGGU';
      case 'diproses':
        return 'DIPROSES';
      case 'diverifikasi':
        return 'DIVERIFIKASI';
      case 'menunggu_kasi':
        return 'MENUNGGU KASI';
      case 'disetujui_kasi':
        return 'DISETUJUI KASI';
      case 'ditolak':
        return 'DITOLAK';
      case 'selesai':
        return 'SELESAI';
      default:
        return key.toUpperCase();
    }
  }

  Widget _buildCard(Map item) {
    final status = (item['status'] ?? '').toString().toLowerCase().trim();
    final color = _getStatusColor(status);
    final icon = statusIcon(status);
    final suratUrl = _getSuratUrl(item);

    return GestureDetector(
      onTap: () => _showDetailSheet(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withOpacity(0.55), color]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.85), color],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['warga']?['nama'] ?? '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(item['jenis_surat']?['nama'] ?? '-',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12.5),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(item['nomor_pengajuan'] ?? '-',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.event_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(item['tanggal'] ?? '-',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 13, color: color),
                            const SizedBox(width: 6),
                            Text(_labelTab(status),
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (status == 'disetujui_kasi')
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: kAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upload_outlined, size: 13, color: kAccent),
                              const SizedBox(width: 4),
                              const Text('Upload Surat',
                                  style: TextStyle(
                                      color: kAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      if (status == 'selesai' && suratUrl != null)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: kAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.picture_as_pdf_rounded, size: 13, color: kAccent),
                              const SizedBox(width: 4),
                              const Text('Surat tersedia',
                                  style: TextStyle(
                                      color: kAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
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
      backgroundColor: Colors.transparent,
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
          getStatusIcon: statusIcon,
          getSuratUrl: _getSuratUrl,
          namaFileFromPath: _namaFileFromPath,
        );
      },
    );
  }

  Color _getStatusColor(String status) => statusColor(status);
}

// ─── Custom dashed-border painter, dipakai pada area drop file ───
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedRectPainter({
    this.color = Colors.grey,
    this.radius = 16,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.strokeWidth = 1.6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rRect);
    final dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ─── Bottom sheet detail pengajuan ───
class _DetailSheetContent extends StatefulWidget {
  final ApiService api;
  final int itemId;
  final bool isProcessingAction;
  final Function(Map, String, String) onVerifikasi;
  final Function(Map, String) onTeruskan;
  final Function(Map) onUploadSurat;
  final String Function(String) labelTab;
  final Color Function(String) getStatusColor;
  final IconData Function(String) getStatusIcon;
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
    required this.getStatusIcon,
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: _loading
          ? const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator(color: kPrimary)),
            )
          : _error != null
              ? SizedBox(
                  height: 220,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                )
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final item = _item!;
    final status = (item['status'] ?? '').toString().toLowerCase().trim();
    final color = widget.getStatusColor(status);
    final icon = widget.getStatusIcon(status);
    final alasanController = TextEditingController(text: item['catatan'] ?? '');
    final berkas = item['berkas'] as List? ?? [];
    final suratUrl = widget.getSuratUrl(item);

    final bool isActionable = status == 'menunggu' ||
        status == 'diproses' ||
        status == 'diverifikasi' ||
        status == 'disetujui_kasi';

    Widget tombolVerifikasi() => Column(
          children: [
            TextField(
              controller: alasanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Catatan / alasan (opsional)",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _pillButton(
                    label: "Tolak",
                    icon: Icons.close_rounded,
                    color: Colors.red,
                    onTap: widget.isProcessingAction
                        ? null
                        : () {
                            Navigator.pop(context);
                            widget.onVerifikasi(item, 'tolak', alasanController.text);
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pillButton(
                    label: "Verifikasi",
                    icon: Icons.check_rounded,
                    color: const Color(0xFF10B981),
                    onTap: widget.isProcessingAction
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

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // ─── Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.85), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Detail Pengajuan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(item['nomor_pengajuan'] ?? '-',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ─── Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text("Status: ${widget.labelTab(status)}",
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.w700, fontSize: 13.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ─── Info grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statTile("Nama", item['warga']?['nama'] ?? '-'),
              const SizedBox(width: 10),
              _statTile("Jenis Surat", item['jenis_surat']?['nama'] ?? '-'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statTile("Tanggal", item['tanggal'] ?? '-'),
              const SizedBox(width: 10),
              _statTile("Tujuan", item['tujuan'] ?? '-'),
            ],
          ),

          if (item['catatan'] != null && item['catatan'].toString().isNotEmpty)
            _calloutCard(
              icon: Icons.sticky_note_2_outlined,
              color: kPrimary,
              label: "Catatan Petugas",
              text: item['catatan'],
            ),

          if (item['alasan_penolakan'] != null)
            _calloutCard(
              icon: Icons.error_outline_rounded,
              color: const Color(0xFFEF4444),
              label: "Alasan Penolakan",
              text: item['alasan_penolakan'],
            ),

          const SizedBox(height: 22),

          // ─── Berkas persyaratan
          Row(
            children: [
              const Text("Berkas Persyaratan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("${berkas.length} file",
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...berkas.map((b) {
            final fileUrl = b['url'];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: fileUrl != null ? () => _bukaBerkas(fileUrl) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.picture_as_pdf_rounded,
                              color: Colors.red.shade600, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b['nama_berkas'] ?? '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13.5),
                              ),
                              const SizedBox(height: 3),
                              Text('Ketuk untuk membuka berkas',
                                  style: TextStyle(
                                      fontSize: 11, color: kPrimary.withOpacity(0.85))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.open_in_new_rounded,
                              size: 16, color: kPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          if (status == 'selesai' && suratUrl != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade50.withOpacity(0.4)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Icon(Icons.task_alt_rounded,
                            color: Colors.green.shade600, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text("Surat sudah siap dan dapat dilihat",
                            style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: _pillButton(
                      label: "Lihat Surat",
                      icon: Icons.open_in_new_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () => _bukaSurat(suratUrl),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isActionable) ...[
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade200)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text("TINDAKAN",
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade200)),
              ],
            ),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 8),

          if (status == 'menunggu') tombolVerifikasi(),
          if (status == 'diproses') tombolVerifikasi(),

          if (status == 'diverifikasi') ...[
            TextField(
              controller: alasanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Catatan tambahan (opsional)",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            _pillButton(
              label: "Teruskan ke Kasi",
              icon: Icons.send_rounded,
              color: kPrimary,
              fullWidth: true,
              onTap: widget.isProcessingAction
                  ? null
                  : () {
                      Navigator.pop(context);
                      widget.onTeruskan(item, alasanController.text);
                    },
            ),
          ],

          if (status == 'menunggu_kasi')
            _calloutCard(
              icon: Icons.hourglass_top_rounded,
              color: const Color(0xFFF97316),
              label: "Menunggu Kasi",
              text: "Pengajuan sedang menunggu validasi dari Kasi.",
              topMargin: 0,
            ),

          if (status == 'disetujui_kasi') ...[
            _calloutCard(
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              label: "Disetujui Kasi",
              text: "Kasi telah menyetujui pengajuan ini. Silakan upload surat.",
              topMargin: 0,
            ),
            const SizedBox(height: 14),
            _pillButton(
              label: "Upload Surat",
              icon: Icons.upload_file_rounded,
              color: kAccent,
              fullWidth: true,
              onTap: widget.isProcessingAction ? null : () => widget.onUploadSurat(item),
            ),
          ],

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ─── Reusable: stat tile (info grid 2 kolom)
  Widget _statTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ─── Reusable: callout card (catatan, alasan, info status)
  Widget _calloutCard({
    required IconData icon,
    required Color color,
    required String label,
    required String text,
    double topMargin = 14,
  }) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 3),
                Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reusable: tombol pill dengan gradient
  Widget _pillButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool fullWidth = false,
  }) {
    final disabled = onTap == null;
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: disabled ? Colors.grey.shade300 : color,
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}