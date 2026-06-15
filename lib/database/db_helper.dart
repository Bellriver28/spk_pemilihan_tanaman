import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database? _db;
  static const String DB_NAME = 'spk_tanaman_topsis.db';
  static const String tableKriteria = 'kriteria';
  static const String tableAlternatif = 'alternatif';

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  initDB() async {
    var dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, DB_NAME);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    // 1. Buat Tabel Kriteria
    await db.execute('''
      CREATE TABLE $tableKriteria(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        bobot REAL,
        jenis TEXT
      )
    ''');

    // 2. Buat Tabel Alternatif (Awalnya hanya ID dan Nama)
    await db.execute('''
      CREATE TABLE $tableAlternatif(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT
      )
    ''');

    // 3. Seed Kriteria Awal & Tambah Kolom ke Tabel Alternatif
    List<Map<String, dynamic>> kriteriaAwal = [
      {'nama': 'n', 'bobot': 0.30, 'jenis': 'Cost'},
      {'nama': 'p', 'bobot': 0.25, 'jenis': 'Cost'},
      {'nama': 'k', 'bobot': 0.25, 'jenis': 'Cost'},
      {'nama': 'temperature', 'bobot': 0.35, 'jenis': 'Cost'},
      {'nama': 'humidity', 'bobot': 0.25, 'jenis': 'Cost'},
      {'nama': 'ph', 'bobot': 0.25, 'jenis': 'Cost'},
      {'nama': 'rainfall', 'bobot': 0.35, 'jenis': 'Benefit'},
    ];

    for (var k in kriteriaAwal) {
      await db.insert(tableKriteria, k);
      await db.execute("ALTER TABLE $tableAlternatif ADD COLUMN ${k['nama']} REAL DEFAULT 0.0");
    }

    // 4. Seed Data Alternatif (22 Data Tanaman)
    List<Map<String, dynamic>> datasetExcel = [
      {'nama': 'apple', 'n': 20.8, 'p': 134.22, 'k': 199.89, 'temperature': 22.63, 'humidity': 92.33, 'ph': 5.93, 'rainfall': 112.65},
      {'nama': 'banana', 'n': 100.23, 'p': 82.01, 'k': 50.05, 'temperature': 27.38, 'humidity': 80.36, 'ph': 5.98, 'rainfall': 104.63},
      {'nama': 'blackgram', 'n': 40.02, 'p': 67.47, 'k': 19.24, 'temperature': 29.97, 'humidity': 65.12, 'ph': 7.13, 'rainfall': 67.88},
      {'nama': 'chickpea', 'n': 40.09, 'p': 67.79, 'k': 79.92, 'temperature': 18.87, 'humidity': 16.86, 'ph': 7.34, 'rainfall': 80.06},
      {'nama': 'coconut', 'n': 21.98, 'p': 16.93, 'k': 30.59, 'temperature': 27.41, 'humidity': 94.84, 'ph': 5.98, 'rainfall': 175.69},
      {'nama': 'coffee', 'n': 101.2, 'p': 28.74, 'k': 29.94, 'temperature': 25.54, 'humidity': 58.87, 'ph': 6.79, 'rainfall': 158.07},
      {'nama': 'cotton', 'n': 117.77, 'p': 46.24, 'k': 19.56, 'temperature': 23.99, 'humidity': 79.84, 'ph': 6.91, 'rainfall': 80.4},
      {'nama': 'grapes', 'n': 23.18, 'p': 132.53, 'k': 200.11, 'temperature': 23.85, 'humidity': 81.88, 'ph': 6.03, 'rainfall': 69.61},
      {'nama': 'jute', 'n': 78.4, 'p': 46.86, 'k': 39.99, 'temperature': 24.96, 'humidity': 79.64, 'ph': 6.73, 'rainfall': 174.79},
      {'nama': 'kidneybeans', 'n': 20.75, 'p': 67.54, 'k': 20.05, 'temperature': 20.12, 'humidity': 21.61, 'ph': 5.75, 'rainfall': 105.92},
      {'nama': 'lentil', 'n': 18.77, 'p': 68.36, 'k': 19.41, 'temperature': 24.51, 'humidity': 64.8, 'ph': 6.93, 'rainfall': 45.68},
      {'nama': 'maize', 'n': 77.76, 'p': 48.44, 'k': 19.79, 'temperature': 22.39, 'humidity': 65.09, 'ph': 6.25, 'rainfall': 84.77},
      {'nama': 'mango', 'n': 20.07, 'p': 27.18, 'k': 29.92, 'temperature': 31.21, 'humidity': 50.16, 'ph': 5.77, 'rainfall': 94.7},
      {'nama': 'mothbeans', 'n': 21.44, 'p': 48.01, 'k': 20.23, 'temperature': 28.19, 'humidity': 53.16, 'ph': 6.83, 'rainfall': 51.2},
      {'nama': 'mungbean', 'n': 20.99, 'p': 47.28, 'k': 19.87, 'temperature': 28.53, 'humidity': 85.5, 'ph': 6.72, 'rainfall': 48.44},
      {'nama': 'muskmelon', 'n': 100.32, 'p': 17.72, 'k': 50.08, 'temperature': 28.66, 'humidity': 92.34, 'ph': 6.36, 'rainfall': 24.69},
      {'nama': 'orange', 'n': 19.58, 'p': 16.55, 'k': 10.01, 'temperature': 22.77, 'humidity': 92.17, 'ph': 7.02, 'rainfall': 110.47},
      {'nama': 'papaya', 'n': 49.88, 'p': 59.05, 'k': 50.04, 'temperature': 33.72, 'humidity': 92.4, 'ph': 6.74, 'rainfall': 142.63},
      {'nama': 'pigeonpeas', 'n': 20.73, 'p': 67.73, 'k': 20.29, 'temperature': 27.74, 'humidity': 48.06, 'ph': 5.79, 'rainfall': 149.46},
      {'nama': 'pomegranate', 'n': 18.87, 'p': 18.75, 'k': 40.21, 'temperature': 21.84, 'humidity': 90.13, 'ph': 6.43, 'rainfall': 107.53},
      {'nama': 'rice', 'n': 79.89, 'p': 47.58, 'k': 39.87, 'temperature': 23.69, 'humidity': 82.27, 'ph': 6.43, 'rainfall': 236.18},
      {'nama': 'watermelon', 'n': 99.42, 'p': 17.0, 'k': 50.22, 'temperature': 25.59, 'humidity': 85.16, 'ph': 6.5, 'rainfall': 50.79},
    ];

    for (var t in datasetExcel) {
      await db.insert(tableAlternatif, t);
    }
  }

  Future<void> addNewKriteriaColumn(String namaKriteria) async {
    final dbClient = await db;
    var result = await dbClient.rawQuery("PRAGMA table_info($tableAlternatif)");
    bool exists = result.any((col) => col['name'] == namaKriteria.toLowerCase());

    if (!exists) {
      await dbClient.execute("ALTER TABLE $tableAlternatif ADD COLUMN $namaKriteria REAL DEFAULT 0.0");
    }
  }

  Future<List<Map<String, dynamic>>> getKriteria() async => (await db).query(tableKriteria);
  Future<List<Map<String, dynamic>>> getAlternatif() async => (await db).query(tableAlternatif);
}