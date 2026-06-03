<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Pengajuan extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'pengajuan';

    protected $fillable = [
        'nomor_pengajuan',
        'warga_id',
        'jenis_surat_id',
        'tujuan',
        'status',
        'catatan',
        'alasan_penolakan',
        'petugas_id',
        'kasi_id',
        'camat_id',
        'tanggal_diproses',
        'tanggal_selesai',
        'surat_path',
    ];

    protected $casts = [
        'tanggal_diproses' => 'datetime',
        'tanggal_selesai'  => 'datetime',
    ];

    // ===================== BOOT =====================

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            $model->nomor_pengajuan = self::generateNomor();
        });
    }

    public static function generateNomor(): string
    {
        $prefix = 'SKB';
        $date   = now()->format('Ymd');
        $count  = self::whereDate('created_at', today())->count() + 1;
        return sprintf('%s-%s-%04d', $prefix, $date, $count);
    }

    // ===================== RELATIONSHIPS =====================

    public function warga()
    {
        return $this->belongsTo(User::class, 'warga_id');
    }

    public function jenisSurat()
    {
        return $this->belongsTo(JenisSurat::class, 'jenis_surat_id');
    }

    public function petugas()
    {
        return $this->belongsTo(User::class, 'petugas_id');
    }

    public function kasi()
    {
        return $this->belongsTo(User::class, 'kasi_id');
    }

    public function camat()
    {
        return $this->belongsTo(User::class, 'camat_id');
    }

    public function berkas()
    {
        return $this->hasMany(BerkasPengajuan::class, 'pengajuan_id');
    }
}
