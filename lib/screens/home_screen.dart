import 'package:flutter/material.dart';
import 'input_nilai_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate; // Menerima fungsi klik dari MainScreen

  const HomeScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat datang!', style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text('SPK Pemilihan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Tanaman Terbaik', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      // SAFE AREA: Mencegah bagian atas/bawah ketutupan sistem HP
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              // --- PERBAIKAN DI SINI: MENGGUNAKAN GAMBAR BANNER DARI FIGMA ---
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // Ganti 'banner_home.png' sesuai dengan nama file yang Anda save dari Figma
                  image: const DecorationImage(
                    image: AssetImage('assets/images/banner_home.png'),
                    fit: BoxFit.cover, // Gambar akan memenuhi area kotak dengan rapi
                  ),
                ),
              ),
              // ---------------------------------------------------------------

              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    // Angka di belakang adalah Index Tab (1 = Kriteria, 2 = Alternatif, dst)
                    _buildMenuCard(context, 'Data Kriteria', Icons.list_alt, Colors.green, 1),
                    _buildMenuCard(context, 'Data Alternatif', Icons.park, Colors.green, 2),
                    _buildMenuCard(context, 'Input Nilai', Icons.grid_on, Colors.blue, -1), // -1 karena tidak ada di Navbar
                    _buildMenuCard(context, 'Proses TOPSIS', Icons.calculate, Colors.orange, 3),
                    _buildMenuCard(context, 'Hasil Ranking', Icons.emoji_events, Colors.amber, 4),
                    _buildMenuCard(context, 'Laporan', Icons.print, Colors.teal, -2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, int tabIndex) {
    return InkWell(
      onTap: () {
        if (tabIndex >= 0) {
          // Jika menu tersebut ada di Navbar, geser tab!
          onNavigate(tabIndex);
        } else if (title == 'Input Nilai') {
          // Khusus Input Nilai, tetap buka halaman baru karena tidak ada di Navbar
          Navigator.push(context, MaterialPageRoute(builder: (context) => const InputNilaiScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Halaman $title sedang dikembangkan')));
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}