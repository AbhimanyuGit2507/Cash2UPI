import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../domain/entities/transaction.dart';

class TransactionDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(TransactionEntity transaction) async {
    final db = await _dbHelper.database;
    return await db.insert('transactions', transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TransactionEntity>> getAllTransactions() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC, time DESC');
    return maps.map((e) => TransactionEntity.fromMap(e)).toList();
  }

  Future<List<TransactionEntity>> getUnsyncedTransactions() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', where: 'is_synced = ?', whereArgs: [0]);
    return maps.map((e) => TransactionEntity.fromMap(e)).toList();
  }

  Future<int> update(TransactionEntity transaction) async {
    final db = await _dbHelper.database;
    return await db.update('transactions', transaction.toMap(), where: 'id = ?', whereArgs: [transaction.id]);
  }
}
