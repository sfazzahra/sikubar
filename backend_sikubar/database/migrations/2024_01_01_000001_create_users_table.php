<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('nik', 16)->unique()->nullable(); // khusus warga
            $table->string('email')->unique()->nullable();   // selain warga
            $table->string('password');
            $table->enum('role', ['admin', 'warga', 'petugas', 'kasi', 'camat'])->default('warga');
            $table->unsignedTinyInteger('seksi_id')->nullable(); // untuk petugas & kasi
            $table->string('no_hp', 20)->nullable();
            $table->string('alamat')->nullable();
            $table->string('foto')->nullable();
            $table->timestamp('email_verified_at')->nullable();
            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
