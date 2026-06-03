<?php

namespace App\Http\Controllers\Kasi;

use App\Http\Controllers\Controller;
use App\Models\Pengajuan;
use Illuminate\Http\Request;

class ValidasiKasiController extends Controller
{
    // ===================== STATISTIK =====================
    public function statistik()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'menunggu_review' => Pengajuan::where('status', 'ditandatangani')->count(),
                'disetujui'       => Pengajuan::whereNotNull('kasi_id')->where('status', 'diverifikasi')->count(),
                'ditolak'         => Pengajuan::where('status', 'ditolak')->count(),
                'total'           => Pengajuan::count(),
            ],
        ]);
    }

    // ===================== FR-20: DAFTAR PENGAJUAN =====================
    public function index(Request $request)
    {
        $query = Pengajuan::with([
            'warga:id,name,nik',
            'jenisSurat:id,nama',
            'berkas:id,pengajuan_id,nama_berkas,file_path',
        ]);

        if ($request->filled('status')) {
            $statusMap = [
                'menunggu_kasi'  => 'ditandatangani',
                'disetujui_kasi' => 'diverifikasi',
            ];
            $dbStatus = $statusMap[$request->status] ?? $request->status;
            $query->whereRaw('LOWER(status) = ?', [strtolower($dbStatus)]);
        } else {
            $query->whereIn('status', ['ditandatangani', 'diverifikasi', 'ditolak', 'selesai'])
                  ->where(function ($q) {
                      $q->where('status', 'ditandatangani')
                        ->orWhere('status', 'ditolak')
                        ->orWhere('status', 'selesai')
                        ->orWhere(function ($q2) {
                            $q2->where('status', 'diverifikasi')
                               ->whereNotNull('kasi_id');
                        });
                  });
        }

        $data = $query->orderByDesc('created_at')->get();

        return response()->json([
            'success' => true,
            'data'    => $data->map(fn($p) => $this->format($p)),
        ]);
    }

    // ===================== FR-21: DETAIL =====================
    public function show($id)
    {
        $pengajuan = Pengajuan::with([
            'warga',
            'jenisSurat',
            'berkas',
        ])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $this->format($pengajuan, true),
        ]);
    }

    // ===================== FR-22: SETUJUI =====================
    public function setujui($id)
    {
        $pengajuan = Pengajuan::findOrFail($id);
        $status = strtolower(trim($pengajuan->status));

        if ($status !== 'ditandatangani') {
            return response()->json([
                'success' => false,
                'message' => "Pengajuan tidak bisa disetujui (status saat ini: $status)",
            ], 422);
        }

        $pengajuan->update([
            'status'  => 'diverifikasi',
            'kasi_id' => auth()->id(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan berhasil disetujui, petugas dapat membuat surat',
            'data'    => $this->format($pengajuan->fresh()),
        ]);
    }

    // ===================== FR-23: TOLAK =====================
    public function tolak(Request $request, $id)
    {
        $request->validate([
            'alasan_penolakan' => 'required|string|max:500',
        ]);

        $pengajuan = Pengajuan::findOrFail($id);
        $status = strtolower(trim($pengajuan->status));

        if ($status !== 'ditandatangani') {
            return response()->json([
                'success' => false,
                'message' => "Pengajuan tidak bisa ditolak (status saat ini: $status)",
            ], 422);
        }

        $pengajuan->update([
            'status'           => 'ditolak',
            'kasi_id'          => auth()->id(),
            'alasan_penolakan' => $request->alasan_penolakan,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan berhasil ditolak',
            'data'    => $this->format($pengajuan->fresh()),
        ]);
    }

    // ===================== FORMAT RESPONSE =====================
    private function format(Pengajuan $p, bool $detail = false): array
    {
        $rawStatus = strtolower($p->status);

        if ($rawStatus === 'diverifikasi' && $p->kasi_id !== null) {
            $flutterStatus = 'disetujui_kasi';
        } elseif ($rawStatus === 'ditandatangani') {
            $flutterStatus = 'menunggu_kasi';
        } else {
            $flutterStatus = $rawStatus;
        }

        $data = [
            'id'               => $p->id,
            'nomor_pengajuan'  => $p->nomor_pengajuan,
            'status'           => $flutterStatus,
            'surat_path'       => $p->surat_path ? asset('storage/' . $p->surat_path) : null,
            'tujuan'           => $p->tujuan,
            'catatan'          => $p->catatan,
            'alasan_penolakan' => $p->alasan_penolakan,
            'tanggal'          => $p->created_at?->format('d M Y'),

            'warga' => $p->warga ? [
                'id'   => $p->warga->id,
                'nama' => $p->warga->name,
                'nik'  => $p->warga->nik ?? null,
            ] : null,

            'jenis_surat' => $p->jenisSurat ? [
                'id'   => $p->jenisSurat->id,
                'nama' => $p->jenisSurat->nama,
            ] : null,

            'berkas' => $p->berkas?->map(fn($b) => [
                'id'          => $b->id,
                'nama_berkas' => $b->nama_berkas,
                'url'         => asset('storage/' . $b->file_path),
            ]),
        ];

        if ($detail && $p->warga) {
            $data['warga']['email'] = $p->warga->email ?? null;
            $data['warga']['no_hp'] = $p->warga->no_hp ?? null;
        }

        return $data;
    }
}
