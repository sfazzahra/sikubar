<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class JenisSurat extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'jenis_surat';

    protected $fillable = [
        'nama',
        'kode',
        'deskripsi',
        'seksi_id',
        'persyaratan',
        'tujuan',
        'is_active',
    ];

    protected $casts = [
        'persyaratan' => 'array',
        'tujuan'      => 'array',
        'is_active'   => 'boolean',
    ];

    public function seksi()
    {
        return $this->belongsTo(Seksi::class, 'seksi_id');
    }

    public function pengajuan()
    {
        return $this->hasMany(Pengajuan::class, 'jenis_surat_id');
    }
}