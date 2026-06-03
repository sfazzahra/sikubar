<?php

namespace App\Http\Controllers\petugas;

use App\Http\Controllers\Controller;
use App\Models\Pengajuan;
use App\Models\Pengaduan;
use Illuminate\Http\Request;

/**
 * FR-15 : Petugas monitoring laporan pelayanan
 */
class MonitoringPetugasController extends Controller
{
    // GET /api/petugas/monitoring?status=Semua&search=Ahmad
    public function index(Request $request)
    {
        $query = Pengajuan::with([
            'warga:id,name',
            'jenisSurat:id,nama',
        ]);

        if ($request->filled('status') && strtolower($request->status) !== 'semua') {
            $query->where('status', strtolower($request->status));
        }

        if ($request->filled('search')) {
            $query->whereHas('warga', fn($q) =>
                $q->where('name', 'like', '%' . $request->search . '%')
            );
        }

        if ($request->filled('tanggal_mulai')) {
            $query->whereDate('created_at', '>=', $request->tanggal_mulai);
        }

        if ($request->filled('tanggal_akhir')) {
            $query->whereDate('created_at', '<=', $request->tanggal_akhir);
        }

        $paginated = $query->orderByDesc('created_at')->paginate(10);

        return response()->json([
            'success' => true,
            'data'    => $paginated->map(fn($p) => [
                'id'              => $p->id,
                'nama'            => $p->warga?->name,
                'jenis'           => $p->jenisSurat?->nama,
                'status'          => ucfirst($p->status),
                'keterangan'      => $p->catatan ?? '-',
                'tanggal'         => $p->created_at?->format('d M Y'),
                'nomor_pengajuan' => $p->nomor_pengajuan,
            ]),
            'meta' => [
                'current_page' => $paginated->currentPage(),
                'last_page'    => $paginated->lastPage(),
                'total'        => $paginated->total(),
            ],
        ]);
    }

    // GET /api/petugas/monitoring/statistik
    // Untuk widget angka di Beranda (total, diproses, selesai)
    public function statistik()
    {
        $total    = Pengajuan::count();
        $diproses = Pengajuan::whereIn('status', ['diproses', 'diverifikasi', 'diteruskan'])->count();
        $selesai  = Pengajuan::where('status', 'selesai')->count();
        $ditolak  = Pengajuan::where('status', 'ditolak')->count();

        $belumVerifikasi = Pengajuan::where('status', 'diproses')->count();
        $pengaduanBaru   = Pengaduan::where('status', 'menunggu')->count();

        $hariIni             = now()->toDateString();
        $verifikasiHariIni   = Pengajuan::whereDate('tanggal_diproses', $hariIni)->count();
        $pengaduanDitanggapi = Pengaduan::whereDate('tanggal_dibalas', $hariIni)->count();

        return response()->json([
            'success' => true,
            'data'    => [
                'total'    => $total,
                'diproses' => $diproses,
                'selesai'  => $selesai,
                'ditolak'  => $ditolak,
                'perlu_perhatian' => [
                    'belum_verifikasi' => $belumVerifikasi,
                    'pengaduan_baru'   => $pengaduanBaru,
                ],
                'ringkasan_hari_ini' => [
                    'diverifikasi'         => $verifikasiHariIni,
                    'pengaduan_ditanggapi' => $pengaduanDitanggapi,
                ],
            ],
        ]);
    }
}
