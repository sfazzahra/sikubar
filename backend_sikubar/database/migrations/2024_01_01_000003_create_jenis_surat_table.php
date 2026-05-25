<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jenis_surat', function (Blueprint $table) {
            $table->id();
            $table->string('nama');
            $table->string('kode')->unique();
            $table->text('deskripsi')->nullable();
            $table->unsignedTinyInteger('seksi_id'); // seksi yang menangani
            $table->json('persyaratan')->nullable(); // daftar dokumen yang dibutuhkan
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('seksi_id')->references('id')->on('seksi');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jenis_surat');
    }
};
