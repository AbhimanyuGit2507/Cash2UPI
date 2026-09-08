import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../domain/entities/sms_message.dart';

class SmsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(SmsMessageEntity sms) async {
    final db = await _dbHelper.database;
    return await db.insert('sms', sms.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SmsMessageEntity>> getPendingSms() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('sms', where: 'is_processed = ?', whereArgs: [0], orderBy: 'timestamp DESC');
    return maps.map((e) => SmsMessageEntity.fromMap(e)).toList();
  }

  Future<int> markAsProcessed(String id) async {
    final db = await _dbHelper.database;
    return await db.update('sms', {'is_processed': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
