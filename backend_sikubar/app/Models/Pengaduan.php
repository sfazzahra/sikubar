<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Pengaduan extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'pengaduan';

    protected $fillable = [
        'warga_id',
        'judul',          // isi dari dropdown kategori di Flutter
        'isi',
        'bukti_path',     // BARU: path file di storage
        'bukti_original', // BARU: nama file asli
        'status',
        'balasan',
        'dibalas_oleh',
        'tanggal_dibalas',
    ];

    protected $casts = [
        'tanggal_dibalas' => 'datetime',
    ];

    // Accessor: URL lengkap bukti
    public function getBuktiUrlAttribute(): ?string
    {
        return $this->bukti_path
            ? asset('storage/' . $this->bukti_path)
            : null;
    }

    public function warga()
    {
        return $this->belongsTo(User::class, 'warga_id');
    }

    public function pembalas()
    {
        return $this->belongsTo(User::class, 'dibalas_oleh');
    }
}