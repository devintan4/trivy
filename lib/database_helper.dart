import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('trivy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Naikan versi menjadi 2 jika Anda sudah pernah menjalankan aplikasi sebelumnya
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY NOT NULL';
    const textType = 'TEXT NOT NULL';

    // 1. Tabel untuk Hotel yang di-Like
    await db.execute('''
      CREATE TABLE liked_hotels (
        id $idType
      )
    ''');

    // 2. TAMBAHKAN DI SINI: Tabel untuk History Booking
    await db.execute('''
      CREATE TABLE bookings (
        id $idType,
        title $textType,
        date $textType
      )
    ''');
  }

  // --- FUNGSI UNTUK LIKED HOTELS ---
  Future<void> likeHotel(String id) async {
    final db = await instance.database;
    await db.insert('liked_hotels', {
      'id': id,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> unlikeHotel(String id) async {
    final db = await instance.database;
    await db.delete('liked_hotels', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getLikedHotels() async {
    final db = await instance.database;
    final maps = await db.query('liked_hotels');
    return maps.isNotEmpty
        ? maps.map((json) => json['id'] as String).toList()
        : [];
  }

  // --- TAMBAHKAN DI SINI: FUNGSI UNTUK BOOKING ---

  // Fungsi untuk memasukkan data booking baru
  Future<void> insertBooking(String id, String title) async {
    final db = await instance.database;
    final String dateNow = DateTime.now()
        .toString(); // Mengambil waktu saat ini

    await db.insert('bookings', {
      'id': id,
      'title': title,
      'date': dateNow,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fungsi untuk mengambil semua riwayat booking (opsional, untuk pembuktian)
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final db = await instance.database;
    return await db.query('bookings', orderBy: 'date DESC');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
