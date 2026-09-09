import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../manual_entry/manual_entry_screen.dart';
import '../voice_entry/voice_entry_screen.dart';
import '../pending/pending_screen.dart';
import '../settings/settings_screen.dart';
import '../../../core/providers/app_providers.dart';
import '../../../services/sync/sync_engine.dart';

import 'package:telephony/telephony.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initPermissionsAndListener();
  }

  Future<void> _initPermissionsAndListener() async {
    try {
      final telephony = Telephony.instance;
      final granted = await telephony.requestPhoneAndSmsPermissions;
      
      if (granted == true) {
        // Safe to listen now
        telephony.listenIncomingSms(
          onNewMessage: (SmsMessage message) {
            // We can handle foreground messages here if needed or let background handler do it
          },
          onBackgroundMessage: null, // Usually handled by main.dart, but we can re-register if needed
        );
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash2UPI Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final settingDao = ref.read(settingDaoProvider);
              final url = await settingDao.getSetting('apps_script_url');
              if (url != null && url.isNotEmpty) {
                 final repo = ref.read(transactionRepositoryProvider);
                 final syncEngine = SyncEngine(repo, url);
                 final success = await syncEngine.syncPendingTransactions();
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Sync completed' : 'Sync failed')));
                 }
              } else if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please set Apps Script URL in Settings')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Pending Classification'),
              subtitle: const Text('Transactions waiting to be categorized'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingScreen()));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'voice',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceEntryScreen()));
            },
            child: const Icon(Icons.mic),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'manual',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualEntryScreen()));
            },
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
