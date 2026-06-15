import 'dart:async';
import 'package:flutter/material.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Container untuk background image
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/ilustrasi_pohon.png'),
            fit: BoxFit.cover, // Membuat gambar menutupi seluruh layar
            // ColorFilter ini opsional, untuk memastikan teks putih tetap terbaca
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4), // Gelapkan gambar 40%
              BlendMode.darken,
            ),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustrasi sudah jadi background, jadi kita tidak perlu widget Image di sini
              Text(
                "SPK Pemilihan Tanaman",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24, // Sedikit diperbesar agar terlihat elegan
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}