<?php

namespace App\Http\Controllers\Warga;

use App\Http\Controllers\Controller;
use App\Models\BerkasPengajuan;
use App\Models\JenisSurat;
use App\Models\Pengajuan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class PengajuanController extends Controller
{
    /**
     * FR-07: Riwayat pengajuan warga
     */
    public function index(Request $request): JsonResponse
    {
        $pengajuan = Pengajuan::with(['jenisSurat.seksi', 'berkas'])
            ->where('warga_id', $request->user()->id)
            ->when($request->filled('status'), fn($q) => $q->where('status', $request->status))
            ->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 10));

        return response()->json([
            'success' => true,
            'data'    => $pengajuan,
        ]);
    }

    /**
     * Detail satu pengajuan warga
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $pengajuan = Pengajuan::with(['jenisSurat.seksi', 'berkas', 'petugas', 'kasi'])
            ->where('warga_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $pengajuan,
        ]);
    }

    /**
     * FR-03 + FR-04: Buat pengajuan baru beserta upload berkas
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'jenis_surat_id' => 'required|exists:jenis_surat,id',
            'tujuan'         => 'nullable|string|max:255',   // ← DITAMBAHKAN
            'berkas'         => 'required|array|min:1',
            'berkas.*.nama'  => 'required|string|max:255',
            'berkas.*.file'  => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ], [
            'jenis_surat_id.required' => 'Jenis surat wajib dipilih.',
            'berkas.required'         => 'Berkas persyaratan wajib diunggah.',
            'berkas.*.file.mimes'     => 'Format berkas harus PDF, JPG, atau PNG.',
            'berkas.*.file.max'       => 'Ukuran berkas maksimal 5MB.',
        ]);

        $jenisSurat = JenisSurat::where('is_active', true)->findOrFail($request->jenis_surat_id);

        DB::beginTransaction();
        try {
            $pengajuan = Pengajuan::create([
                'warga_id'       => $request->user()->id,
                'jenis_surat_id' => $jenisSurat->id,
                'tujuan'         => $request->tujuan,   // ← DITAMBAHKAN
                'status'         => 'menunggu',
            ]);

            foreach ($request->berkas as $item) {
                /** @var \Illuminate\Http\UploadedFile $file */
                $file = $item['file'];
                $path = $file->store("berkas/{$pengajuan->id}", 'public');

                BerkasPengajuan::create([
                    'pengajuan_id'  => $pengajuan->id,
                    'nama_berkas'   => $item['nama'],
                    'file_path'     => $path,
                    'file_original' => $file->getClientOriginalName(),
                    'mime_type'     => $file->getMimeType(),
                    'file_size'     => $file->getSize(),
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Pengajuan berhasil dikirim.',
                'data'    => $pengajuan->load(['jenisSurat', 'berkas']),
            ], 201);

        } catch (\Throwable $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat menyimpan pengajuan.',
                'error'   => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * FR-05: Perbarui/ganti berkas persyaratan
     * Hanya bisa jika status masih 'menunggu'
     */
    public function updateBerkas(Request $request, int $pengajuanId): JsonResponse
    {
        $pengajuan = Pengajuan::where('warga_id', $request->user()->id)
                              ->findOrFail($pengajuanId);

        if ($pengajuan->status !== 'menunggu') {
            return response()->json([
                'success' => false,
                'message' => 'Berkas tidak dapat diperbarui karena pengajuan sudah diproses.',
            ], 422);
        }

        $request->validate([
            'berkas'        => 'required|array|min:1',
            'berkas.*.nama' => 'required|string|max:255',
            'berkas.*.file' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ]);

        DB::beginTransaction();
        try {
            foreach ($pengajuan->berkas as $berkas) {
                Storage::disk('public')->delete($berkas->file_path);
            }
            $pengajuan->berkas()->delete();

            foreach ($request->berkas as $item) {
                $file = $item['file'];
                $path = $file->store("berkas/{$pengajuan->id}", 'public');

                BerkasPengajuan::create([
                    'pengajuan_id'  => $pengajuan->id,
                    'nama_berkas'   => $item['nama'],
                    'file_path'     => $path,
                    'file_original' => $file->getClientOriginalName(),
                    'mime_type'     => $file->getMimeType(),
                    'file_size'     => $file->getSize(),
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Berkas berhasil diperbarui.',
                'data'    => $pengajuan->fresh()->load('berkas'),
            ]);

        } catch (\Throwable $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat memperbarui berkas.',
            ], 500);
        }
    }

    /**
     * FR-05: Ganti satu berkas saja (tanpa hapus semua)
     */
    public function replaceBerkas(Request $request, int $pengajuanId, int $berkasId): JsonResponse
    {
        $pengajuan = Pengajuan::where('warga_id', $request->user()->id)
                              ->findOrFail($pengajuanId);

        if ($pengajuan->status !== 'menunggu') {
            return response()->json([
                'success' => false,
                'message' => 'Berkas tidak dapat diperbarui karena pengajuan sudah diproses.',
            ], 422);
        }

        $berkas = BerkasPengajuan::where('pengajuan_id', $pengajuanId)->findOrFail($berkasId);

        $request->validate([
            'file' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ]);

        Storage::disk('public')->delete($berkas->file_path);

        $file = $request->file('file');
        $path = $file->store("berkas/{$pengajuan->id}", 'public');

        $berkas->update([
            'file_path'     => $path,
            'file_original' => $file->getClientOriginalName(),
            'mime_type'     => $file->getMimeType(),
            'file_size'     => $file->getSize(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Berkas berhasil diganti.',
            'data'    => $berkas->fresh(),
        ]);
    }

    /**
     * Daftar jenis surat yang aktif (untuk form pengajuan)
     */
    public function jenisSuratAktif(): JsonResponse
    {
        $jenisSurat = JenisSurat::with('seksi')
            ->where('is_active', true)
            ->orderBy('nama')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $jenisSurat,
        ]);
    }
}