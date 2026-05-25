<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pengaduan', function (Blueprint $table) {
            // Kolom path file bukti (opsional)
            $table->string('bukti_path')->nullable()->after('isi');
            $table->string('bukti_original')->nullable()->after('bukti_path'); // nama file asli
        });
    }

    public function down(): void
    {
        Schema::table('pengaduan', function (Blueprint $table) {
            $table->dropColumn(['bukti_path', 'bukti_original']);
        });
    }
};