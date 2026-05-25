<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('berkas_pengajuan', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('pengajuan_id');
            $table->string('nama_berkas');     // label/nama dokumen (e.g. "KTP", "KK")
            $table->string('file_path');       // path di storage
            $table->string('file_original');   // nama file asli
            $table->string('mime_type')->nullable();
            $table->unsignedBigInteger('file_size')->nullable();
            $table->timestamps();

            $table->foreign('pengajuan_id')->references('id')->on('pengajuan')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('berkas_pengajuan');
    }
};
