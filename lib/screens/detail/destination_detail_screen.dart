import 'package:flutter/material.dart';
import 'package:trivy/models/destination_model.dart'; //

class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                destination.title, //
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              background: Image.asset(
                destination.imagePath, //
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Ini adalah konten halaman di bawah gambar
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          destination.location, //
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'About this destination',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Teks placeholder untuk deskripsi
                    Text(
                      'Deskripsi lengkap untuk ${destination.title} akan ditampilkan di sini. '
                      'Ini adalah tempat yang indah di ${destination.location} '
                      'yang menawarkan pemandangan menakjubkan dan pengalaman tak terlupakan. '
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                      'Nullam ac quam et turpis.',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(
                      height: 400,
                    ), // Memberi ruang agar bisa di-scroll
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
