import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivy/models/destination_model.dart';
import 'package:trivy/models/hotel_model.dart';

final usernameProvider = Provider<String>((ref) {
  return 'Explorer!';
});

final popularDestinationsProvider = Provider<List<Destination>>((ref) {
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

final hotelRecommendationsProvider = Provider<List<Hotel>>((ref) {
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
