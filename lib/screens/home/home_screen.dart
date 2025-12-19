import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivy/models/destination_model.dart';
import 'package:trivy/models/hotel_model.dart';
import 'package:trivy/providers/home_providers.dart';
import 'package:trivy/providers/api_providers.dart';
import 'package:trivy/providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // --- STATE MANAGEMENT (Sekarang untuk fitur Reservasi/Rencana) ---
  String _travelerName = "Guest";
  int _groupSize = 1;
  bool _isPremiumMember = false;
  final _bookingFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  void _increaseGroupSize() {
    setState(() {
      _groupSize++;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(popularDestinationsProvider);
    final hotels = ref.watch(hotelRecommendationsProvider);
    final username = ref.watch(usernameProvider);
    final isExpertMode = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          _buildHeader(username),
          const SizedBox(height: 20),
          _buildSearchBar(),

          // --- FITUR 1: QUICK PLANNING (Implementasi State & Grouping) ---
          _buildTravelSection(
            'Quick Trip Planner',
            Column(
              children: [
                Text(
                  'Group Size: $_groupSize People',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _increaseGroupSize,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Traveler'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Priority Pass (Fast Track)'),
                  secondary: const Icon(
                    Icons.verified_user,
                    color: Colors.orange,
                  ),
                  value: _isPremiumMember,
                  onChanged: (v) => setState(() => _isPremiumMember = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildSectionTitle('Popular Destinations', () {}),
          destinations.when(
            data: (data) => _buildPopularDestinations(data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('Error loading destinations: $err')),
          ),

          // --- FITUR 2: REGISTRATION (Implementasi Form & Validation) ---
          _buildTravelSection(
            'Update Traveler Profile',
            Form(
              key: _bookingFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_bookingFormKey.currentState!.validate()) {
                          setState(() => _travelerName = _nameController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully!'),
                            ),
                          );
                        }
                      },
                      child: const Text('Update Identity'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Current Traveler: $_travelerName',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          _buildSectionTitle('Top Rated Hotels', () {}),
          hotels.when(
            data: (data) => _buildHotelList(data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('Error loading hotels: $err')),
          ),

          // --- FITUR 3: TRAVEL NEWS (Implementasi REST API) ---
          _buildTravelSection(
            'Traveler Insights (Global)',
            Consumer(
              builder: (context, ref, _) {
                final apiData = ref.watch(postsProvider);
                return apiData.when(
                  data: (posts) => Column(
                    children: posts
                        .take(3)
                        .map(
                          (post) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: const Icon(
                                Icons.explore_outlined,
                                color: Colors.blue,
                              ),
                              title: Text(
                                post.title,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                post.body,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) =>
                      const Text('Unable to fetch latest insights.'),
                );
              },
            ),
          ),

          // --- FITUR 4: APP SETTINGS (Implementasi SharedPreferences) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Advanced Explorer Mode',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: isExpertMode,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setExpertMode(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildTravelSection(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildHeader(String username) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $username',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Ready for a new adventure?',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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
          hintText: 'Search destinations...',
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
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
          TextButton(onPressed: onTap, child: const Text('See All')),
        ],
      ),
    );
  }

  Widget _buildPopularDestinations(List<Destination> list) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: list.length,
        itemBuilder: (context, index) =>
            _DestinationCard(destination: list[index]),
      ),
    );
  }

  Widget _buildHotelList(List<Hotel> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _HotelCard(hotel: list[index]),
      ),
    );
  }
}

// --- WIDGET COMPONENTS (MODERN TRAVEL STYLE) ---

class _DestinationCard extends StatelessWidget {
  final Destination destination;
  const _DestinationCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (ctx) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(destination.imagePath),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    destination.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(destination.imagePath, fit: BoxFit.cover),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Text(
                    destination.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotelCard extends ConsumerWidget {
  final Hotel hotel;
  const _HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedHotelIdsAsync = ref.watch(likedHotelsProvider);

    return likedHotelIdsAsync.when(
      data: (likedIds) {
        final isLiked = likedIds.contains(hotel.id);
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                hotel.imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              hotel.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(hotel.location),
            trailing: IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () => ref
                  .read(likedHotelsProvider.notifier)
                  .toggleLikeStatus(hotel.id),
            ),
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Room Booking'),
                content: Text('Proceed to book a room at ${hotel.name}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const ListTile(title: Text('Fetching status...')),
      error: (e, _) => ListTile(title: Text('Status Error: $e')),
    );
  }
}
