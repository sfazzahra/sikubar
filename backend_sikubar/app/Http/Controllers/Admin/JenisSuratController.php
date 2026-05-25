<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\JenisSurat;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class JenisSuratController extends Controller
{
    /**
     * FR-35: Daftar semua jenis surat
     */
    public function index(Request $request): JsonResponse
    {
        $query = JenisSurat::with('seksi');

        if ($request->filled('is_active')) {
            $query->where('is_active', filter_var($request->is_active, FILTER_VALIDATE_BOOLEAN));
        }

        if ($request->filled('seksi_id')) {
            $query->where('seksi_id', $request->seksi_id);
        }

        if ($request->filled('search')) {
            $query->where('nama', 'like', '%' . $request->search . '%');
        }

        $jenisSurat = $query->orderBy('nama')->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data'    => $jenisSurat,
        ]);
    }

    /**
     * FR-35: Buat jenis surat baru
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nama'          => 'required|string|max:255',
            'kode'          => 'required|string|max:50|unique:jenis_surat,kode',
            'deskripsi'     => 'nullable|string',
            'seksi_id'      => 'required|exists:seksi,id',
            'persyaratan'   => 'nullable|array',
            'persyaratan.*' => 'string|max:255',
            'tujuan'        => 'nullable|array',   // ← sudah ada, tidak perlu ubah
            'tujuan.*'      => 'string|max:255',
            'is_active'     => 'boolean',
        ], [
            'kode.unique'       => 'Kode surat sudah digunakan.',
            'seksi_id.required' => 'Seksi penanganan wajib dipilih.',
        ]);

        $jenisSurat = JenisSurat::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Jenis surat berhasil dibuat.',
            'data'    => $jenisSurat->load('seksi'),
        ], 201);
    }

    /**
     * Detail jenis surat
     */
    public function show(int $id): JsonResponse
    {
        $jenisSurat = JenisSurat::with('seksi')->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $jenisSurat,
        ]);
    }

    /**
     * FR-35: Update jenis surat
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $jenisSurat = JenisSurat::findOrFail($id);

        $validated = $request->validate([
            'nama'          => 'sometimes|required|string|max:255',
            'kode'          => ['sometimes', 'required', 'string', 'max:50',
                                Rule::unique('jenis_surat', 'kode')->ignore($jenisSurat->id)],
            'deskripsi'     => 'nullable|string',
            'seksi_id'      => 'sometimes|required|exists:seksi,id',
            'persyaratan'   => 'nullable|array',
            'persyaratan.*' => 'string|max:255',
            'tujuan'        => 'nullable|array',   // ← DITAMBAHKAN
            'tujuan.*'      => 'string|max:255',   // ← DITAMBAHKAN
            'is_active'     => 'boolean',
        ]);

        $jenisSurat->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Jenis surat berhasil diperbarui.',
            'data'    => $jenisSurat->fresh()->load('seksi'),
        ]);
    }

    /**
     * FR-35: Hapus jenis surat
     */
    public function destroy(int $id): JsonResponse
    {
        $jenisSurat = JenisSurat::findOrFail($id);

        $pengajuanAktif = $jenisSurat->pengajuan()
            ->whereNotIn('status', ['selesai', 'ditolak'])
            ->count();

        if ($pengajuanAktif > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Jenis surat tidak dapat dihapus karena masih ada pengajuan yang sedang diproses.',
            ], 422);
        }

        $jenisSurat->delete();

        return response()->json([
            'success' => true,
            'message' => 'Jenis surat berhasil dihapus.',
        ]);
    }

    /**
     * Toggle aktif/nonaktif
     */
    public function toggleActive(int $id): JsonResponse
    {
        $jenisSurat = JenisSurat::findOrFail($id);
        $jenisSurat->update(['is_active' => !$jenisSurat->is_active]);

        return response()->json([
            'success' => true,
            'message' => 'Status jenis surat berhasil diubah.',
            'data'    => ['is_active' => $jenisSurat->is_active],
        ]);
    }
}