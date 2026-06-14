<?php

namespace App\Http\Controllers\Camat;

use App\Http\Controllers\Controller;
use App\Models\Pengajuan;
use App\Models\Pengaduan;
use Carbon\Carbon;
use Illuminate\Http\Request;

class CamatController extends Controller
{
    // ─────────────────────────────────────────────────
    //  DASHBOARD STATS
    // ─────────────────────────────────────────────────

    public function dashboard()
    {
        // Statistik pengajuan
        $totalPengajuan   = Pengajuan::count();
        $disetujui        = Pengajuan::whereIn('status', ['disetujui_kasi', 'selesai'])->count();
        $ditolak          = Pengajuan::where('status', 'ditolak')->count();
        $menunggu         = Pengajuan::whereIn('status', ['menunggu', 'diproses', 'diverifikasi', 'menunggu_kasi'])->count();

        // Statistik pengaduan
        $totalPengaduan   = Pengaduan::count();
        $pengaduanDiproses = Pengaduan::where('status', 'diproses')->count();
        $pengaduanSelesai = Pengaduan::where('status', 'selesai')->count();

        // Statistik mingguan (Senin s/d Minggu pekan ini)
        $startOfWeek = Carbon::now()->startOfWeek(Carbon::MONDAY);
        $namaHari    = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

        $statistikMingguan = [];
        for ($i = 0; $i < 7; $i++) {
            $date = $startOfWeek->copy()->addDays($i);
            $statistikMingguan[] = [
                'hari'   => $namaHari[$i],
                'jumlah' => Pengajuan::whereDate('created_at', $date)->count(),
            ];
        }

        return response()->json([
            'status' => 'success',
            'data'   => [
                'total_pengajuan'     => $totalPengajuan,
                'pengajuan_disetujui' => $disetujui,
                'pengajuan_ditolak'   => $ditolak,
                'pengajuan_menunggu'  => $menunggu,
                'total_pengaduan'     => $totalPengaduan,
                'pengaduan_diproses'  => $pengaduanDiproses,
                'pengaduan_selesai'   => $pengaduanSelesai,
                'statistik_mingguan'  => $statistikMingguan,
            ],
        ]);
    }

    // ─────────────────────────────────────────────────
    //  MONITORING PENGAJUAN (read-only)
    // ─────────────────────────────────────────────────

    public function indexPengajuan(Request $request)
    {
        $query = Pengajuan::with([
            'warga:id,name,nik',       // relasi di model: warga()
            'jenisSurat:id,nama',
            'berkas',
        ])->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nomor_pengajuan', 'like', "%$search%")
                  ->orWhereHas('warga', fn($u) => $u->where('name', 'like', "%$search%"));
            });
        }

        $paginated = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'status' => 'success',
            'data'   => $paginated->map(fn($item) => $this->formatPengajuan($item)),
            'meta'   => [
                'current_page' => $paginated->currentPage(),
                'last_page'    => $paginated->lastPage(),
                'total'        => $paginated->total(),
            ],
        ]);
    }

    /**
     * GET /api/camat/pengajuan/{id}
     */
    public function showPengajuan($id)
    {
        $item = Pengajuan::with([
            'warga:id,name,nik',
            'jenisSurat:id,nama',
            'berkas',
        ])->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data'   => $this->formatPengajuan($item, detail: true),
        ]);
    }

    // ─────────────────────────────────────────────────
    //  MONITORING PENGADUAN (read-only)
    // ─────────────────────────────────────────────────

    public function indexPengaduan(Request $request)
    {
        $query = Pengaduan::with([
            'warga:id,name',       // relasi di model: warga()
            'pembalas:id,name',    // relasi di model: pembalas()
        ])->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('judul', 'like', "%$search%")
                  ->orWhere('isi', 'like', "%$search%")
                  ->orWhereHas('warga', fn($u) => $u->where('name', 'like', "%$search%"));
            });
        }

        $paginated = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'status' => 'success',
            'data'   => $paginated->map(fn($item) => $this->formatPengaduan($item)),
            'meta'   => [
                'current_page' => $paginated->currentPage(),
                'last_page'    => $paginated->lastPage(),
                'total'        => $paginated->total(),
            ],
        ]);
    }

    /**
     * GET /api/camat/pengaduan/{id}
     */
    public function showPengaduan($id)
    {
        $item = Pengaduan::with([
            'warga:id,name',
            'pembalas:id,name',
        ])->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data'   => $this->formatPengaduan($item),
        ]);
    }

    // ─────────────────────────────────────────────────
    //  PRIVATE FORMATTERS
    // ─────────────────────────────────────────────────

    private function formatPengajuan(Pengajuan $item, bool $detail = false): array
    {
        $base = [
            'id'               => $item->id,
            'nomor_pengajuan'  => $item->nomor_pengajuan,
            'tujuan'           => $item->tujuan,
            'status'           => $item->status,
            'catatan'          => $item->catatan,
            'alasan_penolakan' => $item->alasan_penolakan,
            'tanggal_diproses' => $item->tanggal_diproses?->format('d M Y'),
            'tanggal_selesai'  => $item->tanggal_selesai?->format('d M Y'),
            'created_at'       => $item->created_at?->format('d M Y'),

            // Warga (relasi warga(), FK: warga_id)
            'user' => [
                'nama' => $item->warga?->name,
                'nik'  => $item->warga?->nik,
            ],

            // Jenis surat
            'jenis_surat' => [
                'nama' => $item->jenisSurat?->nama,
            ],

            // Surat jadi yang diupload petugas (kolom: surat_path)
            'surat_url' => $item->surat_path
                ? asset('storage/' . $item->surat_path)
                : null,
        ];

        // Detail tambahan (hanya untuk showPengajuan)
        if ($detail) {
            $base['berkas'] = $item->berkas->map(fn($b) => [
                'nama_berkas' => $b->nama_berkas ?? $b->nama ?? '-',
                'url'         => $b->file_path
                    ? asset('storage/' . $b->file_path)
                    : null,
            ])->toArray();
        }

        return $base;
    }

    
    private function formatPengaduan(Pengaduan $item): array
    {
        return [
            'id'              => $item->id,

            // Nama warga (via relasi warga())
            'nama'            => $item->warga?->name ?? '-',

            // Judul di model = kategori pengaduan
            'kategori'        => $item->judul,

            'isi'             => $item->isi,
            'status'          => $item->status,

            // Balasan petugas
            'balasan'         => $item->balasan,

            // Nama petugas yang membalas (via relasi pembalas())
            'nama_pembalas'   => $item->pembalas?->name,

            // Tanggal dibalas dari kolom tanggal_dibalas
            'tanggal_balasan' => $item->tanggal_dibalas?->format('d M Y'),

            'tanggal'         => $item->created_at?->format('d M Y'),

            // Bukti — gunakan accessor bukti_url dari model
            'file_bukti'      => $item->bukti_url,
        ];
    }
}