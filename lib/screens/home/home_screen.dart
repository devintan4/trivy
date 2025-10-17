import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivy/models/destination_model.dart';
import 'package:trivy/models/hotel_model.dart';
import 'package:trivy/providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca data AsyncValue dari FutureProvider
    final AsyncValue<List<Destination>> destinations = ref.watch(
      popularDestinationsProvider,
    );
    final AsyncValue<List<Hotel>> hotels = ref.watch(
      hotelRecommendationsProvider,
    );

    final String username = ref.watch(usernameProvider);

    return Scaffold(
      body: ListView(
        children: [
          _buildHeader(username),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 30),
          _buildSectionTitle('Popular Destinations', () {}),
          const SizedBox(height: 20),

          // Menggunakan .when untuk menangani state loading, error, dan data
          destinations.when(
            data: (destinationsData) =>
                _buildPopularDestinations(destinationsData),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),

          const SizedBox(height: 30),
          _buildSectionTitle('Hotel Recommendations', () {}),
          const SizedBox(height: 20),

          hotels.when(
            data: (hotelsData) => _buildHotelList(hotelsData),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {},
      ),
    );
  }

  // == WIDGET-WIDGET PEMBANTU ==

  Widget _buildHeader(String username) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $username',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Discover your next journey',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/destination_paris.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          hintText: 'Search for places...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'See All',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDestinations(List<Destination> destinations) {
    return Container(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final destination = destinations[index];
          return _DestinationCard(
            destination: destination,
          ); // Gunakan widget terpisah
        },
      ),
    );
  }

  Widget _buildHotelList(List<Hotel> hotels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return _HotelCard(hotel: hotel); // Gunakan widget terpisah
        },
        separatorBuilder: (context, index) => const SizedBox(height: 15),
      ),
    );
  }
}

// == WIDGET KARTU DESTINASI (DENGAN INTERAKSI GAMBAR & OPSI) ==

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination});
  final Destination destination;

  // Fungsi untuk menampilkan dialog gambar
  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(destination.imagePath),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                destination.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // FITUR: Image Interaktif
            GestureDetector(
              onTap: () => _showImageDialog(context),
              child: Image.asset(
                destination.imagePath,
                fit: BoxFit.cover,
                height: 250,
                width: 200,
              ),
            ),
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            // FITUR: Opsi (Option)
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  // Aksi sederhana saat opsi dipilih
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$value selected for ${destination.title}'),
                    ),
                  );
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'View Details',
                    child: Text('View Details'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Add to Wishlist',
                    child: Text('Add to Wishlist'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

// == WIDGET KARTU HOTEL (DENGAN LOCAL STATE & DIALOG) ==

class _HotelCard extends ConsumerWidget {
  const _HotelCard({required this.hotel});
  final Hotel hotel;

  void _showBookingConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Booking'),
          content: Text(
            'Are you sure you want to book a room at ${hotel.name}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking for ${hotel.name} confirmed!'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedHotelIds = ref.watch(likedHotelsProvider);
    final isLiked = likedHotelIds.contains(hotel.id);

    return GestureDetector(
      onTap: () => _showBookingConfirmationDialog(context),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  hotel.imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hotel.location,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          '${hotel.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ## PERUBAHAN HANYA DI SINI ##
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  ref
                      .read(likedHotelsProvider.notifier)
                      .toggleLikeStatus(hotel.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
