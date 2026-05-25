<?php

namespace App\Http\Controllers\Warga;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    /**
     * FR-02: Lihat profil warga
     */
    public function show(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data'    => $request->user(),
        ]);
    }

    /**
     * FR-02: Update profil warga
     */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name'  => 'sometimes|required|string|max:255',
            'nik'   => ['sometimes', 'required', 'digits:16',
                        Rule::unique('users', 'nik')->ignore($user->id)],
            'no_hp' => 'nullable|string|max:20',
            'alamat'=> 'nullable|string',
        ], [
            'nik.digits' => 'NIK harus 16 digit angka.',
            'nik.unique' => 'NIK sudah digunakan akun lain.',
        ]);

        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui.',
            'data'    => $user->fresh(),
        ]);
    }

    /**
     * Update foto profil warga
     */
    public function updateFoto(Request $request): JsonResponse
    {
        $request->validate([
            'foto' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $user = $request->user();

        if ($user->foto && Storage::disk('public')->exists($user->foto)) {
            Storage::disk('public')->delete($user->foto);
        }

        $path = $request->file('foto')->store('foto-profil', 'public');
        $user->update(['foto' => $path]);

        return response()->json([
            'success' => true,
            'message' => 'Foto profil berhasil diperbarui.',
            'data'    => ['foto_url' => $user->fresh()->foto_url],
        ]);
    }

    /**
     * Ganti kata sandi warga
     */
    public function updatePassword(Request $request): JsonResponse
    {
        $request->validate([
            'password_lama' => 'required|string',
            'password_baru' => 'required|string|min:6|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->password_lama, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Kata sandi lama tidak sesuai.',
            ], 422);
        }

        $user->update(['password' => Hash::make($request->password_baru)]);
        $user->tokens()->where('id', '!=', $request->user()->currentAccessToken()->id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil diperbarui.',
        ]);
    }
}
