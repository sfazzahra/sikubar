<?php

use App\Http\Controllers\Auth\StaffAuthController;
use App\Http\Controllers\Auth\WargaAuthController;
use App\Http\Controllers\Admin\JenisSuratController;
use App\Http\Controllers\Admin\ProfileController as AdminProfileController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Warga\PengaduanController;
use App\Http\Controllers\Warga\PengajuanController;
use App\Http\Controllers\Warga\ProfileController as WargaProfileController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - SiKubar
|--------------------------------------------------------------------------
| Prefix: /api
|
| Auth:
|   - Warga   : POST /warga/login  (NIK + password)
|   - Staff   : POST /staff/login  (email + password)
|
*/

// ============================================================
// AUTH - Tidak perlu token
// ============================================================

// Warga: login dengan NIK
Route::prefix('warga')->group(function () {
    Route::post('login', [WargaAuthController::class, 'login']);
});

// Staff (admin, petugas, kasi, camat): login dengan email
Route::prefix('staff')->group(function () {
    Route::post('login', [StaffAuthController::class, 'login']);
});

// ============================================================
// WARGA - Butuh token + role:warga
// ============================================================

Route::middleware(['auth:sanctum', 'role:warga'])->prefix('warga')->group(function () {

    // FR-08: Logout
    Route::post('logout', [WargaAuthController::class, 'logout']);

    // Info diri
    Route::get('me', [WargaAuthController::class, 'me']);

    // FR-02: Profil warga
    Route::get('profile', [WargaProfileController::class, 'show']);
    Route::put('profile', [WargaProfileController::class, 'update']);
    Route::post('profile/foto', [WargaProfileController::class, 'updateFoto']);
    Route::put('profile/password', [WargaProfileController::class, 'updatePassword']);

    // FR-03 + FR-04: Pengajuan surat
    Route::get('jenis-surat', [PengajuanController::class, 'jenisSuratAktif']);        // daftar jenis surat aktif
    Route::get('pengajuan', [PengajuanController::class, 'index']);                    // FR-07: riwayat
    Route::post('pengajuan', [PengajuanController::class, 'store']);                   // FR-03 + FR-04: buat baru
    Route::get('pengajuan/{id}', [PengajuanController::class, 'show']);                // detail
    Route::post('pengajuan/{id}/berkas', [PengajuanController::class, 'updateBerkas']);// FR-05: ganti semua berkas
    Route::post('pengajuan/{id}/berkas/{berkasId}', [PengajuanController::class, 'replaceBerkas']); // FR-05: ganti 1 berkas

    // FR-06: Pengaduan/keluhan
    Route::get('pengaduan', [PengaduanController::class, 'index']);
    Route::post('pengaduan', [PengaduanController::class, 'store']);
    Route::get('pengaduan/{id}', [PengaduanController::class, 'show']);
});

// ============================================================
// ADMIN - Butuh token + role:admin
// ============================================================

Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {

    // FR-36: Logout
    Route::post('logout', [StaffAuthController::class, 'logout']);

    // Info diri
    Route::get('me', [StaffAuthController::class, 'me']);

    // FR-33: Profil admin
    Route::get('profile', [AdminProfileController::class, 'show']);
    Route::put('profile', [AdminProfileController::class, 'update']);
    Route::post('profile/foto', [AdminProfileController::class, 'updateFoto']);
    Route::put('profile/password', [AdminProfileController::class, 'updatePassword']);

    // FR-34: Manajemen pengguna (semua role)
    Route::apiResource('users', UserController::class);

    // FR-35: Manajemen jenis surat
    Route::apiResource('jenis-surat', JenisSuratController::class);
    Route::patch('jenis-surat/{id}/toggle-active', [JenisSuratController::class, 'toggleActive']);

    // Data referensi
    Route::get('seksi', function () {
        return response()->json([
            'success' => true,
            'data'    => \App\Models\Seksi::all(),
        ]);
    });
});
