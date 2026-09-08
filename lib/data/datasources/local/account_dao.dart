import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../domain/entities/account.dart';

class AccountDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(AccountEntity account) async {
    final db = await _dbHelper.database;
    return await db.insert('accounts', account.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AccountEntity>> getAllAccounts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    return maps.map((e) => AccountEntity.fromMap(e)).toList();
  }

  Future<int> updateBalance(String id, double newBalance) async {
    final db = await _dbHelper.database;
    return await db.update('accounts', {'current_balance': newBalance}, where: 'id = ?', whereArgs: [id]);
  }
}
