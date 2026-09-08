import '../../domain/entities/sms_message.dart';
import '../datasources/local/sms_dao.dart';

class SmsRepository {
  final SmsDao _dao;

  SmsRepository(this._dao);

  Future<void> addSms(String sender, String body, int timestamp) async {
    final sms = SmsMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: sender,
      body: body,
      timestamp: timestamp,
      isProcessed: false,
    );
    await _dao.insert(sms);
  }

  Future<List<SmsMessageEntity>> getPendingSms() => _dao.getPendingSms();

  Future<void> markAsProcessed(String id) => _dao.markAsProcessed(id);
}
