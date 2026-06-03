<?php

namespace App\Http\Controllers\petugas;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

/**
 * FR-10 : Petugas mengelola profil pribadi
 * FR-17 : Petugas logout
 */
class ProfilePetugasController extends Controller
{
    // GET /api/petugas/profile
    public function show(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data'    => [
                'id'     => $user->id,
                'name'   => $user->name,
                'email'  => $user->email,
                'no_hp'  => $user->no_hp,
                'alamat' => $user->alamat,
                'role'   => $user->role,
                'foto'   => $user->foto ? asset('storage/' . $user->foto) : null,
            ],
        ]);
    }

    // PUT /api/petugas/profile
    public function update(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name'   => 'sometimes|string|max:100',
            'no_hp'  => 'sometimes|string|max:20',
            'alamat' => 'sometimes|string|max:255',
            'foto'   => 'sometimes|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        if ($request->hasFile('foto')) {
            if ($user->foto) {
                Storage::disk('public')->delete($user->foto);
            }
            $validated['foto'] = $request->file('foto')->store('foto_profil', 'public');
        }

        $user->update($validated);
        $user->refresh();

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'data'    => [
                'id'     => $user->id,
                'name'   => $user->name,
                'email'  => $user->email,
                'no_hp'  => $user->no_hp,
                'alamat' => $user->alamat,
                'role'   => $user->role,
                'foto'   => $user->foto ? asset('storage/' . $user->foto) : null,
            ],
        ]);
    }

    // PUT /api/petugas/profile/password
    public function gantiPassword(Request $request)
    {
        $request->validate([
            'password_lama'              => 'required|string',
            'password_baru'              => 'required|string|min:8',
            'password_baru_confirmation' => 'required|string|same:password_baru',
        ]);

        $user = $request->user();

        if (!Hash::check($request->password_lama, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama tidak sesuai',
            ], 422);
        }

        $user->update(['password' => Hash::make($request->password_baru)]);
        $user->tokens()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diubah. Silakan login kembali.',
        ]);
    }

    // POST /api/petugas/logout  (FR-17)
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ]);
    }
}
