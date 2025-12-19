import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivy/models/hotel_model.dart';
import 'package:trivy/providers/home_providers.dart';
import 'package:trivy/widgets/hotel_card.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHotelsAsync = ref.watch(hotelRecommendationsProvider);
    final likedHotelIdsAsync = ref.watch(likedHotelsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Hotels')),
      body: allHotelsAsync.when(
        data: (allHotels) {
          return likedHotelIdsAsync.when(
            data: (likedHotelIds) {
              final savedHotels = allHotels
                  .where((hotel) => likedHotelIds.contains(hotel.id))
                  .toList();

              if (savedHotels.isEmpty) {
                return const Center(
                  child: Text(
                    'You haven\'t saved any hotels yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20.0),
                itemCount: savedHotels.length,
                itemBuilder: (context, index) {
                  final hotel = savedHotels[index];
                  return HotelCard(hotel: hotel);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Error loading likes: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading hotels: $err')),
      ),
    );
  }
}
