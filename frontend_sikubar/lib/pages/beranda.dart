import 'package:flutter/material.dart';
import '../widgets/bottom_menuwarga.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2F80ED), Color(0xFF1C4FA1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                /// 🔵 HEADER
                const SizedBox(height: 20),
                const Icon(Icons.account_balance, color: Colors.white, size: 55),
                const SizedBox(height: 8),
                const Text(
                  "Kecamatan Kundur Barat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                

                const SizedBox(height: 20),

                /// 🏙️ BANNER
                _banner(),

                /// 📝 DESKRIPSI
                _deskripsiKecamatan(),

                /// 📊 STATISTIK
                _sectionTitle("Statistik Kecamatan"),
                _statistik(),

                /// 🏘️ WILAYAH (SLIDER 🔥)
                _sectionTitle("Wilayah Kecamatan"),
                _wilayahSlider(),

          

                /// 📢 INFO PENTING
                _sectionTitle("Informasi Penting"),
                _infoCard(),

                /// 📰 BERITA
                _sectionTitle("Berita & Pengumuman"),
                _beritaList(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomMenu(currentIndex: 0),
    );
  }

  /// 🔹 TITLE
  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// 🏙️ BANNER
  static Widget _banner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage("assets/kantorcamatkuba.jpeg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// 📝 DESKRIPSI
  static Widget _deskripsiKecamatan() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tentang Kecamatan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Kecamatan Kundur Barat merupakan salah satu kecamatan di Kabupaten Karimun yang terbentuk dari pemekaran Kecamatan Kundur berdasarkan Undang-Undang Nomor 53 Tahun 1999. Kecamatan ini terdiri dari 1 kelurahan dan 4 desa dengan luas wilayah sekitar 271,51 km².",
            textAlign: TextAlign.justify,
            style: TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  /// 📊 STATISTIK
  static Widget _statistik() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _statCard("19.405", "Penduduk"),
          _statCard("271,51", "Km²"),
          _statCard("5", "Wilayah"),
          _statCard("111", "RT"),
          _statCard("44", "RW"),
        ],
      ),
    );
  }

  static Widget _statCard(String angka, String label) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(angka,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// 🏘️ WILAYAH SLIDER
  static Widget _wilayahSlider() {
    final List<Map<String, String>> desa = [
      {"nama": "Kelurahan Sawang", "img": "assets/sawang.jpg"},
      {"nama": "Desa Sawang Laut", "img": "assets/sawang_laut.jpg"},
      {"nama": "Desa Kundur", "img": "assets/kundur.jpg"},
      {"nama": "Desa Sawang Selatan", "img": "assets/sawang_selatan.jpg"},
      {"nama": "Desa Gemuruh", "img": "assets/gemuruh.jpg"},
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: desa.length,
        itemBuilder: (context, index) {
          final item = desa[index];

          return Container(
            width: 140,
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 6)
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    item["img"]!,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    item["nama"]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  

  static Widget _menuItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  /// 📢 INFO
  static Widget _infoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text("Pelayanan buka Senin - Jumat (08.00 - 14.00)"),
          )
        ],
      ),
    );
  }

  /// 📰 BERITA
  static Widget _beritaList() {
    return Column(
      children: [
        _beritaItem("Program Digitalisasi Kecamatan", "Hari ini"),
        _beritaItem("Pelayanan Online Ditingkatkan", "Kemarin"),
        _beritaItem("Sosialisasi Warga", "2 hari lalu"),
      ],
    );
  }

  static Widget _beritaItem(String title, String waktu) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(waktu),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}