<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade'); // penerima
            $table->string('judul');
            $table->text('pesan');
            $table->enum('tipe', ['pengajuan', 'pengaduan'])->default('pengajuan');
            $table->json('data')->nullable(); // payload tambahan (pengajuan_id, dll)
            $table->timestamp('read_at')->nullable(); // NULL = belum dibaca
            $table->timestamps();

            $table->index(['user_id', 'read_at']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};