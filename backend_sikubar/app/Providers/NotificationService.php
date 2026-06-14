<?php

namespace App\Providers;

use App\Models\Notification;
use App\Models\User;


class NotificationService
{
    // ═══════════════════════════════════════════════════
    // PENGAJUAN SURAT
    // ═══════════════════════════════════════════════════

    /**
     * [Warga kirim pengajuan] → Notifikasi ke Petugas
     */
    public static function pengajuanBaru(int $petugasId, string $namawarga, string $jenisSurat, int $pengajuanId): void
    {
        self::create(
            userId  : $petugasId,
            judul   : 'Pengajuan Surat Baru',
            pesan   : "{$namawarga} mengajukan {$jenisSurat}. Silakan verifikasi berkas.",
            tipe    : 'pengajuan',
            data    : ['pengajuan_id' => $pengajuanId],
        );
    }

    /**
     * [Petugas verifikasi berkas] → Notifikasi ke Warga (status: diproses)
     */
    public static function pengajuanDiproses(int $wargaId, string $jenisSurat, int $pengajuanId): void
    {
        self::create(
            userId  : $wargaId,
            judul   : 'Pengajuan Sedang Diproses',
            pesan   : "Pengajuan {$jenisSurat} kamu sedang diverifikasi oleh petugas.",
            tipe    : 'pengajuan',
            data    : ['pengajuan_id' => $pengajuanId],
        );
    }

    /**
     * [Petugas tolak berkas] → Notifikasi ke Warga
     */
    public static function pengajuanDitolakPetugas(int $wargaId, string $jenisSurat, string $catatan, int $pengajuanId): void
    {
        self::create(
            userId  : $wargaId,
            judul   : 'Pengajuan Ditolak',
            pesan   : "Pengajuan {$jenisSurat} kamu ditolak oleh petugas. Alasan: {$catatan}",
            tipe    : 'pengajuan',
            data    : ['pengajuan_id' => $pengajuanId],
        );
    }

    /**
     * [Petugas teruskan ke Kasi] → Notifikasi ke Kasi
     */
    public static function pengajuanDiteruskanKeKasi(int $kasiId, string $namaWarga, string $jenisSurat, int $pengajuanId): void
    {
        self::create(
            userId  : $kasiId,
            judul   : 'Pengajuan Surat Masuk',
            pesan   : "Ada pengajuan {$jenisSurat} dari {$namaWarga} yang perlu divalidasi.",
            tipe    : 'pengajuan',
            data    : ['pengajuan_id' => $pengajuanId],
        );
    }

/**
 * [Kasi setujui] → Notifikasi ke Petugas
 */
public static function pengajuanDisetujuiKasiPetugas(
    int $petugasId,
    string $namaWarga,
    string $jenisSurat,
    int $pengajuanId
): void {
    self::create(
        userId: $petugasId,
        judul: 'Pengajuan Disetujui Kasi',
        pesan: "Pengajuan {$jenisSurat} dari {$namaWarga} telah disetujui Kasi. Silakan upload surat.",
        tipe: 'pengajuan',
        data: ['pengajuan_id' => $pengajuanId],
    );
}

/**
 * [Kasi setujui] → Notifikasi ke Warga
 */
public static function pengajuanDisetujuiKasiWarga(
    int $wargaId,
    string $jenisSurat,
    int $pengajuanId
): void {
    self::create(
        userId: $wargaId,
        judul: 'Pengajuan Disetujui',
        pesan: "Pengajuan {$jenisSurat} kamu telah disetujui. Surat sedang disiapkan.",
        tipe: 'pengajuan',
        data: ['pengajuan_id' => $pengajuanId],
    );
}

/**
 * [Kasi tolak] → Notifikasi ke Petugas
 */
public static function pengajuanDitolakKasiPetugas(
    int $petugasId,
    string $namaWarga,
    string $jenisSurat,
    string $alasan,
    int $pengajuanId
): void {
    self::create(
        userId: $petugasId,
        judul: 'Pengajuan Ditolak Kasi',
        pesan: "Pengajuan {$jenisSurat} dari {$namaWarga} ditolak Kasi. Alasan: {$alasan}",
        tipe: 'pengajuan',
        data: ['pengajuan_id' => $pengajuanId],
    );
}

/**
 * [Kasi tolak] → Notifikasi ke Warga
 */
public static function pengajuanDitolakKasiWarga(
    int $wargaId,
    string $jenisSurat,
    string $alasan,
    int $pengajuanId
): void {
    self::create(
        userId: $wargaId,
        judul: 'Pengajuan Ditolak',
        pesan: "Maaf, pengajuan {$jenisSurat} kamu ditolak. Alasan: {$alasan}",
        tipe: 'pengajuan',
        data: ['pengajuan_id' => $pengajuanId],
    );
}
    /**
     * [Petugas upload surat] → Notifikasi ke Kasi + Camat + Warga
     */
    public static function suratSelesaiDiupload(?int $kasiId, ?int $camatId, int $wargaId, string $namaWarga, string $jenisSurat, int $pengajuanId): void
    {
// ke Kasi
if ($kasiId !== null) {
    self::create(
        userId  : $kasiId,
        judul   : 'Surat Telah Diupload',
        pesan   : "Surat {$jenisSurat} untuk {$namaWarga} telah selesai diupload oleh petugas.",
        tipe    : 'pengajuan',
        data    : ['pengajuan_id' => $pengajuanId],
    );
}

// ke Camat
if ($camatId !== null) {
    self::create(
        userId  : $camatId,
        judul   : 'Surat Pengajuan Selesai',
        pesan   : "Surat {$jenisSurat} atas nama {$namaWarga} telah selesai diterbitkan.",
        tipe    : 'pengajuan',
        data    : ['pengajuan_id' => $pengajuanId],
    );
}
        
    }
public static function suratSelesaiUntukWarga(
    int $wargaId,
    string $jenisSurat,
    int $pengajuanId
): void
{
    self::create(
        userId  : $wargaId,
        judul   : 'Surat Kamu Sudah Siap',
        pesan   : "Surat {$jenisSurat} kamu sudah selesai. Silakan ambil ke kantor kecamatan.",
        tipe    : 'pengajuan',
        data    : ['pengajuan_id' => $pengajuanId],
    );
}
    // ═══════════════════════════════════════════════════
    // PENGADUAN
    // ═══════════════════════════════════════════════════

    /**
     * [Warga kirim pengaduan] → Notifikasi ke Petugas
     */
    public static function pengaduanBaru(int $petugasId, string $namaWarga, string $judul, int $pengaduanId): void
    {
        self::create(
            userId  : $petugasId,
            judul   : 'Pengaduan Baru Masuk',
            pesan   : "{$namaWarga} mengirim pengaduan: \"{$judul}\". Silakan ditanggapi.",
            tipe    : 'pengaduan',
            data    : ['pengaduan_id' => $pengaduanId],
        );
    }

    /**
     * [Petugas tanggapi pengaduan] → Notifikasi ke Warga
     */
    public static function pengaduanDitanggapi(int $wargaId, string $judulPengaduan, int $pengaduanId): void
    {
        self::create(
            userId  : $wargaId,
            judul   : 'Pengaduan Kamu Ditanggapi',
            pesan   : "Petugas telah memberikan tanggapan atas pengaduanmu: \"{$judulPengaduan}\".",
            tipe    : 'pengaduan',
            data    : ['pengaduan_id' => $pengaduanId],
        );
    }
    

    // ═══════════════════════════════════════════════════
    // PRIVATE: core create
    // ═══════════════════════════════════════════════════

    private static function create(
        int    $userId,
        string $judul,
        string $pesan,
        string $tipe,
        array  $data = [],
    ): void {

    
        Notification::create([
            'user_id' => $userId,
            'judul'   => $judul,
            'pesan'   => $pesan,
            'tipe'    => $tipe,
            'data'    => $data,
        ]);
    }
    
}