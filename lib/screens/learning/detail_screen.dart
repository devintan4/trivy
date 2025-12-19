import 'package:flutter/material.dart';
import 'package:trivy/models/destination_model.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- TUGAS 4 (POIN 20): MENERIMA DATA ---
    // Mengambil argumen yang dikirim dan mengubahnya kembali menjadi objek Destination
    final destination =
        ModalRoute.of(context)!.settings.arguments as Destination;

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan gambar sesuai data yang dikirim
            Image.asset(
              destination.imagePath,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.blue, size: 20),
                      SizedBox(width: 5),
                      Text(
                        "Popular Destination",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "This is a wonderful place to visit. You can enjoy the beautiful scenery and local culture here. Integrated with our travel system, you can now book tours and hotels nearby directly from the app.",
                    style: TextStyle(color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text("Book This Destination"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
