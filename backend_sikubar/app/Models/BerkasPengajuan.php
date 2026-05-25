<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BerkasPengajuan extends Model
{
    protected $table = 'berkas_pengajuan';

    protected $fillable = [
        'pengajuan_id',
        'nama_berkas',
        'file_path',
        'file_original',
        'mime_type',
        'file_size',
    ];

    public function pengajuan()
    {
        return $this->belongsTo(Pengajuan::class, 'pengajuan_id');
    }

    public function getFileUrlAttribute(): string
    {
        return asset('storage/' . $this->file_path);
    }
}
