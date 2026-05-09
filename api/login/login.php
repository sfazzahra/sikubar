<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

include '../config/database.php';

// Ambil data JSON dari Flutter
$data = json_decode(file_get_contents("php://input"), true);

$identifier = $data['identifier'];
$password = $data['password'];

// ==========================
// LOGIN WARGA (pakai NIK)
// ==========================
if (is_numeric($identifier)) {

    $query = "SELECT * FROM tb_warga WHERE nik='$identifier'";
    $result = mysqli_query($conn, $query);

    if (mysqli_num_rows($result) > 0) {

        $user = mysqli_fetch_assoc($result);

        if ($password == $user['password']) {

            echo json_encode([
                "success" => true,
                "role" => "warga",
                "message" => "Login warga berhasil"
            ]);

        } else {

            echo json_encode([
                "success" => false,
                "message" => "Password salah"
            ]);
        }

    } else {

        echo json_encode([
            "success" => false,
            "message" => "NIK tidak ditemukan"
        ]);
    }

// ==========================
// LOGIN ADMIN/PETUGAS/KASI/CAMAT
// ==========================
} else {

    $query = "SELECT * FROM tb_users WHERE email='$identifier'";
    $result = mysqli_query($conn, $query);

    if (mysqli_num_rows($result) > 0) {

        $user = mysqli_fetch_assoc($result);

        if ($password == $user['password']) {

            echo json_encode([
                "success" => true,
                "role" => $user['role'],
                "message" => "Login berhasil"
            ]);

        } else {

            echo json_encode([
                "success" => false,
                "message" => "Password salah"
            ]);
        }

    } else {

        echo json_encode([
            "success" => false,
            "message" => "Email tidak ditemukan"
        ]);
    }
}

?>