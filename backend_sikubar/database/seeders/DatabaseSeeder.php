<?php

namespace Database\Seeders;

use App\Models\JenisSurat;
use App\Models\Seksi;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ===================== SEKSI =====================
        // ID 1-5 sesuai spesifikasi
        $seksiData = [
            ['id' => 1, 'nama' => 'Seksi Pemerintah',                  'kode' => 'SPM'],
            ['id' => 2, 'nama' => 'Seksi Ketentraman dan Ketertiban',   'kode' => 'SKK'],
            ['id' => 3, 'nama' => 'Seksi Pemberdayaan Masyarakat',      'kode' => 'SPB'],
            ['id' => 4, 'nama' => 'Seksi Kesejahteraan Sosial',         'kode' => 'SKS'],
            ['id' => 5, 'nama' => 'Seksi Lingkungan Hidup',             'kode' => 'SLH'],
        ];

        foreach ($seksiData as $data) {
            Seksi::updateOrCreate(['id' => $data['id']], $data);
        }

        // ===================== ADMIN =====================
        User::updateOrCreate(
            ['email' => 'admin@kecamatankundurbarat.go.id'],
            [
                'name'     => 'Administrator',
                'email'    => 'admin@kecamatankundurbarat.go.id',
                'password' => Hash::make('admin123'),
                'role'     => 'admin',
            ]
        );

        // ===================== CAMAT =====================
        User::updateOrCreate(
            ['email' => 'camat@kecamatankundurbarat.go.id'],
            [
                'name'     => 'Camat Kundur Barat',
                'email'    => 'camat@kecamatankundurbarat.go.id',
                'password' => Hash::make('camat123'),
                'role'     => 'camat',
            ]
        );

        // ===================== KASI (per seksi) =====================
        $kasiData = [
            ['seksi_id' => 1, 'name' => 'Kasi Pemerintah',                 'email' => 'kasi.pemerintah@kecamatankundurbarat.go.id'],
            ['seksi_id' => 2, 'name' => 'Kasi Ketentraman dan Ketertiban', 'email' => 'kasi.trantib@kecamatankundurbarat.go.id'],
            ['seksi_id' => 3, 'name' => 'Kasi Pemberdayaan Masyarakat',    'email' => 'kasi.pemberdayaan@kecamatankundurbarat.go.id'],
            ['seksi_id' => 4, 'name' => 'Kasi Kesejahteraan Sosial',       'email' => 'kasi.kessos@kecamatankundurbarat.go.id'],
            ['seksi_id' => 5, 'name' => 'Kasi Lingkungan Hidup',           'email' => 'kasi.lingkungan@kecamatankundurbarat.go.id'],
        ];

        foreach ($kasiData as $kasi) {
            User::updateOrCreate(
                ['email' => $kasi['email']],
                [
                    'name'      => $kasi['name'],
                    'password'  => Hash::make('kasi123'),
                    'role'      => 'kasi',
                    'seksi_id'  => $kasi['seksi_id'],
                ]
            );
        }

        // ===================== JENIS SURAT =====================
        // 5 jenis surat sesuai FR-03
        $jenisSuratData = [
            [
                'nama'        => 'Surat Rekomendasi BBM',
                'kode'        => 'BBM',
                'deskripsi'   => 'Surat rekomendasi untuk kebutuhan bahan bakar minyak.',
                'seksi_id'    => 1, // Seksi Pemerintah
                'persyaratan' => ['KTP', 'KK', 'Surat Permohonan'],
                'is_active'   => true,
            ],
            [
                'nama'        => 'Dispensasi Nikah',
                'kode'        => 'NIKAH',
                'deskripsi'   => 'Surat dispensasi untuk pernikahan di bawah umur.',
                'seksi_id'    => 1,
                'persyaratan' => ['KTP', 'KK', 'Akta Kelahiran', 'Surat Keterangan dari KUA'],
                'is_active'   => true,
            ],
            [
                'nama'        => 'Surat Keterangan Ahli Waris',
                'kode'        => 'WARIS',
                'deskripsi'   => 'Surat keterangan penetapan ahli waris.',
                'seksi_id'    => 1,
                'persyaratan' => ['KTP Pemohon', 'KK', 'Akta Kematian', 'KTP Ahli Waris'],
                'is_active'   => true,
            ],
            [
                'nama'        => 'Pembuatan Kartu Keluarga (KK)',
                'kode'        => 'KK',
                'deskripsi'   => 'Pengurusan pembuatan atau perubahan Kartu Keluarga.',
                'seksi_id'    => 1,
                'persyaratan' => ['KK Lama', 'KTP Kepala Keluarga', 'Akta Nikah/Cerai (jika ada)', 'Akta Kelahiran Anak'],
                'is_active'   => true,
            ],
            [
                'nama'        => 'Pembuatan KTP Elektronik',
                'kode'        => 'EKTP',
                'deskripsi'   => 'Pengurusan pembuatan atau perekaman KTP Elektronik.',
                'seksi_id'    => 1,
                'persyaratan' => ['KK', 'Akta Kelahiran', 'Foto 3x4 (2 lembar)'],
                'is_active'   => true,
            ],
        ];

        foreach ($jenisSuratData as $js) {
            JenisSurat::updateOrCreate(['kode' => $js['kode']], $js);
        }

        // ===================== WARGA CONTOH =====================
        User::updateOrCreate(
            ['nik' => '2101234567890001'],
            [
                'name'     => 'Budi Santoso',
                'nik'      => '2101234567890001',
                'password' => Hash::make('warga123'),
                'role'     => 'warga',
                'no_hp'    => '08123456789',
                'alamat'   => 'Jl. Merdeka No. 1, Kundur Barat',
            ]
        );
    }
}
