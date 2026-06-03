<?php

namespace App\Http\Controllers\Kasi;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ProfileKasiController extends Controller
{
    // FR-19 Lihat Profil
    public function show()
    {
        return response()->json([
            'success' => true,
            'data' => auth()->user()
        ]);
    }

    // FR-19 Update Profil
    public function update(Request $request)
    {
        $request->validate([
            'name'   => 'required|string|max:255',
            'email'  => 'nullable|email',
            'no_hp'  => 'nullable|string|max:20',
            'alamat' => 'nullable|string',
        ]);

        $user = auth()->user();

        $user->update([
            'name'   => $request->name,
            'email'  => $request->email ?? $user->email,
            'no_hp'  => $request->no_hp,
            'alamat' => $request->alamat,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'data'    => $user->fresh()
        ]);
    }

    // Ganti Password
    public function gantiPassword(Request $request)
    {
        $request->validate([
            'password_lama' => 'required',
            'password_baru' => 'required|min:6'
        ]);

        $user = auth()->user();

        if (!Hash::check($request->password_lama, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama salah'
            ], 422);
        }

        $user->update([
            'password' => bcrypt($request->password_baru)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diganti'
        ]);
    }

    // FR-25 Logout
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ]);
    }
}
