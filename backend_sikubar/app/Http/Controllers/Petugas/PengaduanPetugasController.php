<?php

namespace App\Http\Controllers\petugas;

use App\Http\Controllers\Controller;
use App\Models\Pengaduan;
use Illuminate\Http\Request;
use App\Providers\NotificationService;

/**
 * FR-14 : Petugas melihat dan menanggapi pengaduan masyarakat
 */
class PengaduanPetugasController extends Controller
{
    // GET /api/petugas/pengaduan?status=diproses
    public function index(Request $request)
    {
        $query = Pengaduan::with([
            'warga:id,name',
            'pembalas:id,name',
        ]);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $data = $query->orderByDesc('created_at')->paginate(10);

        return response()->json([
            'success' => true,
            'data'    => $data->map(fn($p) => $this->format($p)),
            'meta'    => [
                'current_page' => $data->currentPage(),
                'last_page'    => $data->lastPage(),
                'total'        => $data->total(),
            ],
        ]);
    }

    // GET /api/petugas/pengaduan/{id}
    public function show($id)
    {
        $pengaduan = Pengaduan::with(['warga', 'pembalas'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $this->format($pengaduan),
        ]);
    }

    // POST /api/petugas/pengaduan/{id}/tanggapi
    // Body: { balasan: "..." }
    public function tanggapi(Request $request, $id)
    {
        $request->validate([
            'balasan' => 'required|string|min:5|max:1000',
        ]);

        $pengaduan = Pengaduan::findOrFail($id);

        if ($pengaduan->status === 'selesai') {
            return response()->json([
                'success' => false,
                'message' => 'Pengaduan ini sudah selesai ditanggapi',
            ], 422);
        }

        $pengaduan->update([
            'balasan'         => $request->balasan,
            'status'          => 'selesai',
            'dibalas_oleh'    => $request->user()->id,
            'tanggal_dibalas' => now(),
        ]);

        NotificationService::pengaduanDitanggapi(
    $pengaduan->warga_id,
    $pengaduan->judul,
    $pengaduan->id
);

        return response()->json([
            'success' => true,
            'message' => 'Tanggapan berhasil dikirim',
            'data'    => $this->format($pengaduan->fresh(['warga', 'pembalas'])),
        ]);
    }

    private function format(Pengaduan $p): array
    {
        return [
            'id'              => $p->id,
            'judul'           => $p->judul,
            'isi'             => $p->isi,
            'status'          => $p->status,
            'balasan'         => $p->balasan,
            'tanggal'         => $p->created_at?->format('Y-m-d'),
            'tanggal_dibalas' => $p->tanggal_dibalas?->format('d M Y H:i'),
            'nama'            => $p->warga?->name,
            'dibalas_oleh'    => $p->pembalas?->name,
            'bukti_path'      => $p->bukti_path,
        ];
    }
}
