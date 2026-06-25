import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';

// ─── Design tokens (selaras dengan halaman Verifikasi & Pengaduan) ───
const Color _kPrimary = Color(0xFF2F80ED);
const Color _kPrimaryDark = Color(0xFF1B5FC4);

class MonitoringPetugasPage extends StatefulWidget {
  const MonitoringPetugasPage({super.key});

  @override
  State<MonitoringPetugasPage> createState() => _MonitoringPetugasPageState();
}

class _MonitoringPetugasPageState extends State<MonitoringPetugasPage> {
  final ApiService _api = ApiService();

  bool isLoading = true;
  bool isExporting = false;
  String selectedFilter = "Semua";
  List dataMonitoring = [];
  int currentPage = 1;
  int lastPage = 1;
  int totalData = 0;

  // Filter tanggal
  DateTime? tanggalMulai;
  DateTime? tanggalAkhir;

  final List<String> filterOptions = ["Semua", "Diproses", "Selesai", "Ditolak"];

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
        tanggalMulai: tanggalMulai != null
            ? '${tanggalMulai!.year}-${tanggalMulai!.month.toString().padLeft(2, '0')}-${tanggalMulai!.day.toString().padLeft(2, '0')}'
            : null,
        tanggalAkhir: tanggalAkhir != null
            ? '${tanggalAkhir!.year}-${tanggalAkhir!.month.toString().padLeft(2, '0')}-${tanggalAkhir!.day.toString().padLeft(2, '0')}'
            : null,
      );

      final meta = res['meta'];
      setState(() {
        dataMonitoring = res['data'];
        lastPage = meta['last_page'];
        totalData = meta['total'];
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

  // ─── LOAD SEMUA DATA UNTUK EXPORT ────────────────────────────────────────
  Future<List> _loadAllDataForExport() async {
    List allData = [];
    int page = 1;
    int total = 1;

    while (page <= total) {
      final res = await _api.getMonitoringPetugas(
        status: selectedFilter == "Semua" ? null : selectedFilter.toLowerCase(),
        page: page,
        tanggalMulai: tanggalMulai != null
            ? '${tanggalMulai!.year}-${tanggalMulai!.month.toString().padLeft(2, '0')}-${tanggalMulai!.day.toString().padLeft(2, '0')}'
            : null,
        tanggalAkhir: tanggalAkhir != null
            ? '${tanggalAkhir!.year}-${tanggalAkhir!.month.toString().padLeft(2, '0')}-${tanggalAkhir!.day.toString().padLeft(2, '0')}'
            : null,
      );

      allData.addAll(res['data']);
      total = res['meta']['last_page'];
      page++;
    }

    return allData;
  }

  // ─── EXPORT EXCEL ─────────────────────────────────────────────────────────
  Future<void> _exportExcel() async {
    setState(() => isExporting = true);

    try {
      final allData = await _loadAllDataForExport();

      final excel = Excel.createExcel();
      final sheet = excel['Monitoring Pengajuan'];

      // ── Style helper ──
      CellStyle headerStyle() => CellStyle(
            bold: true,
            backgroundColorHex: ExcelColor.fromHexString('#1C4FA1'),
            fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
          );

      // ── BARIS 1: Judul laporan ──
      final judulPeriode = _judulPeriode();
      sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('G1'));
      final judulCell = sheet.cell(CellIndex.indexByString('A1'));
      judulCell.value = TextCellValue('LAPORAN MONITORING PENGAJUAN');
      judulCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
        horizontalAlign: HorizontalAlign.Center,
        fontColorHex: ExcelColor.fromHexString('#1C4FA1'),
      );

      // ── BARIS 2: Periode ──
      sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('G2'));
      final periodeCell = sheet.cell(CellIndex.indexByString('A2'));
      periodeCell.value = TextCellValue('Kecamatan Kundur Barat — $judulPeriode');
      periodeCell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        fontColorHex: ExcelColor.fromHexString('#475569'),
      );

      // ── BARIS 3: Kosong ──
      sheet.merge(CellIndex.indexByString('A3'), CellIndex.indexByString('G3'));

      // ── BARIS 4: Ringkasan ──
      sheet.merge(CellIndex.indexByString('A4'), CellIndex.indexByString('G4'));
      final ringkasanCell = sheet.cell(CellIndex.indexByString('A4'));
      ringkasanCell.value = TextCellValue(
          'Total: ${allData.length} pengajuan  |  Filter: $selectedFilter');
      ringkasanCell.cellStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F1F5F9'),
        fontColorHex: ExcelColor.fromHexString('#334155'),
        horizontalAlign: HorizontalAlign.Center,
      );

      // ── BARIS 5: Kosong ──
      sheet.merge(CellIndex.indexByString('A5'), CellIndex.indexByString('G5'));

      // ── BARIS 6: Header kolom ──
      final headers = ['No', 'Nomor Pengajuan', 'Nama Warga', 'Jenis Surat', 'Status', 'Keterangan', 'Tanggal'];
      final headerCols = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByString('${headerCols[i]}6'));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle();
      }

      // ── Lebar kolom ──
      sheet.setColumnWidth(0, 6);   // No
      sheet.setColumnWidth(1, 26);  // Nomor Pengajuan
      sheet.setColumnWidth(2, 28);  // Nama Warga
      sheet.setColumnWidth(3, 28);  // Jenis Surat
      sheet.setColumnWidth(4, 18);  // Status
      sheet.setColumnWidth(5, 30);  // Keterangan
      sheet.setColumnWidth(6, 16);  // Tanggal

      // ── BARIS DATA (sekaligus zebra stripe digabung dengan style status) ──
      for (int i = 0; i < allData.length; i++) {
        final item = allData[i];
        final row = i + 7; // mulai baris 7
        final status = item['status'] ?? '-';
        final isZebra = i % 2 == 1;
        final zebraBg = isZebra ? '#F8FAFC' : '#FFFFFF';

        final rowData = [
          (i + 1).toString(),
          item['nomor_pengajuan'] ?? '-',
          item['nama'] ?? '-',
          item['jenis'] ?? '-',
          status,
          item['keterangan'] ?? '-',
          item['tanggal'] ?? '-',
        ];

        for (int j = 0; j < rowData.length; j++) {
          final cell = sheet.cell(CellIndex.indexByString('${headerCols[j]}$row'));
          cell.value = TextCellValue(rowData[j]);

          if (j == 4) {
            // Kolom Status: warna teks sesuai status, background ikut pola zebra
            final statusColor = _getStatusHex(status);
            cell.cellStyle = CellStyle(
              fontColorHex: ExcelColor.fromHexString(statusColor),
              backgroundColorHex: ExcelColor.fromHexString(zebraBg),
              bold: true,
              horizontalAlign: HorizontalAlign.Center,
            );
          } else {
            cell.cellStyle = CellStyle(
              backgroundColorHex: ExcelColor.fromHexString(zebraBg),
              horizontalAlign:
                  (j == 0 || j == 6) ? HorizontalAlign.Center : HorizontalAlign.Left,
            );
          }
        }
      }

      // ── BARIS AKHIR: Footer ──
      final footerRow = allData.length + 8;
      sheet.merge(
        CellIndex.indexByString('A$footerRow'),
        CellIndex.indexByString('G$footerRow'),
      );
      final footerCell = sheet.cell(CellIndex.indexByString('A$footerRow'));
      footerCell.value = TextCellValue(
          'Dicetak pada: ${_formatTanggalHariIni()}  —  Sistem Informasi Kecamatan Kundur Barat');
      footerCell.cellStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#94A3B8'),
        horizontalAlign: HorizontalAlign.Center,
      );

      // ── HAPUS sheet default "Sheet1" ──
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // ── SIMPAN & SHARE FILE ──
      final bytes = excel.encode();
      if (bytes == null) throw Exception('Gagal membuat file Excel');

      final namaFile =
          'Monitoring_${selectedFilter}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      if (kIsWeb) {
        await Share.shareXFiles(
          [
            XFile.fromData(
              Uint8List.fromList(bytes),
              mimeType:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              name: namaFile,
            )
          ],
          subject: 'Laporan Monitoring Pengajuan — $judulPeriode',
        );
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$namaFile');

        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Laporan Monitoring Pengajuan — $judulPeriode',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isExporting = false);
    }
  }

  String _getStatusHex(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
      case 'diverifikasi':
      case 'diteruskan':
        return '#F97316';
      case 'selesai':
        return '#22C55E';
      case 'ditolak':
        return '#EF4444';
      default:
        return '#94A3B8';
    }
  }

  String _judulPeriode() {
    if (tanggalMulai != null && tanggalAkhir != null) {
      return '${_fmt(tanggalMulai!)} – ${_fmt(tanggalAkhir!)}';
    } else if (tanggalMulai != null) {
      return 'Mulai ${_fmt(tanggalMulai!)}';
    } else if (tanggalAkhir != null) {
      return 'Sampai ${_fmt(tanggalAkhir!)}';
    }
    return 'Semua Periode';
  }

  String _fmt(DateTime d) {
    const bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${bulan[d.month]} ${d.year}';
  }

  String _formatTanggalHariIni() => _fmt(DateTime.now());

  // ─── PILIH PERIODE CEPAT ─────────────────────────────────────────────────
  void _showPeriodePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44, height: 5,
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kPrimary, _kPrimaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _kPrimary.withOpacity(0.32),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.event_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Pilih Periode Laporan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A2E4A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _periodeItem(Icons.calendar_view_month_rounded, 'Bulan Ini', () => _setPeriodeBulanIni()),
                _periodeItem(Icons.history_rounded, 'Bulan Lalu', () => _setPeriodeBulanLalu()),
                _periodeItem(Icons.calendar_today_rounded, '3 Bulan Terakhir', () => _setPeriode3Bulan()),
                _periodeItem(Icons.event_repeat_rounded, '6 Bulan Terakhir', () => _setPeriode6Bulan()),
                _periodeItem(Icons.event_note_rounded, 'Tahun Ini', () => _setPeriodeTahunIni()),
                _periodeItem(Icons.all_inclusive_rounded, 'Semua Data', () {
                  setState(() {
                    tanggalMulai = null;
                    tanggalAkhir = null;
                  });
                  Navigator.pop(context);
                  _loadMonitoring(reset: true);
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range_rounded, size: 18),
                    label: const Text('Pilih Tanggal Manual',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kPrimary,
                      side: BorderSide(color: _kPrimary.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _pilihTanggalManual();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _periodeItem(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: _kPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2E4A))),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _setPeriodeBulanIni() {
    final now = DateTime.now();
    setState(() {
      tanggalMulai = DateTime(now.year, now.month, 1);
      tanggalAkhir = DateTime(now.year, now.month + 1, 0);
    });
    Navigator.pop(context);
    _loadMonitoring(reset: true);
  }

  void _setPeriodeBulanLalu() {
    final now = DateTime.now();
    final bulanLalu = DateTime(now.year, now.month - 1, 1);
    setState(() {
      tanggalMulai = bulanLalu;
      tanggalAkhir = DateTime(now.year, now.month, 0);
    });
    Navigator.pop(context);
    _loadMonitoring(reset: true);
  }

  void _setPeriode3Bulan() {
    final now = DateTime.now();
    setState(() {
      tanggalMulai = DateTime(now.year, now.month - 2, 1);
      tanggalAkhir = now;
    });
    Navigator.pop(context);
    _loadMonitoring(reset: true);
  }

  void _setPeriode6Bulan() {
    final now = DateTime.now();
    setState(() {
      tanggalMulai = DateTime(now.year, now.month - 5, 1);
      tanggalAkhir = now;
    });
    Navigator.pop(context);
    _loadMonitoring(reset: true);
  }

  void _setPeriodeTahunIni() {
    final now = DateTime.now();
    setState(() {
      tanggalMulai = DateTime(now.year, 1, 1);
      tanggalAkhir = DateTime(now.year, 12, 31);
    });
    Navigator.pop(context);
    _loadMonitoring(reset: true);
  }

  Future<void> _pilihTanggalManual() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: tanggalMulai != null && tanggalAkhir != null
          ? DateTimeRange(start: tanggalMulai!, end: tanggalAkhir!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2F80ED)),
        ),
        child: child!,
      ),
    );

    if (range != null) {
      setState(() {
        tanggalMulai = range.start;
        tanggalAkhir = range.end;
      });
      _loadMonitoring(reset: true);
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final periodeAktif = tanggalMulai != null || tanggalAkhir != null;

    return AppScaffold(
      title: 'Monitoring Pengajuan',
      actions: [
        GestureDetector(
          onTap: isExporting ? null : _exportExcel,
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: isExporting
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.file_download_outlined, color: Colors.white, size: 16),
                      SizedBox(width: 5),
                      Text('Excel',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
        ),
      ],
      body: Column(
        children: [
          // ── FILTER STATUS + PERIODE (frosted glass) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: filterOptions.map((f) => _buildFilterChip(f)).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _showPeriodePicker,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            gradient: periodeAktif
                                ? const LinearGradient(colors: [_kPrimary, _kPrimaryDark])
                                : null,
                            color: periodeAktif ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: periodeAktif
                                ? [
                                    BoxShadow(
                                      color: _kPrimary.withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 14,
                                color: periodeAktif ? Colors.white : Colors.white.withOpacity(0.85),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                periodeAktif ? 'Periode' : 'Semua',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: periodeAktif ? Colors.white : Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── LABEL PERIODE AKTIF ──
          if (periodeAktif)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _judulPeriode(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          tanggalMulai = null;
                          tanggalAkhir = null;
                        });
                        _loadMonitoring(reset: true);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── KONTEN ──
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 38,
                            height: 38,
                            child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 3),
                          ),
                          SizedBox(height: 14),
                          Text('Memuat data monitoring...',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                        ],
                      ),
                    )
                  : dataMonitoring.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: _kPrimary.withOpacity(0.07),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.inbox_rounded,
                                    size: 36, color: _kPrimary.withOpacity(0.5)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada data pengajuan',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Coba ubah filter atau periode laporan',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12.5),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: _kPrimary,
                          onRefresh: () => _loadMonitoring(reset: true),
                          child: Column(
                            children: [
                              // Info total
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _kPrimary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$totalData pengajuan ditemukan',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: _kPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                                  itemCount: dataMonitoring.length +
                                      (currentPage < lastPage ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == dataMonitoring.length) {
                                      return _buildLoadMore();
                                    }
                                    return _buildCard(dataMonitoring[index]);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text) {
    final isActive = selectedFilter == text;
    final icon = _getFilterIcon(text);

    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = text);
        _loadMonitoring(reset: true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? const LinearGradient(colors: [_kPrimary, _kPrimaryDark]) : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _kPrimary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isActive ? Colors.white : Colors.white.withOpacity(0.85)),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.85),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilterIcon(String text) {
    switch (text) {
      case 'Diproses':
        return Icons.autorenew_rounded;
      case 'Selesai':
        return Icons.task_alt_rounded;
      case 'Ditolak':
        return Icons.cancel_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
      case 'diverifikasi':
      case 'diteruskan':
        return Icons.autorenew_rounded;
      case 'selesai':
        return Icons.task_alt_rounded;
      case 'ditolak':
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  Widget _buildCard(Map item) {
    final status = item['status'] ?? '-';
    final color = _getStatusColor(status);
    final hasKeterangan = item['keterangan'] != null && item['keterangan'] != '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.85), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_getStatusIcon(status), color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A2E4A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item['jenis'] ?? '-',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item['nomor_pengajuan'] ?? '-',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFB0BEC5)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (hasKeterangan) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['keterangan'],
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['tanggal'] ?? '-',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFFB0BEC5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Material(
          color: _kPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              setState(() => currentPage++);
              _loadMonitoring();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.expand_more_rounded, size: 18, color: _kPrimary),
                  const SizedBox(width: 6),
                  Text('Muat lebih banyak ($currentPage/$lastPage)',
                      style: const TextStyle(
                          color: _kPrimary, fontWeight: FontWeight.w700, fontSize: 12.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
      case 'diverifikasi':
      case 'diteruskan':
        return const Color(0xFFF97316);
      case 'selesai':
        return const Color(0xFF22C55E);
      case 'ditolak':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
      case 'diverifikasi':
      case 'diteruskan':
        return const Color(0xFFFFF7ED);
      case 'selesai':
        return const Color(0xFFF0FDF4);
      case 'ditolak':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }
}