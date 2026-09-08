import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cash2upi_ledger.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sms (
        id TEXT PRIMARY KEY,
        sender TEXT,
        body TEXT,
        timestamp INTEGER,
        is_processed INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        date TEXT,
        time TEXT,
        type TEXT,
        bank TEXT,
        amount REAL,
        cash REAL,
        commission REAL,
        category TEXT,
        notes TEXT,
        source TEXT,
        status TEXT,
        is_synced INTEGER,
        user_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        bank_name TEXT,
        current_balance REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }
}
