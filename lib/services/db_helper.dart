// NOTE: Tambahkan dependencies sqflite dan path di pubspec.yaml
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/wisata_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wisata.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wisata(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        lokasi TEXT,
        deskripsi TEXT,
        kategori TEXT,
        gambarPath TEXT,
        dana INTEGER,
        tanggalKunjungan TEXT,
        lat REAL,
        lng REAL
      )
    ''');
  }

  Future<int> insertWisata(WisataModel wisata) async {
    final db = await instance.database;
    return await db.insert('wisata', wisata.toMap());
  }

  Future<List<WisataModel>> getAllWisata() async {
    final db = await instance.database;
    final result = await db.query('wisata');
    return result.map((map) => WisataModel.fromMap(map)).toList();
  }

  Future<int> updateWisata(WisataModel wisata) async {
    final db = await instance.database;
    return await db.update('wisata', wisata.toMap(), where: 'id = ?', whereArgs: [wisata.id]);
  }

  Future<int> deleteWisata(int id) async {
    final db = await instance.database;
    return await db.delete('wisata', where: 'id = ?', whereArgs: [id]);
  }
} 