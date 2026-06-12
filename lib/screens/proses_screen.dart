import 'package:flutter/material.dart';

class ProsesScreen extends StatelessWidget {
  final Function(int) onNavigate; // Tambahkan fungsi penerima

  const ProsesScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Proses TOPSIS', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.calculate, size: 100, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Siap untuk menghitung?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sistem akan melakukan kalkulasi rekomendasi tanaman dengan metode TOPSIS secara lokal dan real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('HITUNG TOPSIS NOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  // PERBAIKAN DI SINI: Cukup geser tab ke index 4 (HasilScreen)
                  onNavigate(4);
                },
              ),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Tahapan Perhitungan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            _buildStepItem('1', 'Normalisasi Matriks Keputusan'),
            _buildStepItem('2', 'Pembobotan Matriks yang Dinormalisasi'),
            _buildStepItem('3', 'Menentukan Solusi Ideal Positif (+) & Negatif (-)'),
            _buildStepItem('4', 'Menghitung Jarak ke Solusi Ideal'),
            _buildStepItem('5', 'Menghitung Nilai Preferensi Kelayakan Kelompok'),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.green[100],
            child: Text(number, style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}