import '../../data/repositories/transaction_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SyncEngine {
  final TransactionRepository _transactionRepository;
  final String _appsScriptUrl;

  SyncEngine(this._transactionRepository, this._appsScriptUrl);

  Future<bool> syncPendingTransactions() async {
    try {
      final unsynced = await _transactionRepository.getUnsyncedTransactions();
      if (unsynced.isEmpty) return true;

      for (var tx in unsynced) {
        final response = await http.post(
          Uri.parse(_appsScriptUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(tx.toMap()),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            await _transactionRepository.markAsSynced(tx.id);
          }
        }
      }
      return true;
    } catch (e) {
      print('Sync error: $e');
      return false;
    }
  }
}
