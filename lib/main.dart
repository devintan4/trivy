import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivy/screens/home/home_screen.dart';
import 'package:trivy/screens/learning/detail_screen.dart'; // Pastikan import ini ada
import 'package:trivy/models/destination_model.dart'; // Dibutuhkan untuk pengecekan tipe data

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivy Travel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      // Menggunakan home untuk rute awal
      home: const HomeScreen(),

      // --- PERBAIKAN: Menambahkan Generator untuk Route /detail ---
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          // Mengambil argumen yang dikirim (objek Destination)
          final args = settings.arguments as Destination;

          return MaterialPageRoute(
            builder: (context) {
              return const DetailScreen();
              // Catatan: Pastikan DetailScreen Anda sudah menggunakan
              // ModalRoute.of(context)!.settings.arguments untuk menangkap data
            },
            settings:
                settings, // Meneruskan settings agar argumen terbaca di screen tujuan
          );
        }
        return null; // Membiarkan route lain ditangani secara default
      },
    );
  }
}
