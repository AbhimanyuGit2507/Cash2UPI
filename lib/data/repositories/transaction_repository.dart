import '../../domain/entities/transaction.dart';
import '../datasources/local/transaction_dao.dart';
import 'package:uuid/uuid.dart';

class TransactionRepository {
  final TransactionDao _dao;

  TransactionRepository(this._dao);

  Future<void> addTransaction({
    required TransactionType type,
    required String bank,
    required double amount,
    required double cash,
    required double commission,
    required String category,
    required String notes,
    required TransactionSource source,
    required TransactionStatus status,
  }) async {
    final now = DateTime.now();
    final transaction = TransactionEntity(
      id: const Uuid().v4(),
      date: "\${now.year}-\${now.month.toString().padLeft(2, '0')}-\${now.day.toString().padLeft(2, '0')}",
      time: "\${now.hour.toString().padLeft(2, '0')}:\${now.minute.toString().padLeft(2, '0')}",
      type: type,
      bank: bank,
      amount: amount,
      cash: cash,
      commission: commission,
      category: category,
      notes: notes,
      source: source,
      status: status,
      isSynced: false,
    );
    await _dao.insert(transaction);
  }

  Future<List<TransactionEntity>> getAllTransactions() => _dao.getAllTransactions();

  Future<void> markAsSynced(String id) async {
    final transactions = await _dao.getAllTransactions();
    final index = transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final updated = transactions[index].copyWith(isSynced: true);
      await _dao.update(updated);
    }
  }

  Future<List<TransactionEntity>> getUnsyncedTransactions() => _dao.getUnsyncedTransactions();
}
