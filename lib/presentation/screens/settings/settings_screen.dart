import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _userNameController = TextEditingController();
  final _groqKeyController = TextEditingController();
  final _googleKeyController = TextEditingController();
  final _appsScriptUrlController = TextEditingController();
  
  String _activeSttEngine = 'native';
  String _nativeSttLanguage = 'en_IN';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingDao = ref.read(settingDaoProvider);
    final userName = await settingDao.getSetting('user_name') ?? '';
    final groqKey = await settingDao.getSetting('groq_api_key') ?? '';
    final googleKey = await settingDao.getSetting('google_stt_api_key') ?? '';
    final url = await settingDao.getSetting('apps_script_url') ?? '';
    final engine = await settingDao.getSetting('active_stt_engine') ?? 'native';
    final sttLang = await settingDao.getSetting('native_stt_language') ?? 'en_IN';

    setState(() {
      _userNameController.text = userName;
      _groqKeyController.text = groqKey;
      _googleKeyController.text = googleKey;
      _appsScriptUrlController.text = url;
      _activeSttEngine = engine;
      _nativeSttLanguage = sttLang;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final settingDao = ref.read(settingDaoProvider);
    await settingDao.saveSetting('user_name', _userNameController.text);
    await settingDao.saveSetting('groq_api_key', _groqKeyController.text);
    await settingDao.saveSetting('google_stt_api_key', _googleKeyController.text);
    await settingDao.saveSetting('apps_script_url', _appsScriptUrlController.text);
    await settingDao.saveSetting('active_stt_engine', _activeSttEngine);
    await settingDao.saveSetting('native_stt_language', _nativeSttLanguage);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Multi-User Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'User Name (e.g. Mobile 1)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Voice-to-Text Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _activeSttEngine,
              decoration: const InputDecoration(
                labelText: 'Active STT Engine',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'native', child: Text('Native (On-Device)')),
                DropdownMenuItem(value: 'groq', child: Text('Groq Whisper API')),
                DropdownMenuItem(value: 'google', child: Text('Google Cloud API')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _activeSttEngine = val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _nativeSttLanguage,
              decoration: const InputDecoration(
                labelText: 'Speech Language',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'en_IN', child: Text('English (India)')),
                DropdownMenuItem(value: 'hi_IN', child: Text('Hindi (India)')),
                DropdownMenuItem(value: 'bn_IN', child: Text('Bengali (India)')),
              ],
              onChanged: _activeSttEngine == 'native' ? (val) {
                if (val != null) setState(() => _nativeSttLanguage = val);
              } : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'API Keys',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _groqKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Groq API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _googleKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Google Cloud STT API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sync Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _appsScriptUrlController,
              decoration: const InputDecoration(
                labelText: 'Apps Script URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            )
          ],
        ),
      ),
    );
  }
}
