import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivy/models/destination_model.dart';
import 'package:trivy/models/hotel_model.dart';
import 'package:trivy/database_helper.dart';

final usernameProvider = Provider<String>((ref) {
  return 'Explorer!';
});

final popularDestinationsProvider = FutureProvider<List<Destination>>((
  ref,
) async {
  await Future.delayed(const Duration(seconds: 2));
  return [
    Destination(
      imagePath: 'assets/images/destination_bali.png',
      title: 'Kelingking Beach',
      location: 'Bali, Indonesia',
    ),
    Destination(
      imagePath: 'assets/images/destination_paris.png',
      title: 'Eiffel Tower',
      location: 'Paris, France',
    ),
    Destination(
      imagePath: 'assets/images/destination_santorini.png',
      title: 'Santorini',
      location: 'Greece',
    ),
  ];
});

final hotelRecommendationsProvider = FutureProvider<List<Hotel>>((ref) async {
  await Future.delayed(const Duration(seconds: 3));
  return [
    Hotel(
      imagePath: 'assets/images/destination_santorini.png',
      name: 'Santorini Resort',
      location: 'Greece',
      rating: 4.8,
    ),
    Hotel(
      imagePath: 'assets/images/destination_bali.png',
      name: 'Ubud Valley Hotel',
      location: 'Bali, Indonesia',
      rating: 4.9,
    ),
  ];
});

class LikedHotelsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return await DatabaseHelper.instance.getLikedHotels();
  }

  Future<void> toggleLikeStatus(String hotelId) async {
    final db = DatabaseHelper.instance;
    final currentLikedIds = state.value ?? [];
    final isCurrentlyLiked = currentLikedIds.contains(hotelId);

    if (isCurrentlyLiked) {
      state = AsyncData(currentLikedIds.where((id) => id != hotelId).toList());
      await db.unlikeHotel(hotelId);
    } else {
      state = AsyncData([...currentLikedIds, hotelId]);
      await db.likeHotel(hotelId);
    }
  }
}

final likedHotelsProvider =
    AsyncNotifierProvider<LikedHotelsNotifier, List<String>>(
      LikedHotelsNotifier.new,
    );
