import '../../domain/entities/account.dart';
import '../datasources/local/account_dao.dart';

class AccountRepository {
  final AccountDao _dao;

  AccountRepository(this._dao);

  Future<void> addAccount(String id, String bankName, double initialBalance) async {
    final account = AccountEntity(id: id, bankName: bankName, currentBalance: initialBalance);
    await _dao.insert(account);
  }

  Future<List<AccountEntity>> getAllAccounts() => _dao.getAllAccounts();

  Future<void> updateBalance(String id, double amount, bool isCredit) async {
    final accounts = await _dao.getAllAccounts();
    final account = accounts.firstWhere((a) => a.id == id, orElse: () => AccountEntity(id: id, bankName: id, currentBalance: 0));
    
    final newBalance = isCredit ? account.currentBalance + amount : account.currentBalance - amount;
    
    // If account doesn't exist, we should probably insert it first or update it
    if (accounts.any((a) => a.id == id)) {
      await _dao.updateBalance(id, newBalance);
    } else {
      await addAccount(id, id, newBalance);
    }
  }
}
