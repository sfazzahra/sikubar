import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // ← tambah ini

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ─── HELPER: ambil token tersimpan ───────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ─── HELPER: header default (JSON) ───────────────────────────────────────
  Future<Map<String, String>> _headers({bool withToken = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (withToken) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ─── HELPER: parse response & lempar exception jika gagal ────────────────
  Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    String message = body['message'] ?? 'Terjadi kesalahan.';

    if (body['errors'] != null) {
      final errors = body['errors'] as Map<String, dynamic>;
      message = (errors.values.first as List).first.toString();
    }

    throw ApiException(message, res.statusCode);
  }

  // =========================================================================
  // AUTH
  // =========================================================================

  /// FR-01: Login warga — NIK + password
  Future<Map<String, dynamic>> loginWarga(
    String nik,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/warga/login'),
      headers: await _headers(withToken: false),
      body: jsonEncode({
        'nik': nik,
        'password': password,
      }),
    );

    return _parse(res);
  }

  /// FR-32: Login admin/staff — email + password
  Future<Map<String, dynamic>> loginStaff(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/staff/login'),
      headers: await _headers(withToken: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _parse(res);
  }

  /// FR-08 / FR-36: Logout warga & admin
  Future<void> logout({bool isWarga = true}) async {
    final endpoint = isWarga
        ? '/warga/logout'
        : '/admin/logout';

    await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('user_role');
  }

  // =========================================================================
  // WARGA — Profil (FR-02)
  // =========================================================================

  Future<Map<String, dynamic>> getProfil() async {
    final res = await http.get(
      Uri.parse('$baseUrl/warga/profile'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> updateProfil(
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/warga/profile'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> updateProfilWargaPassword(
    String passwordLama,
    String passwordBaru,
    String konfirmasi,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/warga/profile/password'),
      headers: await _headers(),
      body: jsonEncode({
        'password_lama': passwordLama,
        'password_baru': passwordBaru,
        'password_baru_confirmation': konfirmasi,
      }),
    );

    return _parse(res);
  }

  // =========================================================================
  // WARGA — Jenis Surat
  // =========================================================================

  Future<Map<String, dynamic>> getJenisSurat() async {
    final res = await http.get(
      Uri.parse('$baseUrl/warga/jenis-surat'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  // =========================================================================
  // WARGA — Pengajuan
  // =========================================================================

  Future<Map<String, dynamic>> getRiwayatPengajuan({
    int page = 1,
    String? status,
  }) async {
    final query = {
      'page': page.toString(),
      if (status != null) 'status': status,
    };
    final res = await http.get(
      Uri.parse('$baseUrl/warga/pengajuan').replace(queryParameters: query),
      headers: await _headers(),
    );
    return _parse(res);
  }
 
  Future<Map<String, dynamic>> getDetailPengajuan(int id) async {
    final res = await http.get(
        Uri.parse('$baseUrl/warga/pengajuan/$id'), headers: await _headers());
    return _parse(res);
  }
 
  /// FR-03 + FR-04: Buat pengajuan baru + upload berkas (berkas wajib & pendukung)
  /// berkas format: [{'nama': 'KTP', 'bytes': Uint8List, 'filename': 'ktp.jpg'}]
  Future<Map<String, dynamic>> buatPengajuan({
    required int jenisSuratId,
    String? tujuan,
    required List<Map<String, dynamic>> berkas,
  }) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/warga/pengajuan'));
 
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
 
    request.fields['jenis_surat_id'] = jenisSuratId.toString();
    if (tujuan != null && tujuan.isNotEmpty) {
      request.fields['tujuan'] = tujuan;
    }
 
    for (int i = 0; i < berkas.length; i++) {
      request.fields['berkas[$i][nama]'] = berkas[i]['nama'] as String;
      request.files.add(http.MultipartFile.fromBytes(
        'berkas[$i][file]',
        berkas[i]['bytes'] as Uint8List,
        filename: berkas[i]['filename'] as String,
      ));
    }
 
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");
    return _parse(res);
  }
 
  Future<Map<String, dynamic>> getBerkas(
      int pengajuanId, int berkasId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/warga/pengajuan/$pengajuanId/berkas/$berkasId'),
      headers: await _headers(),
    );
    return _parse(res);
  }
 
  Future<Map<String, dynamic>> replaceBerkas({
    required int pengajuanId,
    required int berkasId,
    required File file,
  }) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/warga/pengajuan/$pengajuanId/berkas/$berkasId'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _parse(res);
  }

  // =========================================================================
  // WARGA — Pengaduan
  // =========================================================================

  Future<Map<String, dynamic>> kirimPengaduan({
    required String judul,
    required String isi,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/warga/pengaduan'),
      headers: await _headers(),
      body: jsonEncode({
        'judul': judul,
        'isi': isi,
      }),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> kirimPengaduanDenganBukti({
    required String judul,
    required String isi,
    Uint8List? buktiBytes,
    String? buktiNama,
  }) async {
    if (buktiBytes == null) {
      return kirimPengaduan(judul: judul, isi: isi);
    }

    final token = await _getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/warga/pengaduan'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields['judul'] = judul;
    request.fields['isi'] = isi;

    if (buktiNama != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'bukti',
          buktiBytes,
          filename: buktiNama,
        ),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    return _parse(res);
  }

  Future<Map<String, dynamic>> getRiwayatPengaduan({
    int page = 1,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/warga/pengaduan').replace(
        queryParameters: {'page': page.toString()},
      ),
      headers: await _headers(),
    );

    return _parse(res);
  }

  // =========================================================================
  // ADMIN — Pengguna
  // =========================================================================

  Future<Map<String, dynamic>> getUsers({
    String? role,
    int? seksiId,
    String? search,
    int page = 1,
  }) async {
    final query = {
      'page': page.toString(),
      if (role != null) 'role': role,
      if (seksiId != null) 'seksi_id': seksiId.toString(),
      if (search != null) 'search': search,
    };

    final res = await http.get(
      Uri.parse('$baseUrl/admin/users').replace(queryParameters: query),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/users'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/users/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> deleteUser(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/users/$id'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  // =========================================================================
  // ADMIN — Jenis Surat
  // =========================================================================

  Future<Map<String, dynamic>> getJenisSuratAdmin({
    bool? isActive,
    int page = 1,
  }) async {
    final query = {
      'page': page.toString(),
      if (isActive != null) 'is_active': isActive.toString(),
    };

    final res = await http.get(
      Uri.parse('$baseUrl/admin/jenis-surat').replace(queryParameters: query),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> createJenisSurat(
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/jenis-surat'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> updateJenisSurat(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/jenis-surat/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> deleteJenisSurat(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/jenis-surat/$id'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> toggleAktifJenisSurat(int id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/admin/jenis-surat/$id/toggle-active'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  // =========================================================================
  // ADMIN — Profil
  // =========================================================================

  Future<Map<String, dynamic>> getProfilAdmin() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/profile'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> updateProfilAdmin(
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/profile'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> updatePasswordAdmin(
    String passwordLama,
    String passwordBaru,
    String konfirmasi,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/profile/password'),
      headers: await _headers(),
      body: jsonEncode({
        'password_lama': passwordLama,
        'password_baru': passwordBaru,
        'password_baru_confirmation': konfirmasi,
      }),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> getSeksi() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/seksi'),
      headers: await _headers(),
    );

    return _parse(res);
  }

   // =========================================================================
  // PETUGAS — Profil (FR-10, FR-17)
  // =========================================================================
 
  Future<Map<String, dynamic>> getProfilPetugas() async {
    final res = await http.get(
      Uri.parse('$baseUrl/petugas/profile'),
      headers: await _headers(),
    );
 
    return _parse(res);
  }
 
  Future<Map<String, dynamic>> updateProfilPetugas(
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/petugas/profile'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
 
    return _parse(res);
  }
 
  Future<Map<String, dynamic>> updatePasswordPetugas(
    String passwordLama,
    String passwordBaru,
    String konfirmasi,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/petugas/profile/password'),
      headers: await _headers(),
      body: jsonEncode({
        'password_lama': passwordLama,
        'password_baru': passwordBaru,
        'password_baru_confirmation': konfirmasi,
      }),
    );
 
    return _parse(res);
  }
 
  /// Alias — konsisten dengan pola updateProfilWargaPassword
  Future<Map<String, dynamic>> updateProfilPetugasPassword(
    String passwordLama,
    String passwordBaru,
    String konfirmasi,
  ) =>
      updatePasswordPetugas(passwordLama, passwordBaru, konfirmasi);
 
  Future<void> logoutPetugas() async {
    await http.post(
      Uri.parse('$baseUrl/petugas/logout'),
      headers: await _headers(),
    );
 
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('user_role');
  }

  // =========================================================================
  // PETUGAS — Pengajuan (FR-11, FR-12, FR-13)
  // =========================================================================

  Future<Map<String, dynamic>> getPengajuanPetugas({
    String? status,
    String? search,
    int page = 1,
  }) async {
    final query = {
      'page': page.toString(),
      if (status != null) 'status': status,
      if (search != null) 'search': search,
    };

    final res = await http.get(
      Uri.parse('$baseUrl/petugas/pengajuan').replace(queryParameters: query),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> getDetailPengajuanPetugas(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/petugas/pengajuan/$id'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> verifikasiPengajuan(
    int id, {
    required String action, // 'verifikasi' atau 'tolak'
    String? catatan,
  }) async {
    final res = await http.post(
  Uri.parse('$baseUrl/petugas/pengajuan/$id/verifikasi'),
  headers: await _headers(),
  body: jsonEncode({
    'action': action,
    if (catatan != null) 'catatan': catatan,
  }),
);

print("STATUS: ${res.statusCode}");
print("BODY: ${res.body}");

    return _parse(res);
  }

  Future<Map<String, dynamic>> teruskanPengajuan(
    int id, {
    String? catatan,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/petugas/pengajuan/$id/teruskan'),
      headers: await _headers(),
      body: jsonEncode({
        if (catatan != null) 'catatan': catatan,
      }),
    );

    return _parse(res);
  }

  // =========================================================================
  // PETUGAS — Upload Surat (FR-16)
  // =========================================================================
 
  Future<Map<String, dynamic>> uploadSurat(
  int pengajuanId,
  PlatformFile file,
) async {
  final token = await _getToken();

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/petugas/pengajuan/$pengajuanId/upload-surat'),
  );

  request.headers.addAll({
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  });

  // ✅ Web hanya support bytes, mobile bisa bytes atau path
  if (file.bytes != null) {
    request.files.add(
      http.MultipartFile.fromBytes(
        'surat',
        file.bytes!,
        filename: file.name,
      ),
    );
  } else if (file.path != null && !kIsWeb) {  // ← guard kIsWeb
    request.files.add(
      await http.MultipartFile.fromPath(
        'surat',
        file.path!,
        filename: file.name,
      ),
    );
  } else {
    throw ApiException('File tidak dapat dibaca', 400);
  }

  final streamed = await request.send();
  final res = await http.Response.fromStream(streamed);

  print('STATUS: ${res.statusCode}');
  print('BODY: ${res.body}');

  return _parse(res);
}

  // =========================================================================
  // PETUGAS — Pengaduan (FR-14)
  // =========================================================================

  Future<Map<String, dynamic>> getPengaduanPetugas({
    String? status,
    int page = 1,
  }) async {
    final query = {
      'page': page.toString(),
      if (status != null) 'status': status,
    };

    final res = await http.get(
      Uri.parse('$baseUrl/petugas/pengaduan').replace(queryParameters: query),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> getDetailPengaduanPetugas(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/petugas/pengaduan/$id'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> tanggapiPengaduan(
    int id,
    String balasan,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/petugas/pengaduan/$id/tanggapi'),
      headers: await _headers(),
      body: jsonEncode({'balasan': balasan}),
    );

    return _parse(res);
  }

  // =========================================================================
  // PETUGAS — Monitoring (FR-15)
  // =========================================================================

  Future<Map<String, dynamic>> getMonitoringPetugas({
    String? status,
    String? search,
    String? tanggalMulai,
    String? tanggalAkhir,
    int page = 1,
  }) async {
    final query = {
      'page': page.toString(),
      if (status != null) 'status': status,
      if (search != null) 'search': search,
      if (tanggalMulai != null) 'tanggal_mulai': tanggalMulai,
      if (tanggalAkhir != null) 'tanggal_akhir': tanggalAkhir,
    };

    final res = await http.get(
      Uri.parse('$baseUrl/petugas/monitoring').replace(queryParameters: query),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> getStatistikPetugas() async {
    final res = await http.get(
      Uri.parse('$baseUrl/petugas/monitoring/statistik'),
      headers: await _headers(),
    );

    return _parse(res);
  }
    // =========================================================================
  // KASI — PROFILE
  // =========================================================================
  Future<Map<String, dynamic>> getProfilKasi() async {
    final res = await http.get(
      Uri.parse('$baseUrl/kasi/profile'),
      headers: await _headers(),
    );
 
    return _parse(res);
  }
 
  Future<Map<String, dynamic>> updateProfilKasi(
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/kasi/profile'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
 
    return _parse(res);
  }
 
  Future<Map<String, dynamic>> updatePasswordKasi(
    String passwordLama,
    String passwordBaru,
    String konfirmasi,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/kasi/profile/password'),
      headers: await _headers(),
      body: jsonEncode({
        'password_lama': passwordLama,
        'password_baru': passwordBaru,
        'password_baru_confirmation': konfirmasi,
      }),
    );
 
    return _parse(res);
  }
 
  /// Alias — konsisten dengan pola updateProfilWargaPassword
  Future<Map<String, dynamic>> updateProfilKasiPassword(
    String passwordLama,
    String passwordBaru,
    String konfirmasi,
  ) =>
      updatePasswordKasi(passwordLama, passwordBaru, konfirmasi);
 
  Future<void> logoutKasi() async {
    await http.post(
      Uri.parse('$baseUrl/kasi/logout'),
      headers: await _headers(),
    );
 
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('user_role');
  }


  // =========================================================================
  // KASI — VALIDASI
  // =========================================================================

  Future<Map<String, dynamic>> getPengajuanKasi() async {
    final res = await http.get(
      Uri.parse('$baseUrl/kasi/pengajuan'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> getDetailPengajuanKasi(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/kasi/pengajuan/$id'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> approvePengajuanKasi(int id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/kasi/pengajuan/$id/setujui'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> tolakPengajuanKasi(
    int id,
    String alasan,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/kasi/pengajuan/$id/tolak'),
      headers: await _headers(),
      body: jsonEncode({
        'alasan_penolakan': alasan,
      }),
    );

    return _parse(res);
  }

    // =========================================================================
  // CAMAT — DASHBOARD
  // =========================================================================

  Future<Map<String, dynamic>> getCamatDashboard() async {
    final res = await http.get(
      Uri.parse('$baseUrl/camat/dashboard'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  // =========================================================================
  // CAMAT — PENGAJUAN
  // =========================================================================

  Future<Map<String, dynamic>> getCamatPengajuan({
    String? status,
    String? search,
    int page = 1,
  }) async {
    final query = {
      'page': page.toString(),
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final res = await http.get(
      Uri.parse('$baseUrl/camat/pengajuan')
          .replace(queryParameters: query),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> getCamatDetailPengajuan(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/camat/pengajuan/$id'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  // =========================================================================
  // CAMAT — PENGADUAN
  // =========================================================================

  Future<Map<String, dynamic>> getCamatPengaduan({
    String? status,
    String? search,
    int page = 1,
  }) async {
    final query = {
      'page': page.toString(),
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final res = await http.get(
      Uri.parse('$baseUrl/camat/pengaduan')
          .replace(queryParameters: query),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> getCamatDetailPengaduan(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/camat/pengaduan/$id'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> getNotifikasi() async {
  final res = await http.get(
    Uri.parse('$baseUrl/notifikasi'),
    headers: await _headers(),
  );

  return _parse(res);
}

Future<Map<String, dynamic>> getUnreadNotifikasiCount() async {
  final res = await http.get(
    Uri.parse('$baseUrl/notifikasi/unread-count'),
    headers: await _headers(),
  );

  return _parse(res);
}

Future<void> tandaiNotifikasiDibaca(int id) async {
  await http.put(
    Uri.parse('$baseUrl/notifikasi/$id/read'),
    headers: await _headers(),
  );
}

Future<void> tandaiSemuaNotifikasiDibaca() async {
  await http.put(
    Uri.parse('$baseUrl/notifikasi/read-all'),
    headers: await _headers(),
  );
}

// =========================================================================
// CAMAT — PROFILE
// =========================================================================

Future<Map<String, dynamic>> getProfilCamat() async {
  final res = await http.get(
    Uri.parse('$baseUrl/camat/profile'),
    headers: await _headers(),
  );

  return _parse(res);
}

Future<Map<String, dynamic>> updateProfilCamat(
  Map<String, dynamic> data,
) async {
  final res = await http.put(
    Uri.parse('$baseUrl/camat/profile'),
    headers: await _headers(),
    body: jsonEncode(data),
  );

  return _parse(res);
}

Future<Map<String, dynamic>> updatePasswordCamat(
  String passwordLama,
  String passwordBaru,
  String konfirmasi,
) async {
  final res = await http.put(
    Uri.parse('$baseUrl/camat/profile/password'),
    headers: await _headers(),
    body: jsonEncode({
      'password_lama': passwordLama,
      'password_baru': passwordBaru,
      'password_baru_confirmation': konfirmasi,
    }),
  );

  return _parse(res);
}

Future<void> logoutCamat() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('auth_token');
  await prefs.remove('user_data');
  await prefs.remove('user_role');
}
}
// ─── Custom exception ────────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(
    this.message,
    this.statusCode,
  );

  @override
  String toString() => message;
}

