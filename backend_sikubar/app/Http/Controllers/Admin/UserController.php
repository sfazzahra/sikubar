<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * FR-34: Admin membuat akun pengguna (semua role)
     */
    public function store(Request $request): JsonResponse
    {
        $rules = [
            'name'     => 'required|string|max:255',
            'role'     => 'required|in:admin,warga,petugas,kasi,camat',
            'password' => 'required|string|min:6|confirmed',
            'no_hp'    => 'nullable|string|max:20',
            'alamat'   => 'nullable|string',
        ];

        // Jika role warga: wajib NIK
        if ($request->role === 'warga') {
            $rules['nik']   = 'required|digits:16|unique:users,nik';
            $rules['email'] = 'nullable|email|unique:users,email';
        } else {
            // Role lain: wajib email
            $rules['email'] = 'required|email|unique:users,email';
            $rules['nik']   = 'nullable';
        }

        // Petugas dan Kasi wajib seksi_id
        if (in_array($request->role, ['petugas', 'kasi'])) {
            $rules['seksi_id'] = 'required|exists:seksi,id';
        }

        $validated = $request->validate($rules, [
            'nik.required'      => 'NIK wajib diisi untuk akun warga.',
            'nik.digits'        => 'NIK harus 16 digit angka.',
            'nik.unique'        => 'NIK sudah terdaftar.',
            'email.required'    => 'Email wajib diisi.',
            'email.unique'      => 'Email sudah terdaftar.',
            'seksi_id.required' => 'Seksi wajib dipilih untuk petugas/kasi.',
        ]);

        $user = User::create([
            'name'      => $validated['name'],
            'email'     => $validated['email'] ?? null,
            'nik'       => $validated['nik'] ?? null,
            'password'  => Hash::make($validated['password']),
            'role'      => $validated['role'],
            'seksi_id'  => $validated['seksi_id'] ?? null,
            'no_hp'     => $validated['no_hp'] ?? null,
            'alamat'    => $validated['alamat'] ?? null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Akun berhasil dibuat.',
            'data'    => $user->load('seksi'),
        ], 201);
    }

    /**
     * Daftar semua pengguna (bisa filter by role)
     */
    public function index(Request $request): JsonResponse
    {
        $query = User::with('seksi');

        if ($request->filled('role')) {
            $query->where('role', $request->role);
        }

        if ($request->filled('seksi_id')) {
            $query->where('seksi_id', $request->seksi_id);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%$search%")
                  ->orWhere('email', 'like', "%$search%")
                  ->orWhere('nik', 'like', "%$search%");
            });
        }

        $users = $query->orderBy('created_at', 'desc')
                       ->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data'    => $users,
        ]);
    }

    /**
     * Detail pengguna
     */
    public function show(int $id): JsonResponse
    {
        $user = User::with('seksi')->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $user,
        ]);
    }

    /**
     * Update akun pengguna
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $user = User::findOrFail($id);

        $rules = [
            'name'  => 'sometimes|required|string|max:255',
            'no_hp' => 'nullable|string|max:20',
            'alamat'=> 'nullable|string',
        ];

        if ($user->role === 'warga') {
            $rules['nik'] = ['sometimes', 'required', 'digits:16', Rule::unique('users', 'nik')->ignore($user->id)];
        } else {
            $rules['email'] = ['sometimes', 'required', 'email', Rule::unique('users', 'email')->ignore($user->id)];
        }

        if (in_array($user->role, ['petugas', 'kasi'])) {
            $rules['seksi_id'] = 'sometimes|required|exists:seksi,id';
        }

        if ($request->filled('password')) {
            $rules['password'] = 'required|string|min:6|confirmed';
        }

        $validated = $request->validate($rules);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Akun berhasil diperbarui.',
            'data'    => $user->fresh()->load('seksi'),
        ]);
    }

    /**
     * Hapus akun pengguna (soft delete)
     */
    public function destroy(int $id): JsonResponse
    {
        $user = User::findOrFail($id);

        // Admin tidak bisa hapus diri sendiri
        if ($user->id === auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat menghapus akun sendiri.',
            ], 422);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'Akun berhasil dihapus.',
        ]);
    }
}
