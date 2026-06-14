<?php

namespace App\Http\Controllers\Petugas;

use App\Http\Controllers\Controller;
use App\Models\Pengajuan;
use App\Models\User;
use App\Providers\NotificationService;
use Illuminate\Http\Request;

class VerifikasiPetugasController extends Controller
{
    // ===================== LIST =====================

    public function index(Request $request)
    {
        $seksiId = auth()->user()->seksi_id;

        $query = Pengajuan::with([
            'warga:id,name,email',
            'jenisSurat:id,nama',
            'berkas:id,pengajuan_id,nama_berkas,file_path,file_original',
        ])->whereHas('jenisSurat', fn($q) => $q->where('seksi_id', $seksiId));

        if ($request->filled('status')) {
            $flutterStatus = strtolower(trim($request->status));

            switch ($flutterStatus) {
                // Sudah diverifikasi petugas, belum ada kasi yang approve
                case 'diverifikasi':
                    $query->where('status', 'diverifikasi')
                          ->whereNull('kasi_id');
                    break;

                // Sudah diteruskan ke kasi, menunggu keputusan kasi
                case 'menunggu_kasi':
                    $query->where('status', 'ditandatangani');
                    break;

                // Sudah disetujui kasi
                case 'disetujui_kasi':
                    $query->where('status', 'diverifikasi')
                          ->whereNotNull('kasi_id');
                    break;

                default:
                    $query->whereRaw('LOWER(status) = ?', [$flutterStatus]);
                    break;
            }
        }

        if ($request->filled('search')) {
            $query->whereHas('warga', fn($q) => $q->where('name', 'like', '%' . $request->search . '%'));
        }

        $data = $query->orderByDesc('created_at')->paginate(10);

        return response()->json([
            'success' => true,
            'data'    => $data->getCollection()->map(fn($p) => $this->format($p)),
            'meta'    => [
                'current_page' => $data->currentPage(),
                'last_page'    => $data->lastPage(),
                'total'        => $data->total(),
            ],
        ]);
    }

    // ===================== DETAIL =====================

    public function show($id)
    {
        $seksiId = auth()->user()->seksi_id;

        // Filter by seksi agar semua petugas di seksi bisa melihat detail,
        // bukan hanya petugas yang pertama mengambil pengajuan
        $pengajuan = Pengajuan::with([
            'warga:id,name,email,no_hp',
            'jenisSurat',
            'berkas',
        ])->whereHas('jenisSurat', fn($q) => $q->where('seksi_id', $seksiId))
          ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $this->format($pengajuan, true),
        ]);
    }

    // ===================== VERIFIKASI =====================

    public function verifikasi(Request $request, $id)
    {
        $request->validate([
            'action'  => 'required|in:verifikasi,tolak',
            'catatan' => 'nullable|string|max:500',
        ]);

        $seksiId = auth()->user()->seksi_id;

        $pengajuan = Pengajuan::with(['warga', 'jenisSurat'])
            ->whereHas('jenisSurat', fn($q) => $q->where('seksi_id', $seksiId))
            ->findOrFail($id);

        $status = strtolower(trim($pengajuan->status));

        if (!in_array($status, ['menunggu', 'diproses'])) {
            return response()->json([
                'success' => false,
                'message' => "Pengajuan tidak bisa diproses (status saat ini: {$status})",
            ], 422);
        }

        // Tandai petugas yang mengambil alih pengajuan ini
        if ($status === 'menunggu') {
            $pengajuan->update([
                'status'           => 'diproses',
                'petugas_id'       => auth()->id(),
                'tanggal_diproses' => now(),
            ]);
        }

        if ($request->action === 'verifikasi') {
            $pengajuan->update([
                'status'          => 'diverifikasi',
                'catatan'         => $request->catatan,
                'petugas_id'      => auth()->id(),
                'tanggal_selesai' => now(),
            ]);

            NotificationService::pengajuanDiproses(
                $pengajuan->warga_id,
                $pengajuan->jenisSurat->nama,
                $pengajuan->id
            );

            $message = 'Berkas berhasil diverifikasi';
        } else {
            $pengajuan->update([
                'status'           => 'ditolak',
                'alasan_penolakan' => $request->catatan,
                'petugas_id'       => auth()->id(),
            ]);

            NotificationService::pengajuanDitolakPetugas(
                $pengajuan->warga_id,
                $pengajuan->jenisSurat->nama,
                $request->catatan ?? '-',
                $pengajuan->id
            );

            $message = 'Berkas ditolak';
        }

        return response()->json([
            'success' => true,
            'message' => $message,
            'data'    => $this->format($pengajuan->fresh()),
        ]);
    }

    // ===================== TERUSKAN KE KASI =====================

    public function teruskan(Request $request, $id)
    {
        $request->validate([
            'catatan' => 'nullable|string|max:500',
        ]);

        $seksiId = auth()->user()->seksi_id;

        $pengajuan = Pengajuan::with(['warga', 'jenisSurat'])
            ->whereHas('jenisSurat', fn($q) => $q->where('seksi_id', $seksiId))
            ->findOrFail($id);

        $status = strtolower(trim($pengajuan->status));

        if ($status !== 'diverifikasi') {
            return response()->json([
                'success' => false,
                'message' => "Hanya pengajuan yang sudah diverifikasi yang bisa diteruskan (status saat ini: {$status})",
            ], 422);
        }

        $pengajuan->update([
            'status'  => 'ditandatangani',
            'catatan' => $request->catatan ?? $pengajuan->catatan,
        ]);

        // Kirim notifikasi ke SEMUA kasi di seksi yang sesuai
        $kasiIds = User::where('role', 'kasi')
            ->where('seksi_id', $seksiId)
            ->pluck('id');

        foreach ($kasiIds as $kasiId) {
            NotificationService::pengajuanDiteruskanKeKasi(
                $kasiId,
                $pengajuan->warga->name,
                $pengajuan->jenisSurat->nama,
                $pengajuan->id
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan berhasil diteruskan ke Kasi',
            'data'    => $this->format($pengajuan->fresh()),
        ]);
    }

    // ===================== UPLOAD SURAT =====================

    public function uploadSurat(Request $request, $id)
    {
        $request->validate([
            'surat' => 'required|file|mimes:pdf|max:5120',
        ]);

        $seksiId = auth()->user()->seksi_id;

        $pengajuan = Pengajuan::with(['warga', 'jenisSurat'])
            ->whereHas('jenisSurat', fn($q) => $q->where('seksi_id', $seksiId))
            ->findOrFail($id);

        $path = $request->file('surat')->store('surat', 'public');

        $pengajuan->update([
            'surat_path'      => $path,
            'status'          => 'selesai',
            'tanggal_selesai' => now(),
        ]);

        // Notifikasi ke semua kasi di seksi — surat yang mereka setujui sudah selesai dibuat
        $kasiIds = User::where('role', 'kasi')
            ->where('seksi_id', $seksiId)
            ->pluck('id');

        foreach ($kasiIds as $kasiId) {
            NotificationService::suratSelesaiDiupload(
                null,
                $kasiId,
                $pengajuan->warga_id,
                $pengajuan->warga->name,
                $pengajuan->jenisSurat->nama,
                $pengajuan->id
            );
        }

        // Notifikasi ke semua camat
        $camatIds = User::where('role', 'camat')->pluck('id');
        foreach ($camatIds as $camatId) {
            NotificationService::suratSelesaiDiupload(
                null,
                $camatId,
                $pengajuan->warga_id,
                $pengajuan->warga->name,
                $pengajuan->jenisSurat->nama,
                $pengajuan->id
            );
        }

        // Notifikasi ke warga bahwa suratnya sudah selesai
        NotificationService::suratSelesaiUntukWarga(
            $pengajuan->warga_id,
            $pengajuan->jenisSurat->nama,
            $pengajuan->id
        );

        return response()->json([
            'success' => true,
            'message' => 'Surat berhasil diupload',
            'data'    => $this->format($pengajuan->fresh()),
        ]);
    }

    // ===================== FORMAT RESPONSE =====================

    private function format(Pengajuan $p, bool $detail = false): array
    {
        $rawStatus = strtolower($p->status);

        if ($rawStatus === 'ditandatangani') {
            $flutterStatus = 'menunggu_kasi';
        } elseif ($rawStatus === 'diverifikasi' && $p->kasi_id !== null) {
            $flutterStatus = 'disetujui_kasi';
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
            'tanggal_diproses' => $p->tanggal_diproses?->format('d M Y H:i'),
            'tanggal_selesai'  => $p->tanggal_selesai?->toISOString(),

            'user' => $p->warga ? [
                'id'   => $p->warga->id,
                'nama' => $p->warga->name,
            ] : null,

            'jenis_surat' => $p->jenisSurat ? [
                'id'   => $p->jenisSurat->id,
                'nama' => $p->jenisSurat->nama,
            ] : null,

            'berkas' => $p->berkas?->map(fn($b) => [
                'id'            => $b->id,
                'nama_berkas'   => $b->nama_berkas,
                'url'           => asset('storage/' . $b->file_path),
                'file_original' => $b->file_original,
            ]),
        ];

        if ($detail && $p->warga) {
            $data['user']['email'] = $p->warga->email;
            $data['user']['no_hp'] = $p->warga->no_hp;
        }

        return $data;
    }
}