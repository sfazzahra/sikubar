<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengajuan', function (Blueprint $table) {
            $table->id();
            $table->string('nomor_pengajuan')->unique(); // nomor unik otomatis
            $table->unsignedBigInteger('warga_id');
            $table->unsignedBigInteger('jenis_surat_id');
            $table->enum('status', [
                'menunggu',      // baru diajukan
                'diproses',      // sedang diproses petugas
                'diverifikasi',  // sudah diverif kasi
                'ditandatangani',// sudah ditandatangani camat
                'selesai',       // selesai
                'ditolak'        // ditolak
            ])->default('menunggu');
            $table->text('catatan')->nullable();        // catatan dari petugas/kasi
            $table->text('alasan_penolakan')->nullable();
            $table->unsignedBigInteger('petugas_id')->nullable();
            $table->unsignedBigInteger('kasi_id')->nullable();
            $table->unsignedBigInteger('camat_id')->nullable();
            $table->timestamp('tanggal_diproses')->nullable();
            $table->timestamp('tanggal_selesai')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('warga_id')->references('id')->on('users');
            $table->foreign('jenis_surat_id')->references('id')->on('jenis_surat');
            $table->foreign('petugas_id')->references('id')->on('users');
            $table->foreign('kasi_id')->references('id')->on('users');
            $table->foreign('camat_id')->references('id')->on('users');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengajuan');
    }
};
