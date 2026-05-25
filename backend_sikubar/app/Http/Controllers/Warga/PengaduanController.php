<?php

namespace App\Http\Controllers\Warga;

use App\Http\Controllers\Controller;
use App\Models\Pengaduan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PengaduanController extends Controller
{
    /**
     * FR-06: Kirim pengaduan
     * Menerima: judul (dari dropdown kategori), isi, dan bukti (file opsional)
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'judul' => 'required|string|max:255',
            'isi'   => 'required|string|min:10',
            'bukti' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120',
        ], [
            'judul.required' => 'Kategori pengaduan wajib dipilih.',
            'isi.required'   => 'Isi pengaduan wajib diisi.',
            'isi.min'        => 'Isi pengaduan minimal 10 karakter.',
            'bukti.mimes'    => 'File bukti harus berupa JPG, PNG, atau PDF.',
            'bukti.max'      => 'Ukuran file bukti maksimal 5MB.',
        ]);

        $buktiPath     = null;
        $buktiOriginal = null;

        // Upload file bukti jika ada
        if ($request->hasFile('bukti')) {
            $file          = $request->file('bukti');
            $buktiPath     = $file->store('bukti-pengaduan/' . $request->user()->id, 'public');
            $buktiOriginal = $file->getClientOriginalName();
        }

        $pengaduan = Pengaduan::create([
            'warga_id'       => $request->user()->id,
            'judul'          => $validated['judul'],
            'isi'            => $validated['isi'],
            'status'         => 'menunggu',
            'bukti_path'     => $buktiPath,
            'bukti_original' => $buktiOriginal,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengaduan berhasil dikirim. Kami akan segera menindaklanjuti.',
            'data'    => $pengaduan,
        ], 201);
    }

    /**
     * Riwayat pengaduan warga (dengan URL bukti)
     */
    public function index(Request $request): JsonResponse
    {
        $pengaduan = Pengaduan::where('warga_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 10));

        // Tambahkan URL bukti di setiap item
        $pengaduan->getCollection()->transform(function ($item) {
            $item->bukti_url = $item->bukti_path
                ? asset('storage/' . $item->bukti_path)
                : null;
            return $item;
        });

        return response()->json([
            'success' => true,
            'data'    => $pengaduan,
        ]);
    }

    /**
     * Detail satu pengaduan
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $pengaduan = Pengaduan::where('warga_id', $request->user()->id)
            ->with('pembalas')
            ->findOrFail($id);

        $pengaduan->bukti_url = $pengaduan->bukti_path
            ? asset('storage/' . $pengaduan->bukti_path)
            : null;

        return response()->json([
            'success' => true,
            'data'    => $pengaduan,
        ]);
    }
}