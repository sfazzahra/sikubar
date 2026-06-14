<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * GET /api/notifikasi
     * Ambil semua notifikasi milik user yang sedang login.
     */
    public function index(): JsonResponse
    {
        $notifikasi = Notification::forUser(Auth::id())
            ->orderByRaw('read_at IS NOT NULL') // unread dulu
            ->orderByDesc('created_at')
            ->get()
            ->map(fn($n) => [
                'id'           => $n->id,
                'judul'        => $n->judul,
                'pesan'        => $n->pesan,
                'tipe'         => $n->tipe,
                'data'         => $n->data,
                'is_read'      => $n->is_read,
                'sudah_dibaca' => $n->is_read,
                'read_at'      => $n->read_at?->toISOString(),
                'created_at'   => $n->created_at->toISOString(),
                'tanggal'      => $n->created_at->toISOString(),
            ]);

        return response()->json([
            'success' => true,
            'data'    => $notifikasi,
        ]);
    }

    /**
     * GET /api/notifikasi/unread-count
     * Jumlah notifikasi belum dibaca (untuk badge ringan).
     */
    public function unreadCount(): JsonResponse
    {
        $count = Notification::forUser(Auth::id())
            ->unread()
            ->count();

        return response()->json([
            'success'      => true,
            'unread_count' => $count,
        ]);
    }

    /**
     * PUT /api/notifikasi/{id}/read
     * Tandai satu notifikasi sebagai sudah dibaca.
     */
    public function markAsRead(int $id): JsonResponse
    {
        $notif = Notification::forUser(Auth::id())->findOrFail($id);
        $notif->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi ditandai sudah dibaca.',
        ]);
    }

    /**
     * PUT /api/notifikasi/read-all
     * Tandai semua notifikasi sebagai sudah dibaca.
     */
    public function markAllAsRead(): JsonResponse
    {
        Notification::forUser(Auth::id())
            ->unread()
            ->update(['read_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'Semua notifikasi ditandai sudah dibaca.',
        ]);
    }
}