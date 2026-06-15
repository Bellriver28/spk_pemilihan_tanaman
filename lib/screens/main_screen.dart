import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'kriteria_screen.dart';
import 'alternatif_screen.dart';
import 'proses_screen.dart';
import 'hasil_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Daftar halaman yang akan dipanggil oleh Navbar
    final List<Widget> pages = [
      HomeScreen(onNavigate: _onItemTapped),      // Index 0
      KriteriaScreen(onNavigate: _onItemTapped),  // Index 1
      AlternatifScreen(onNavigate: _onItemTapped),// Index 2
      ProsesScreen(onNavigate: _onItemTapped),    // Index 3
      HasilScreen(onNavigate: _onItemTapped),     // Index 4
    ];

    return Scaffold(
      body: pages[_selectedIndex],

      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Kriteria'),
            BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Alternatif'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Proses'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Hasil'),
          ],
        ),
      ),
    );
  }
}