<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Seksi extends Model
{
    protected $table = 'seksi';

    protected $fillable = ['nama', 'kode'];

    public function users()
    {
        return $this->hasMany(User::class, 'seksi_id');
    }

    public function jenisSurat()
    {
        return $this->hasMany(JenisSurat::class, 'seksi_id');
    }
}
