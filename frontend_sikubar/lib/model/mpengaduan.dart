class Pengaduan {
  final String id;
  final String kategori;
  final String isi;
  final String file;
  final String status;
  final DateTime tanggal;

  Pengaduan({
    required this.id,
    required this.kategori,
    required this.isi,
    required this.file,
    this.status = "Dikirim",
    required this.tanggal,
  });
}