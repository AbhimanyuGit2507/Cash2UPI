import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/transaction_dao.dart';
import '../../data/datasources/local/account_dao.dart';
import '../../data/datasources/local/sms_dao.dart';
import '../../data/datasources/local/setting_dao.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/sms_repository.dart';
import '../../services/sms/sms_parser.dart';
import '../../services/ai/ai_providers.dart';

final transactionDaoProvider = Provider((ref) => TransactionDao());
final accountDaoProvider = Provider((ref) => AccountDao());
final smsDaoProvider = Provider((ref) => SmsDao());
final settingDaoProvider = Provider((ref) => SettingDao());

final transactionRepositoryProvider = Provider((ref) => TransactionRepository(ref.watch(transactionDaoProvider)));
final accountRepositoryProvider = Provider((ref) => AccountRepository(ref.watch(accountDaoProvider)));
final smsRepositoryProvider = Provider((ref) => SmsRepository(ref.watch(smsDaoProvider)));

final smsParserEngineProvider = Provider((ref) => SmsParserEngine());
final aiOrchestratorProvider = Provider((ref) => AIOrchestrator());

final pendingSmsProvider = FutureProvider((ref) {
  final repo = ref.watch(smsRepositoryProvider);
  return repo.getPendingSms();
});

final allTransactionsProvider = FutureProvider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getAllTransactions();
});

final allAccountsProvider = FutureProvider((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.getAllAccounts();
});
