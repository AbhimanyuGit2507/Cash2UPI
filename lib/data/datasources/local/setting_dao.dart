import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../domain/entities/app_setting.dart';

class SettingDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertOrUpdate(AppSettingEntity setting) async {
    final db = await _dbHelper.database;
    return await db.insert('settings', setting.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  Future<void> saveSetting(String key, String value) async {
    await insertOrUpdate(AppSettingEntity(key: key, value: value));
  }
}
