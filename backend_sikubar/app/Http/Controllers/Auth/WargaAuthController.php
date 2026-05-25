<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class WargaAuthController extends Controller
{
    /**
     * FR-01: Login warga menggunakan NIK dan kata sandi
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'nik'      => 'required|string|digits:16',
            'password' => 'required|string|min:6',
        ], [
            'nik.required'      => 'NIK wajib diisi.',
            'nik.digits'        => 'NIK harus 16 digit angka.',
            'password.required' => 'Kata sandi wajib diisi.',
        ]);

        $warga = User::where('nik', $request->nik)
                     ->where('role', 'warga')
                     ->first();

        if (!$warga || !Hash::check($request->password, $warga->password)) {
            throw ValidationException::withMessages([
                'nik' => ['NIK atau kata sandi salah.'],
            ]);
        }

        // Hapus token lama jika ada
        $warga->tokens()->delete();

        $token = $warga->createToken('warga-token', ['role:warga'])->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'data'    => [
                'token' => $token,
                'user'  => [
                    'id'       => $warga->id,
                    'name'     => $warga->name,
                    'nik'      => $warga->nik,
                    'role'     => $warga->role,
                    'no_hp'    => $warga->no_hp,
                    'alamat'   => $warga->alamat,
                    'foto_url' => $warga->foto_url,
                ],
            ],
        ]);
    }

    /**
     * FR-08: Logout warga
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil.',
        ]);
    }

    /**
     * Get authenticated warga info
     */
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data'    => $request->user()->load('seksi'),
        ]);
    }
}
