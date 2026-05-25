<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $fillable = [
        'name',
        'nik',
        'email',
        'password',
        'role',
        'seksi_id',
        'no_hp',
        'alamat',
        'foto',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    // ===================== ROLE HELPERS =====================

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function isWarga(): bool
    {
        return $this->role === 'warga';
    }

    public function isPetugas(): bool
    {
        return $this->role === 'petugas';
    }

    public function isKasi(): bool
    {
        return $this->role === 'kasi';
    }

    public function isCamat(): bool
    {
        return $this->role === 'camat';
    }

    // ===================== RELATIONSHIPS =====================

    public function seksi()
    {
        return $this->belongsTo(Seksi::class, 'seksi_id');
    }

    public function pengajuan()
    {
        return $this->hasMany(Pengajuan::class, 'warga_id');
    }

    public function pengaduan()
    {
        return $this->hasMany(Pengaduan::class, 'warga_id');
    }

    // ===================== ACCESSORS =====================

    public function getFotoUrlAttribute(): ?string
    {
        if ($this->foto) {
            return asset('storage/' . $this->foto);
        }
        return null;
    }
}
