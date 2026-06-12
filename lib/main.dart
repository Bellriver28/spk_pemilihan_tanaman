import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPK Pemilihan Tanaman Terbaik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF1B5E20),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const SplashScreen(), // Memulai aplikasi dari Splash Screen
    );
  }
}