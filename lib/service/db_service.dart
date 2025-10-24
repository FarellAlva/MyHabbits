// // service/db_service.dart

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../model/model.dart';

// class DatabaseService {
//   Database? _database;
//   static const String _tableName = 'habits';

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB();
//     return _database!;
//   }

//   Future<String> get fullPath async {
//     final path = await getDatabasesPath();
//     return join(path, 'mahabits.db');
//   }

//   Future<Database> _initDB() async {
//     final path = await fullPath;
//     return openDatabase(
//       path,
//       version: 1,
//       onCreate: _create,
//       singleInstance: true,
//     );
//   }

//   // Membuat tabel
//   Future<void> _create(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE $_tableName (
//         id TEXT PRIMARY KEY,
//         name TEXT,
//         isCompleted INTEGER
//       )
//     ''');
//   }

//   // 1. Menyimpan/Memperbarui Habit
//   Future<void> saveHabit(Habit habit) async {
//     final db = await database;
//     await db.insert(
//       _tableName, 
//       habit.toSqliteMap(), 
//       conflictAlgorithm: ConflictAlgorithm.replace, // Jika ID sudah ada, ganti
//     );
//   }

//   // 2. Mengambil semua Habit
//   Future<List<Habit>> getHabits() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(_tableName);

//     // Mengkonversi List<Map> ke List<Habit>
//     return List.generate(maps.length, (i) {
//       return Habit.fromSqliteMap(maps[i]);
//     });
//   }

//   // 3. Menghapus Habit
//   Future<void> deleteHabit(String id) async {
//     final db = await database;
//     await db.delete(
//       _tableName,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }