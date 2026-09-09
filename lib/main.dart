import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:telephony/telephony.dart';
import 'core/database/database_helper.dart';
import 'data/datasources/local/transaction_dao.dart';
import 'data/datasources/local/setting_dao.dart';
import 'data/repositories/transaction_repository.dart';
import 'services/sync/sync_engine.dart';
import 'services/sms/sms_parser.dart';
import 'domain/entities/transaction.dart';
import 'services/notifications/notification_service.dart';
import 'presentation/screens/home/home_screen.dart';

@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) async {
  try {
    await DatabaseHelper().database;
    final parserEngine = SmsParserEngine();
    final parsed = parserEngine.parse(message.body ?? '', message.address ?? '');
    
    if (parsed != null) {
      final settingDao = SettingDao();
      final userName = await settingDao.getSetting('user_name') ?? 'Unknown';
      
      final tx = TransactionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now().toIso8601String().split('T').first,
        time: DateTime.now().toIso8601String().split('T').last.substring(0, 5),
        type: parsed.isCredit ? TransactionType.deposit : TransactionType.withdrawal,
        bank: parsed.bankName,
        amount: parsed.amount,
        cash: 0,
        commission: 0,
        category: 'Uncategorized',
        notes: message.body ?? '',
        source: TransactionSource.sms,
        status: TransactionStatus.pending,
        isSynced: false,
        userName: userName,
      );
      
      final txRepo = TransactionRepository(TransactionDao());
      await txRepo.addTransaction(tx);
    }
  } catch (e) {
    print('SMS Background processing failed: $e');
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await DatabaseHelper().database;
      final settingDao = SettingDao();
      final url = await settingDao.getSetting('apps_script_url');
      if (url == null || url.isEmpty) return Future.value(true);
      
      final txRepo = TransactionRepository(TransactionDao());
      final syncEngine = SyncEngine(txRepo, url);
      await syncEngine.syncPendingTransactions();
    } catch (e) {
      print('Background sync failed: $e');
    }
    return Future.value(true);
  });
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Add global error handler for Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('Flutter Error: ${details.exception}');
      // You can add more complex logging here if needed
    };
    
    try {
      await DatabaseHelper().database;
    } catch (e) {
      debugPrint('Database initialization failed: $e');
    }

    try {
      await NotificationService().init();
    } catch (e) {
      debugPrint('Notification Service initialization failed: $e');
    }
    
    try {
      Workmanager().initialize(
        callbackDispatcher,
      );
      Workmanager().registerPeriodicTask(
        "1",
        "syncTask",
        frequency: const Duration(minutes: 15),
      );
    } catch (e) {
      debugPrint('Workmanager initialization failed: $e');
    }
    
    try {
      final telephony = Telephony.instance;
      // We wrap this in a try-catch because if SMS permissions are not granted,
      // listenIncomingSms will throw an exception and crash the app on startup.
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          backgroundMessageHandler(message);
        },
        onBackgroundMessage: backgroundMessageHandler,
      );
    } catch (e) {
      debugPrint('Telephony listener initialization failed (likely missing permissions): $e');
    }
    
    runApp(const ProviderScope(child: Cash2UpiApp()));
  }, (error, stackTrace) {
    debugPrint('Zoned Guarded Error: $error');
  });
}

class Cash2UpiApp extends StatelessWidget {
  const Cash2UpiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cash2UPI Ledger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
