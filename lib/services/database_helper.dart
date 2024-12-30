import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/customer.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const String dbName = 'customers.db';
  static const int _version = 2;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbName);
    return _database!;
  }

  Future<String> get _dbPath async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return join(dbFolder.path, dbName);
  }

  Future<Database> _initDB(String filePath) async {
    final path = await _dbPath;
    
    await deleteDatabase();
    
    return await openDatabase(
      path,
      version: _version,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phone TEXT NOT NULL,
        batteryType TEXT NOT NULL,
        deviceName TEXT NOT NULL,
        notes TEXT NOT NULL,
        isDoubleSided INTEGER NOT NULL,
        dateAdded TEXT NOT NULL,
        batteryChangeDate TEXT,
        batteryReminderMonths INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE customers RENAME TO customers_old');
      
      await _createDB(db, newVersion);
      
      await db.execute('''
        INSERT INTO customers (
          id, firstName, lastName, phone, batteryType, deviceName, 
          notes, isDoubleSided, dateAdded
        )
        SELECT 
          id, firstName, lastName, phone, batteryType, deviceName,
          notes, isDoubleSided, dateAdded
        FROM customers_old
      ''');
      
      await db.execute('DROP TABLE customers_old');
    }
  }

  Future<void> deleteDatabase() async {
    final path = await _dbPath;
    await _database?.close();
    _database = null;
    await databaseFactory.deleteDatabase(path);
  }

  Future<Customer> create(Customer customer) async {
    final db = await instance.database;
    final id = await db.insert('customers', customer.toMap());
    return customer;
  }

  Future<Customer?> readCustomer(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Customer>> readAllCustomers() async {
    final db = await instance.database;
    final result = await db.query('customers', orderBy: 'dateAdded DESC');
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<int> update(Customer customer) async {
    final db = await instance.database;
    return db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> getDatabaseSize() async {
    final path = await _dbPath;
    final file = File(path);
    if (!await file.exists()) return '0 KB';

    final bytes = await file.length();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<String> backupDatabase() async {
    final dbPath = await _dbPath;
    final backupFolder = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = join(backupFolder.path, 'customers_backup_$timestamp.db');

    try {
      File(dbPath).copySync(backupPath);
      return backupPath;
    } catch (e) {
      throw Exception('Yedekleme sırasında hata oluştu: $e');
    }
  }

  Future<void> restoreDatabase(String backupPath) async {
    final dbPath = await _dbPath;
    try {
      await _database?.close();
      _database = null;

      File(backupPath).copySync(dbPath);
    } catch (e) {
      throw Exception('Geri yükleme sırasında hata oluştu: $e');
    }
  }
} 