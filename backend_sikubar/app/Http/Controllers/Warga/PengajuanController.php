<?php

namespace App\Http\Controllers\Warga;

use App\Http\Controllers\Controller;
use App\Models\BerkasPengajuan;
use App\Models\JenisSurat;
use App\Models\Pengajuan;
use App\Models\User;
use App\Providers\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class PengajuanController extends Controller
{
    // ── INDEX ─────────────────────────────────────────────────────────────

    public function index(Request $request): JsonResponse
    {
        $pengajuan = Pengajuan::with(['jenisSurat.seksi', 'berkas'])
            ->where('warga_id', $request->user()->id)
            ->when($request->filled('status'), fn($q) => $q->where('status', $request->status))
            ->orderByDesc('created_at')
            ->paginate($request->get('per_page', 10));

        return response()->json([
            'success' => true,
            'data'    => $pengajuan,
        ]);
    }

    // ── SHOW ──────────────────────────────────────────────────────────────

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

    // ── SHOW BERKAS ───────────────────────────────────────────────────────

    public function showBerkas(Request $request, int $pengajuanId, int $berkasId): JsonResponse
    {
        $pengajuan = Pengajuan::where('warga_id', $request->user()->id)
            ->findOrFail($pengajuanId);

        $berkas = BerkasPengajuan::where('pengajuan_id', $pengajuan->id)
            ->findOrFail($berkasId);

        return response()->json([
            'success' => true,
            'data'    => [
                'id'            => $berkas->id,
                'nama_berkas'   => $berkas->nama_berkas,
                'nama_bersih'   => $berkas->nama_bersih,
                'file_original' => $berkas->file_original,
                'mime_type'     => $berkas->mime_type,
                'file_size'     => $berkas->file_size,
                'file_url'      => $berkas->file_url,
                'is_pendukung'  => $berkas->is_pendukung,
            ],
        ]);
    }

    // ── STORE ─────────────────────────────────────────────────────────────

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'jenis_surat_id' => 'required|exists:jenis_surat,id',
            'tujuan'         => 'nullable|string|max:255',
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
        $seksiId    = $jenisSurat->seksi_id;

        DB::beginTransaction();
        try {
            $pengajuan = Pengajuan::create([
                'warga_id'       => $request->user()->id,
                'jenis_surat_id' => $jenisSurat->id,
                'tujuan'         => $request->tujuan,
                'status'         => 'menunggu',
            ]);

            foreach ($request->berkas as $item) {
                /** @var \Illuminate\Http\UploadedFile $file */
                $file = $item['file'];
                $path = $this->simpanFile($file, $item['nama'], $pengajuan->id);

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

            // Kirim notifikasi ke SEMUA petugas di seksi yang sesuai
            $petugasIds = User::where('role', 'petugas')
                ->where('seksi_id', $seksiId)
                ->pluck('id');

            foreach ($petugasIds as $petugasId) {
                NotificationService::pengajuanBaru(
                    petugasId: $petugasId,
                    namawarga: $request->user()->name,
                    jenisSurat: $pengajuan->jenisSurat->nama,
                    pengajuanId: $pengajuan->id,
                );
            }

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

    // ── UPDATE BERKAS (ganti semua) ───────────────────────────────────────

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
            // Hapus semua berkas lama dari storage
            foreach ($pengajuan->berkas as $berkas) {
                Storage::disk('public')->delete($berkas->file_path);
            }
            $pengajuan->berkas()->delete();

            // Simpan berkas baru
            foreach ($request->berkas as $item) {
                $file = $item['file'];
                $path = $this->simpanFile($file, $item['nama'], $pengajuan->id);

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
                'error'   => $e->getMessage(),
            ], 500);
        }
    }

    // ── REPLACE BERKAS (ganti satu) ───────────────────────────────────────

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

        $berkas = BerkasPengajuan::where('pengajuan_id', $pengajuanId)
            ->findOrFail($berkasId);

        $request->validate([
            'file' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ]);

        $file = $request->file('file');

        Storage::disk('public')->delete($berkas->file_path);
        $path = $this->simpanFile($file, $berkas->nama_berkas, $pengajuanId);

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

    // ── JENIS SURAT AKTIF ─────────────────────────────────────────────────

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

    // ── PRIVATE HELPERS ───────────────────────────────────────────────────

    /**
     * Generate nama file unik dan simpan ke storage public.
     */
    private function simpanFile(
        \Illuminate\Http\UploadedFile $file,
        string $namaBerkas,
        int $pengajuanId
    ): string {
        $namaFile = Str::slug($namaBerkas)
            . '_'
            . time()
            . '.'
            . $file->getClientOriginalExtension();

        return $file->storeAs("berkas/{$pengajuanId}", $namaFile, 'public');
    }
}