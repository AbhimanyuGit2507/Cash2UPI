import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/providers/app_providers.dart';
import '../../../domain/entities/transaction.dart';
import '../../../services/ai/ai_providers.dart';

class VoiceEntryScreen extends ConsumerStatefulWidget {
  const VoiceEntryScreen({super.key});

  @override
  ConsumerState<VoiceEntryScreen> createState() => _VoiceEntryScreenState();
}

class _VoiceEntryScreenState extends ConsumerState<VoiceEntryScreen> {
  final _audioRecorder = AudioRecorder();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isRecording = false;
  bool _isProcessing = false;
  String _text = 'Hold mic to speak your transaction';
  
  String _activeSttEngine = 'native';
  String _nativeSttLanguage = 'en_IN';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingDao = ref.read(settingDaoProvider);
    final engine = await settingDao.getSetting('active_stt_engine');
    final lang = await settingDao.getSetting('native_stt_language');
    if (mounted) {
      setState(() {
        _activeSttEngine = engine ?? 'native';
        _nativeSttLanguage = lang ?? 'en_IN';
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _text = 'Listening...';
    });
    
    if (_activeSttEngine == 'groq' || _activeSttEngine == 'google') {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '\${dir.path}/recording.wav';
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ), 
          path: path
        );
      }
    } else {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: \$val'),
        onError: (val) => print('onError: \$val'),
      );
      if (available) {
        _speech.listen(
          localeId: _nativeSttLanguage,
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
      _isProcessing = true;
      if (_activeSttEngine != 'native') {
        _text = 'Processing audio...';
      } else {
        _text = 'Parsing details...';
      }
    });

    if (_activeSttEngine != 'native') {
      final path = await _audioRecorder.stop();
      if (path != null) {
        if (_activeSttEngine == 'groq') {
          await _processGroqAudio(path);
        } else if (_activeSttEngine == 'google') {
          await _processGoogleAudio(path);
        }
      }
    } else {
      _speech.stop();
      await Future.delayed(const Duration(milliseconds: 500));
      await _parseTransaction(_text);
    }
  }

  Future<void> _processGroqAudio(String path) async {
    try {
      final settingDao = ref.read(settingDaoProvider);
      final groqKey = await settingDao.getSetting('groq_api_key');
      if (groqKey == null || groqKey.isEmpty) {
        _handleFallback('Groq API Key not found in Settings.');
        return;
      }

      final aiOrchestrator = ref.read(aiOrchestratorProvider);
      setState(() => _text = 'Transcribing with Groq...');
      
      final transcription = await aiOrchestrator.groq.transcribeAudio(path, groqKey);
      setState(() => _text = transcription);
      
      await _parseTransaction(transcription);
    } catch (e) {
      _handleFallback('Groq API failed. Falling back to Native STT. Please tap mic and speak again.');
    }
  }

  Future<void> _processGoogleAudio(String path) async {
    try {
      final settingDao = ref.read(settingDaoProvider);
      final googleKey = await settingDao.getSetting('google_stt_api_key');
      if (googleKey == null || googleKey.isEmpty) {
        _handleFallback('Google Cloud API Key not found in Settings.');
        return;
      }

      setState(() => _text = 'Transcribing with Google Cloud...');
      final googleProvider = GoogleSttProvider();
      final transcription = await googleProvider.transcribeAudio(path, googleKey, _nativeSttLanguage);
      
      setState(() => _text = transcription);
      await _parseTransaction(transcription);
    } catch (e) {
      _handleFallback('Google Cloud STT failed. Falling back to Native STT. Please tap mic and speak again.');
    }
  }

  void _handleFallback(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _activeSttEngine = 'native'; // Fallback for the rest of this session
        _isProcessing = false;
        _text = 'Hold mic to speak again (Native)';
      });
    }
  }

  Future<void> _parseTransaction(String transcription) async {
    if (transcription.isEmpty || transcription == 'Listening...' || transcription == 'Hold mic to speak your transaction') {
       setState(() {
          _text = 'No speech detected.';
          _isProcessing = false;
        });
       return;
    }
    
    try {
      final settingDao = ref.read(settingDaoProvider);
      final groqKey = await settingDao.getSetting('groq_api_key');
      final userName = await settingDao.getSetting('user_name') ?? 'Unknown';
      
      if (groqKey == null || groqKey.isEmpty) {
         setState(() {
          _text = 'Please set Groq API Key to parse the transaction details.';
          _isProcessing = false;
        });
        return;
      }

      final aiOrchestrator = ref.read(aiOrchestratorProvider);
      setState(() => _text = 'Extracting transaction data...');
      final parsed = await aiOrchestrator.parseCommand(transcription, groqKey: groqKey, mistralKey: '', cerebrasKey: '');
      
      if (parsed != null) {
        final tx = TransactionEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now().toIso8601String().split('T').first,
          time: DateTime.now().toIso8601String().split('T').last.substring(0, 5),
          type: TransactionType.values.firstWhere((e) => e.name == parsed['type'], orElse: () => TransactionType.unknown),
          bank: parsed['bank'] ?? 'Cash',
          amount: (parsed['amount'] ?? 0).toDouble(),
          cash: (parsed['cash_received'] ?? 0).toDouble(),
          commission: (parsed['commission'] ?? 0).toDouble(),
          category: parsed['category'] ?? '',
          notes: parsed['notes'] ?? transcription,
          source: TransactionSource.voice,
          status: TransactionStatus.pending,
          isSynced: false,
          userName: userName,
        );
        await ref.read(transactionRepositoryProvider).addTransaction(tx);
        setState(() {
          _text = 'Transaction saved successfully!';
          _isProcessing = false;
        });
      } else {
        setState(() {
          _text = 'Could not parse transaction from speech.';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _text = 'Parsing Error: \$e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Entry')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_activeSttEngine == 'groq')
                const Chip(label: Text('Groq Whisper Engine'), backgroundColor: Colors.amber)
              else if (_activeSttEngine == 'google')
                const Chip(label: Text('Google Cloud STT Engine'), backgroundColor: Colors.greenAccent)
              else
                Chip(label: Text('Native Engine (\$_nativeSttLanguage)'), backgroundColor: Colors.blue[100]),
              const SizedBox(height: 20),
              _isProcessing 
                  ? const CircularProgressIndicator()
                  : Text(_text, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTapDown: (_) => _startRecording(),
        onTapUp: (_) => _stopRecording(),
        onTapCancel: () => _stopRecording(),
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(_isRecording ? Icons.mic : Icons.mic_none, color: _isRecording ? Colors.red : null),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
