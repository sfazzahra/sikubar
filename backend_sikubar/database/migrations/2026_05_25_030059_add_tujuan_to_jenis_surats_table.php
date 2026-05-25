<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
{
    Schema::table('jenis_surat', function (Blueprint $table) {
        $table->json('tujuan')->nullable()->after('persyaratan');
    });
}

public function down(): void
{
    Schema::table('jenis_surat', function (Blueprint $table) {
        $table->dropColumn('tujuan');
    });
}
};
