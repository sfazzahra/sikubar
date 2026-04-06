class Pengajuan {
  final String id;
  final String judul;      // jenis surat
  final String deskripsi;  // alasan
  final DateTime tanggal;
  final String status;
  final String file;

  Pengajuan({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
    this.status = "Diproses",
    this.file = "-",
  });
}