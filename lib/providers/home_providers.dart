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
      id: 'dest_01', // Tambahkan ID agar bisa disimpan di DB
      imagePath: 'assets/images/destination_bali.png',
      title: 'Kelingking Beach',
      location: 'Bali, Indonesia',
    ),
    Destination(
      id: 'dest_02',
      imagePath: 'assets/images/destination_paris.png',
      title: 'Eiffel Tower',
      location: 'Paris, France',
    ),
    Destination(
      id: 'dest_03',
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
      id: 'hotel_01', // Tambahkan ID agar fitur Like bekerja
      imagePath: 'assets/images/destination_santorini.png',
      name: 'Santorini Resort',
      location: 'Greece',
      rating: 4.8,
    ),
    Hotel(
      id: 'hotel_02',
      imagePath: 'assets/images/destination_bali.png',
      name: 'Ubud Valley Hotel',
      location: 'Bali, Indonesia',
      rating: 4.9,
    ),
  ];
});

// --- STATE NOTIFIER UNTUK LIKED HOTELS (SUDAH ADA) ---
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

// --- TAMBAHKAN DI SINI: BOOKING NOTIFIER ---
// Menangani logika penyimpanan booking ke SQLite dan memperbarui state UI
class BookingNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    // Mengambil riwayat booking saat aplikasi pertama kali dijalankan
    return await DatabaseHelper.instance.getAllBookings();
  }

  // Fungsi untuk menambah booking baru ke SQLite
  Future<void> addBooking(String id, String title) async {
    final db = DatabaseHelper.instance;

    // 1. Simpan ke Database Fisik
    await db.insertBooking(id, title);

    // 2. Perbarui State aplikasi agar UI tahu ada data baru
    state = AsyncData(await db.getAllBookings());
  }
}

// Provider global untuk fitur Booking
final bookingProvider =
    AsyncNotifierProvider<BookingNotifier, List<Map<String, dynamic>>>(
      BookingNotifier.new,
    );
