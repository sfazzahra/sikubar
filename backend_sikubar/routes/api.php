<?php

use App\Http\Controllers\Auth\StaffAuthController;
use App\Http\Controllers\Auth\WargaAuthController;
use App\Http\Controllers\Admin\JenisSuratController;
use App\Http\Controllers\Admin\ProfileController as AdminProfileController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Warga\PengaduanController;
use App\Http\Controllers\Warga\PengajuanController;
use App\Http\Controllers\Warga\ProfileController as WargaProfileController;
use App\Http\Controllers\petugas\VerifikasiPetugasController;
use App\Http\Controllers\petugas\PengaduanPetugasController;
use App\Http\Controllers\petugas\MonitoringPetugasController;
use App\Http\Controllers\petugas\ProfilePetugasController;
use App\Http\Controllers\Kasi\ProfileKasiController;
use App\Http\Controllers\Kasi\ValidasiKasiController;
use App\Http\Controllers\Camat\CamatController;
use App\Http\Controllers\Camat\ProfileCamatController;
use App\Http\Controllers\NotificationController;
use Illuminate\Support\Facades\Route;

// ============================================================
// AUTH — Tanpa token
// ============================================================
Route::prefix('warga')->group(function () {
    Route::post('login', [WargaAuthController::class, 'login']);
});

Route::prefix('staff')->group(function () {
    Route::post('login', [StaffAuthController::class, 'login']);
});

// ============================================================
// WARGA
// ============================================================
Route::middleware(['auth:sanctum', 'role:warga'])->prefix('warga')->group(function () {

    Route::post('logout', [WargaAuthController::class, 'logout']);
    Route::get('me',      [WargaAuthController::class, 'me']);

    // Profil
    Route::get ('profile',          [WargaProfileController::class, 'show']);
    Route::put ('profile',          [WargaProfileController::class, 'update']);
    Route::post('profile/foto',     [WargaProfileController::class, 'updateFoto']);
    Route::put ('profile/password', [WargaProfileController::class, 'updatePassword']);

    // Jenis surat aktif (persyaratan + tujuan)
    Route::get('jenis-surat', [PengajuanController::class, 'jenisSuratAktif']);

    // Pengajuan
    Route::get ('pengajuan',      [PengajuanController::class, 'index']);
    Route::post('pengajuan',      [PengajuanController::class, 'store']);
    Route::get ('pengajuan/{id}', [PengajuanController::class, 'show']);

    // Berkas — URUTAN PENTING: GET dulu sebelum POST agar tidak bentrok
    Route::get ('pengajuan/{pengajuanId}/berkas/{berkasId}',
        [PengajuanController::class, 'showBerkas']);    // ← BARU: ambil file_url

    Route::post('pengajuan/{id}/berkas',
        [PengajuanController::class, 'updateBerkas']);  // ganti semua berkas

    Route::post('pengajuan/{pengajuanId}/berkas/{berkasId}',
        [PengajuanController::class, 'replaceBerkas']); // ganti 1 berkas

    // Pengaduan
    Route::get ('pengaduan',      [PengaduanController::class, 'index']);
    Route::post('pengaduan',      [PengaduanController::class, 'store']);
    Route::get ('pengaduan/{id}', [PengaduanController::class, 'show']);
});

// ============================================================
// ADMIN
// ============================================================
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {

    Route::post('logout', [StaffAuthController::class, 'logout']);
    Route::get ('me',     [StaffAuthController::class, 'me']);

    Route::get ('profile',          [AdminProfileController::class, 'show']);
    Route::put ('profile',          [AdminProfileController::class, 'update']);
    Route::post('profile/foto',     [AdminProfileController::class, 'updateFoto']);
    Route::put ('profile/password', [AdminProfileController::class, 'updatePassword']);

    Route::apiResource('users', UserController::class);

    Route::apiResource('jenis-surat', JenisSuratController::class);
    Route::patch('jenis-surat/{id}/toggle-active',
        [JenisSuratController::class, 'toggleActive']);

    Route::get('seksi', function () {
        return response()->json([
            'success' => true,
            'data'    => \App\Models\Seksi::all(),
        ]);
    });
});

// ============================================================
// PETUGAS
// ============================================================
Route::middleware(['auth:sanctum', 'role:petugas'])->prefix('petugas')->group(function () {

    Route::get ('profile',          [ProfilePetugasController::class, 'show']);
    Route::put ('profile',          [ProfilePetugasController::class, 'update']);
    Route::post('profile/foto',     [ProfilePetugasController::class, 'updateFoto']);
    Route::put ('profile/password', [ProfilePetugasController::class, 'gantiPassword']);

    Route::get ('pengajuan',                          [VerifikasiPetugasController::class, 'index']);
    Route::get ('pengajuan/{id}',                     [VerifikasiPetugasController::class, 'show']);
    Route::post('pengajuan/{id}/verifikasi',          [VerifikasiPetugasController::class, 'verifikasi']);
    Route::post('pengajuan/{id}/teruskan',            [VerifikasiPetugasController::class, 'teruskan']);
    Route::post('pengajuan/{id}/upload-surat',        [VerifikasiPetugasController::class, 'uploadSurat']);

    Route::get ('pengaduan',                          [PengaduanPetugasController::class, 'index']);
    Route::get ('pengaduan/{id}',                     [PengaduanPetugasController::class, 'show']);
    Route::post('pengaduan/{id}/tanggapi',            [PengaduanPetugasController::class, 'tanggapi']);

    Route::get ('monitoring',                         [MonitoringPetugasController::class, 'index']);
    Route::get ('monitoring/statistik',               [MonitoringPetugasController::class, 'statistik']);
});

// ============================================================
// KASI
// ============================================================
Route::middleware(['auth:sanctum', 'role:kasi'])->prefix('kasi')->group(function () {

    Route::post('logout',           [ProfileKasiController::class, 'logout']);
    Route::get ('profile',          [ProfileKasiController::class, 'show']);
    Route::put ('profile',          [ProfileKasiController::class, 'update']);
    Route::put ('profile/password', [ProfileKasiController::class, 'gantiPassword']);

    Route::get ('statistik',              [ValidasiKasiController::class, 'statistik']);
    Route::get ('pengajuan',              [ValidasiKasiController::class, 'index']);
    Route::get ('pengajuan/{id}',         [ValidasiKasiController::class, 'show']);
    Route::post('pengajuan/{id}/setujui', [ValidasiKasiController::class, 'setujui']);
    Route::post('pengajuan/{id}/tolak',   [ValidasiKasiController::class, 'tolak']);
});

// ============================================================
// CAMAT
// ============================================================
Route::middleware(['auth:sanctum', 'role:camat'])->prefix('camat')->group(function () {
    Route::get('profile',              [ProfileCamatController::class, 'show']);
    Route::put('profile',              [ProfileCamatController::class, 'update']);
    Route::post('profile/foto',        [ProfileCamatController::class, 'updateFoto']);
    Route::put('profile/password',     [ProfileCamatController::class, 'updatePassword']);

    Route::get('dashboard',          [CamatController::class, 'dashboard']);
    Route::get('pengajuan',          [CamatController::class, 'indexPengajuan']);
    Route::get('pengajuan/{id}',     [CamatController::class, 'showPengajuan']);
    Route::get('pengaduan',          [CamatController::class, 'indexPengaduan']);
    Route::get('pengaduan/{id}',     [CamatController::class, 'showPengaduan']);
});


    // ─── NOTIFIKASI ──────────────────────────────────────────────────────
 Route::middleware('auth:sanctum')->prefix('notifikasi')->group(function () {
    Route::get('/',             [NotificationController::class, 'index']);
    Route::get('/unread-count', [NotificationController::class, 'unreadCount']);
    Route::put('/read-all',     [NotificationController::class, 'markAllAsRead']);
    Route::put('/{id}/read',    [NotificationController::class, 'markAsRead']);
});