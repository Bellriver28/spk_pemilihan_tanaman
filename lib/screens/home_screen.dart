import 'package:flutter/material.dart';
import 'view_dataset_screen.dart';
import '../services/pdf_report_service.dart'; // Sesuaikan path ini dengan lokasi file PDF service kamu

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // AppBar dihapus agar tampilan full bersih dari atas
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20), // Memberi jarak agar tidak menempel ke batas atas HP
              const Text('Selamat datang!', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const Text('SPK Pemilihan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
              const Text('Tanaman Terbaik', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 16),

              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/banner_home.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildMenuCard(context, 'Data Kriteria', Icons.list_alt, Colors.green, 1),
                    _buildMenuCard(context, 'Data Alternatif', Icons.park, Colors.green, 2),
                    _buildMenuCard(context, 'View Dataset', Icons.grid_on, Colors.blue, -99),
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
      onTap: () async {
        if (title == 'Laporan') {
          // Menampilkan indikator loading saat PDF dibuat
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          // Generate PDF
          await PdfReportService.generateAndPrintReport();

          if (context.mounted) Navigator.pop(context); // Menutup dialog loading

        } else if (title == 'View Dataset') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewDatasetScreen(onNavigate: onNavigate),
            ),
          );
        } else if (tabIndex >= 0) {
          onNavigate(tabIndex);
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