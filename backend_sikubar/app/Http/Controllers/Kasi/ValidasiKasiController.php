<?php

namespace App\Http\Controllers\Kasi;

use App\Http\Controllers\Controller;
use App\Models\Pengajuan;
use App\Models\User;
use App\Providers\NotificationService;
use Illuminate\Http\Request;

class ValidasiKasiController extends Controller
{
    // ===================== STATISTIK =====================

    public function statistik()
    {
        $seksiId = auth()->user()->seksi_id;

        // Hanya hitung pengajuan dari seksi kasi yang sedang login
        $base = Pengajuan::whereHas('jenisSurat', fn($q) => $q->where('seksi_id', $seksiId));

        return response()->json([
            'success' => true,
            'data' => [
                'menunggu_review' => (clone $base)->where('status', 'ditandatangani')->count(),
                'disetujui'       => (clone $base)->where('status', 'diverifikasi')->whereNotNull('kasi_id')->count(),
                'ditolak'         => (clone $base)->where('status', 'ditolak')->count(),
                'total'           => (clone $base)->count(),
            ],
        ]);
    }

    // ===================== DAFTAR PENGAJUAN =====================

    public function index(Request $request)
    {
        $seksiId = auth()->user()->seksi_id;

        $query = Pengajuan::with([
            'warga:id,name,nik',
            'jenisSurat:id,nama',
            'berkas:id,pengajuan_id,nama_berkas,file_path',
        ])->whereHas('jenisSurat', fn($q) => $q->where('seksi_id', $seksiId));

        if ($request->filled('status')) {
            $statusMap = [
                'menunggu_kasi'  => 'ditandatangani',
                'disetujui_kasi' => 'diverifikasi',
            ];

            $dbStatus = $statusMap[$request->status] ?? $request->status;
            $query->whereRaw('LOWER(status) = ?', [strtolower($dbStatus)]);

            // Jika filter disetujui_kasi, pastikan memang sudah ada kasi yang approve
            if ($request->status === 'disetujui_kasi') {
                $query->whereNotNull('kasi_id');
            }
        } else {
            // Default: tampilkan semua yang relevan untuk kasi
            $query->where(function ($q) {
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

    // ===================== DETAIL =====================

    public function show($id)
    {
        $seksiId = auth()->user()->seksi_id;

        // Filter by seksi agar semua kasi di seksi bisa melihat detail,
        // bukan hanya kasi yang sudah assign ke pengajuan ini
        $pengajuan = Pengajuan::with(['warga', 'jenisSurat', 'berkas'])
            ->whereHas('jenisSurat', fn($q) => $q->where('seksi_id', $seksiId))
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $this->format($pengajuan, true),
        ]);
    }

    // ===================== SETUJUI =====================

    public function setujui($id)
    {
        $seksiId = auth()->user()->seksi_id;

        $pengajuan = Pengajuan::with(['warga', 'jenisSurat'])
            ->whereHas('jenisSurat', fn($q) => $q->where('seksi_id', $seksiId))
            ->findOrFail($id);

        $status = strtolower(trim($pengajuan->status));

        if ($status !== 'ditandatangani') {
            return response()->json([
                'success' => false,
                'message' => "Pengajuan tidak bisa disetujui (status saat ini: {$status})",
            ], 422);
        }

        $pengajuan->update([
            'status'  => 'diverifikasi',
            'kasi_id' => auth()->id(),
        ]);

        // Notifikasi ke petugas yang menangani pengajuan ini
        if ($pengajuan->petugas_id) {
            NotificationService::pengajuanDisetujuiKasiPetugas(
                $pengajuan->petugas_id,
                $pengajuan->warga->name,
                $pengajuan->jenisSurat->nama,
                $pengajuan->id
            );
        }

        // Notifikasi ke warga
        NotificationService::pengajuanDisetujuiKasiWarga(
            $pengajuan->warga_id,
            $pengajuan->jenisSurat->nama,
            $pengajuan->id
        );

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan berhasil disetujui, petugas dapat membuat surat',
            'data'    => $this->format($pengajuan->fresh()),
        ]);
    }

    // ===================== TOLAK =====================

    public function tolak(Request $request, $id)
    {
        $request->validate([
            'alasan_penolakan' => 'required|string|max:500',
        ]);

        $seksiId = auth()->user()->seksi_id;

        $pengajuan = Pengajuan::with(['warga', 'jenisSurat'])
            ->whereHas('jenisSurat', fn($q) => $q->where('seksi_id', $seksiId))
            ->findOrFail($id);

        $status = strtolower(trim($pengajuan->status));

        if ($status !== 'ditandatangani') {
            return response()->json([
                'success' => false,
                'message' => "Pengajuan tidak bisa ditolak (status saat ini: {$status})",
            ], 422);
        }

        $pengajuan->update([
            'status'           => 'ditolak',
            'kasi_id'          => auth()->id(),
            'alasan_penolakan' => $request->alasan_penolakan,
            'tanggal_selesai'  => now(),
        ]);

        // Notifikasi ke petugas yang menangani pengajuan ini
        if ($pengajuan->petugas_id) {
            NotificationService::pengajuanDitolakKasiPetugas(
                $pengajuan->petugas_id,
                $pengajuan->warga->name,
                $pengajuan->jenisSurat->nama,
                $request->alasan_penolakan,
                $pengajuan->id
            );
        }

        // Notifikasi ke warga
        NotificationService::pengajuanDitolakKasiWarga(
            $pengajuan->warga_id,
            $pengajuan->jenisSurat->nama,
            $request->alasan_penolakan,
            $pengajuan->id
        );

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
            'tanggal_selesai'  => $p->tanggal_selesai?->toISOString(),
            'tanggal_diproses' => $p->tanggal_diproses?->toISOString(),

            'warga' => $p->warga ? [
                'id'   => $p->warga->id,
                'nama' => $p->warga->name,
                'nik'  => $p->warga->nik,
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