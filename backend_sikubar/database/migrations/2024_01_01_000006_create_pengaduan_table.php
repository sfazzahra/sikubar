<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengaduan', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('warga_id');
            $table->string('judul');
            $table->text('isi');
            $table->enum('status', ['menunggu', 'diproses', 'selesai'])->default('menunggu');
            $table->text('balasan')->nullable();
            $table->unsignedBigInteger('dibalas_oleh')->nullable();
            $table->timestamp('tanggal_dibalas')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('warga_id')->references('id')->on('users');
            $table->foreign('dibalas_oleh')->references('id')->on('users');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengaduan');
    }
};
