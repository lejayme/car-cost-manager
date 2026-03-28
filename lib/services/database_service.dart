import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/energy_record.dart';
import '../models/car_info.dart';

/// 数据库服务 - SQLite操作
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static Database? _database;
  static const String dbName = 'car_cost.db';
  static bool _initialized = false;

  /// 初始化数据库（Windows需要FFI支持）
  Future<void> _initDbFactory() async {
    if (_initialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // 桌面平台使用FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    await _initDbFactory();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // 创建开销记录表
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        mileage REAL NOT NULL
      )
    ''');

    // 创建能耗记录表
    await db.execute('''
      CREATE TABLE energy_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        energyType TEXT NOT NULL,
        price REAL NOT NULL,
        quantity REAL NOT NULL,
        totalCost REAL NOT NULL
      )
    ''');

    // 创建车辆信息表
    await db.execute('''
      CREATE TABLE car_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        startDate TEXT NOT NULL,
        purchasePrice REAL
      )
    ''');
  }

  // ========== 开销记录操作 ==========

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<Expense?> getExpenseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Expense.fromMap(maps.first);
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== 能耗记录操作 ==========

  Future<int> insertEnergyRecord(EnergyRecord record) async {
    final db = await database;
    return await db.insert('energy_records', record.toMap());
  }

  Future<List<EnergyRecord>> getAllEnergyRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'energy_records',
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => EnergyRecord.fromMap(maps[i]));
  }

  Future<List<EnergyRecord>> getEnergyRecordsByType(String energyType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'energy_records',
      where: 'energyType = ?',
      whereArgs: [energyType],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => EnergyRecord.fromMap(maps[i]));
  }

  Future<int> updateEnergyRecord(EnergyRecord record) async {
    final db = await database;
    return await db.update(
      'energy_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteEnergyRecord(int id) async {
    final db = await database;
    return await db.delete(
      'energy_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== 车辆信息操作 ==========

  Future<int> insertCarInfo(CarInfo carInfo) async {
    final db = await database;
    return await db.insert('car_info', carInfo.toMap());
  }

  Future<CarInfo?> getCarInfo() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('car_info');
    if (maps.isEmpty) return null;
    return CarInfo.fromMap(maps.first);
  }

  Future<int> updateCarInfo(CarInfo carInfo) async {
    final db = await database;
    return await db.update(
      'car_info',
      carInfo.toMap(),
      where: 'id = ?',
      whereArgs: [carInfo.id],
    );
  }

  // ========== 统计查询 ==========

  Future<double> getTotalCost() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalMileage() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(mileage) as total FROM expenses');
    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getCostByCategory() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT type, SUM(amount) as total FROM expenses GROUP BY type',
    );
    Map<String, double> categoryCosts = {};
    for (var row in result) {
      categoryCosts[row['type'] as String] = row['total'] as double;
    }
    return categoryCosts;
  }

  // 清空所有数据
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('expenses');
    await db.delete('energy_records');
    await db.delete('car_info');
  }
}