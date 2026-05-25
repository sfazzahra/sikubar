import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  /// FR-08 / FR-36: Logout
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
      Uri.parse('$baseUrl/warga/pengajuan')
          .replace(queryParameters: query),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> getDetailPengajuan(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/warga/pengajuan/$id'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> buatPengajuan({
  required int jenisSuratId,
  required String tujuan,
  required List<Map<String, dynamic>> berkas,
}) async {

  final token = await _getToken();

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/warga/pengajuan'),
  );

  request.headers.addAll({
    'Accept': 'application/json',
    if (token != null)
      'Authorization': 'Bearer $token',
  });

  request.fields['jenis_surat_id'] =
    jenisSuratId.toString();

  request.fields['tujuan'] = tujuan;

  for (int i = 0; i < berkas.length; i++) {

    request.fields['berkas[$i][nama]'] =
        berkas[i]['nama'] as String;

    request.files.add(
      http.MultipartFile.fromBytes(
        'berkas[$i][file]',
        berkas[i]['bytes'] as Uint8List,
        filename:
            berkas[i]['filename'] as String,
      ),
    );
  }

  final streamed = await request.send();

  final res = await http.Response.fromStream(
    streamed,
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
      Uri.parse(
        '$baseUrl/warga/pengajuan/$pengajuanId/berkas/$berkasId',
      ),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

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
      return kirimPengaduan(
        judul: judul,
        isi: isi,
      );
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
        queryParameters: {
          'page': page.toString(),
        },
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
      if (seksiId != null)
        'seksi_id': seksiId.toString(),
      if (search != null) 'search': search,
    };

    final res = await http.get(
      Uri.parse('$baseUrl/admin/users')
          .replace(queryParameters: query),
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
      if (isActive != null)
        'is_active': isActive.toString(),
    };

    final res = await http.get(
      Uri.parse('$baseUrl/admin/jenis-surat')
          .replace(queryParameters: query),
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

  Future<Map<String, dynamic>> deleteJenisSurat(
    int id,
  ) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/jenis-surat/$id'),
      headers: await _headers(),
    );

    return _parse(res);
  }

  Future<Map<String, dynamic>> toggleAktifJenisSurat(
    int id,
  ) async {
    final res = await http.patch(
      Uri.parse(
        '$baseUrl/admin/jenis-surat/$id/toggle-active',
      ),
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