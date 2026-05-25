<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    /**
     * FR-33: Lihat profil admin
     */
    public function show(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data'    => $request->user(),
        ]);
    }

    /**
     * FR-33: Update profil admin
     */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name'  => 'sometimes|required|string|max:255',
            'email' => ['sometimes', 'required', 'email',
                        Rule::unique('users', 'email')->ignore($user->id)],
            'no_hp' => 'nullable|string|max:20',
            'alamat'=> 'nullable|string',
        ]);

        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui.',
            'data'    => $user->fresh(),
        ]);
    }

    /**
     * Update foto profil admin
     */
    public function updateFoto(Request $request): JsonResponse
    {
        $request->validate([
            'foto' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ], [
            'foto.image' => 'File harus berupa gambar.',
            'foto.max'   => 'Ukuran foto maksimal 2MB.',
        ]);

        $user = $request->user();

        // Hapus foto lama
        if ($user->foto && Storage::disk('public')->exists($user->foto)) {
            Storage::disk('public')->delete($user->foto);
        }

        $path = $request->file('foto')->store('foto-profil', 'public');
        $user->update(['foto' => $path]);

        return response()->json([
            'success'  => true,
            'message'  => 'Foto profil berhasil diperbarui.',
            'data'     => ['foto_url' => $user->fresh()->foto_url],
        ]);
    }

    /**
     * Ganti kata sandi admin
     */
    public function updatePassword(Request $request): JsonResponse
    {
        $request->validate([
            'password_lama' => 'required|string',
            'password_baru' => 'required|string|min:6|confirmed',
        ], [
            'password_baru.confirmed' => 'Konfirmasi kata sandi tidak cocok.',
            'password_baru.min'       => 'Kata sandi minimal 6 karakter.',
        ]);

        $user = $request->user();

        if (!Hash::check($request->password_lama, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Kata sandi lama tidak sesuai.',
            ], 422);
        }

        $user->update(['password' => Hash::make($request->password_baru)]);
        // Logout semua sesi lain
        $user->tokens()->where('id', '!=', $request->user()->currentAccessToken()->id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil diperbarui.',
        ]);
    }
}
