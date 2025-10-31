import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/model.dart'; 

class DatabaseHelper {
  static const _databaseName = "Habits.db";
  static const _databaseVersion = 1;
  static const table = 'habits_table';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        isCompleted INTEGER NOT NULL
      )
      ''');
  }

  Future<int> insert(Habit habit) async {
    Database db = await instance.database;
    return await db.insert(table, habit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Habit>> queryAllHabits() async {
    Database db = await instance.database;
    // Mengurutkan berdasarkan nama A-Z
    final maps = await db.query(table, orderBy: 'name ASC');

    // Konversi List<Map<String, dynamic>> ke List<Habit>
    return List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    });
  }

  /// Memperbarui Habit yang ada.
  Future<int> update(Habit habit) async {
    Database db = await instance.database;
    return await db.update(table, habit.toMap(),
        where: 'id = ?', whereArgs: [habit.id]);
  }

  /// Menghapus Habit berdasarkan ID.
  Future<int> delete(String id) async {
    Database db = await instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}