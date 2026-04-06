import '../model/mpengajuan.dart';
import '../model/mpengaduan.dart';
import '../model/mprofil.dart';

class DataStore {
  /// ================= PENGAJUAN =================
  static List<Pengajuan> pengajuanList = [];

  static void tambahPengajuan(Pengajuan data) {
    pengajuanList.add(data);
  }

  static void hapusPengajuan(int index) {
    pengajuanList.removeAt(index);
  }

  /// ================= PENGADUAN =================
  static List<Pengaduan> pengaduanList = [];

  static void tambahPengaduan(Pengaduan data) {
    pengaduanList.add(data);
  }

  static void hapusPengaduan(int index) {
    pengaduanList.removeAt(index);
  }

  static void clearPengajuan() {
    pengajuanList.clear();
  }

  static void clearPengaduan() {
    pengaduanList.clear();
  }

  /// ================= PROFIL =================
  static Profil profil = Profil(
    nik: "1234567890123456",
    nama: "Siti Fatimah Az-zahra",
    alamat: "Batam",
    noHp: "08123456789",
  );

  static void updateProfil(Profil data) {
    profil = data;
  }
}