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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY NOT NULL';

    await db.execute('''
      CREATE TABLE liked_hotels (
        id $idType
      )
    ''');
  }

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

    if (maps.isNotEmpty) {
      return maps.map((json) => json['id'] as String).toList();
    } else {
      return [];
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
