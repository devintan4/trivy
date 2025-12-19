import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivy/models/destination_model.dart';
import 'package:trivy/models/hotel_model.dart';
import 'package:trivy/providers/home_providers.dart';
import 'package:trivy/providers/api_providers.dart';
import 'package:trivy/providers/settings_provider.dart';

class TravelerCounter extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const TravelerCounter({
    super.key,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.remove_circle_outline, color: Colors.blue),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count Travelers',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
        ),
      ],
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _travelerCount = 1;
  String _travelerName = "Guest";
  final _bookingFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  void _incrementTraveler() {
    setState(() {
      _travelerCount++;
    });
  }

  void _decrementTraveler() {
    if (_travelerCount > 1) {
      setState(() {
        _travelerCount--;
      });
    }
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          _buildHeader(username),
          const SizedBox(height: 20),
          _buildSearchBar(),

          // --- IMPLEMENTASI LIFTING STATE UP ---
          _buildTravelSection(
            'Quick Trip Planner',
            Column(
              children: [
                const Text(
                  'Select number of travelers for your journey:',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 15),
                TravelerCounter(
                  count: _travelerCount,
                  onAdd: _incrementTraveler,
                  onRemove: _decrementTraveler,
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Text(
              'Explore Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _buildCategoryGrid(),

          _buildSectionTitle('Popular Destinations', () {}),
          destinations.when(
            data: (data) => _buildPopularDestinations(data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),

          _buildTravelSection(
            'Traveler Profile',
            Column(
              children: [
                Form(
                  key: _bookingFormKey,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter a name' : null,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_bookingFormKey.currentState!.validate()) {
                        setState(() => _travelerName = _nameController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Identity Updated!')),
                        );
                      }
                    },
                    child: const Text('Update Identity'),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Current Traveler: $_travelerName',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          _buildSectionTitle('Top Rated Hotels', () {}),
          hotels.when(
            data: (data) => _buildHotelList(data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),

          _buildSectionTitle('Global Hot Destinations', () {}),
          Consumer(
            builder: (context, ref, _) {
              final apiData = ref.watch(postsProvider);

              return apiData.when(
                data: (posts) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: posts
                        .take(5)
                        .map(
                          (post) => Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.explore,
                                  color: Colors.blue,
                                ),
                              ),
                              title: Text(
                                post.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                post.body,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    title: Text(post.title),
                                    content: SingleChildScrollView(
                                      child: Text(post.body),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error loading insights: $e')),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Beaches', 'icon': Icons.beach_access, 'color': Colors.orange},
      {'name': 'Mountains', 'icon': Icons.terrain, 'color': Colors.green},
      {'name': 'Cities', 'icon': Icons.location_city, 'color': Colors.blue},
      {'name': 'Forests', 'icon': Icons.park, 'color': Colors.teal},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: categories[index]['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(categories[index]['icon'], color: categories[index]['color']),
            const SizedBox(width: 10),
            Text(
              categories[index]['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelSection(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }

  Widget _buildHeader(String user) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
    child: Text(
      'Hi, $user',
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      decoration: InputDecoration(
        hintText: 'Search destinations...',
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search),
      ),
    ),
  );

  Widget _buildSectionTitle(String t, VoidCallback o) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          t,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: o, child: const Text('See All')),
      ],
    ),
  );

  Widget _buildPopularDestinations(List<Destination> list) => SizedBox(
    height: 200,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _DestinationCard(destination: list[i]),
    ),
  );

  Widget _buildHotelList(List<Hotel> list) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _HotelCard(hotel: list[i]),
    ),
  );
}

class _DestinationCard extends StatelessWidget {
  final Destination destination;
  const _DestinationCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/detail', arguments: destination),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
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
                  padding: const EdgeInsets.all(8),
                  color: Colors.black45,
                  child: Text(
                    destination.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
    final likedIdsAsync = ref.watch(likedHotelsProvider);

    return likedIdsAsync.when(
      data: (ids) => Card(
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              hotel.imagePath,
              width: 50,
              height: 50,
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
              ids.contains(hotel.id) ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () => ref
                .read(likedHotelsProvider.notifier)
                .toggleLikeStatus(hotel.id),
          ),
        ),
      ),
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}
