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

    protected $appends = ['file_url', 'is_pendukung', 'nama_bersih'];

    public function pengajuan()
    {
        return $this->belongsTo(Pengajuan::class, 'pengajuan_id');
    }

    public function getFileUrlAttribute(): string
    {
        return asset('storage/' . $this->file_path);
    }

    public function getIsPendukungAttribute(): bool
    {
        return str_starts_with($this->nama_berkas ?? '', '[Pendukung]');
    }

    public function getNamaBersihAttribute(): string
    {
        return str_replace('[Pendukung] ', '', $this->nama_berkas ?? '');
    }
}