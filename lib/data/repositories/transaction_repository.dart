import '../../domain/entities/transaction.dart';
import '../datasources/local/transaction_dao.dart';

class TransactionRepository {
  final TransactionDao _dao;

  TransactionRepository(this._dao);

  Future<void> addTransaction(TransactionEntity transaction) async {
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
