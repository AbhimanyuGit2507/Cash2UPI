import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

abstract class AIProvider {
  Future<Map<String, dynamic>?> parseVoiceCommand(String command, String apiKey);

  String get systemPrompt => '''
Return valid JSON only. Never explain. Never add markdown. Never guess.
Unknown values: null

Transaction Types: customer_payment, personal_expense, business_expense, deposit, withdrawal, transfer, income, adjustment
Known Banks: ICICI, SBI, HDFC, Axis, PNB, BOB

Extract: type, bank, amount, cash_received, commission, category, notes, payment_mode
''';
}

class GroqProvider extends AIProvider {
  @override
  Future<Map<String, dynamic>?> parseVoiceCommand(String command, String apiKey) async {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer \$apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama3-8b-8192',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': command}
        ],
        'temperature': 0.0,
        'response_format': {'type': 'json_object'}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return jsonDecode(data['choices'][0]['message']['content']);
    }
    throw Exception('Groq API failed');
  }

  Future<String> transcribeAudio(String filePath, String apiKey) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions'),
    );
    request.headers['Authorization'] = 'Bearer \$apiKey';
    request.fields['model'] = 'whisper-large-v3';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      return data['text'];
    }
    throw Exception('Groq Whisper API failed');
  }
}

class MistralProvider extends AIProvider {
  @override
  Future<Map<String, dynamic>?> parseVoiceCommand(String command, String apiKey) async {
    final response = await http.post(
      Uri.parse('https://api.mistral.ai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer \$apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'mistral-small-latest',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': command}
        ],
        'temperature': 0.0,
        'response_format': {'type': 'json_object'}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return jsonDecode(data['choices'][0]['message']['content']);
    }
    throw Exception('Mistral API failed');
  }
}

class CerebrasProvider extends AIProvider {
  @override
  Future<Map<String, dynamic>?> parseVoiceCommand(String command, String apiKey) async {
    final response = await http.post(
      Uri.parse('https://api.cerebras.ai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer \$apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama3.1-8b',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': command}
        ],
        'temperature': 0.0,
        'response_format': {'type': 'json_object'}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return jsonDecode(data['choices'][0]['message']['content']);
    }
    throw Exception('Cerebras API failed');
  }
}

class AIOrchestrator {
  final GroqProvider groq = GroqProvider();
  final MistralProvider mistral = MistralProvider();
  final CerebrasProvider cerebras = CerebrasProvider();

  Future<Map<String, dynamic>?> parseCommand(String command, {
    required String groqKey,
    required String mistralKey,
    required String cerebrasKey,
  }) async {
    try {
      if (groqKey.isNotEmpty) {
        return await groq.parseVoiceCommand(command, groqKey);
      }
    } catch (e) {
      print('Groq failed: \$e');
    }

    try {
      if (mistralKey.isNotEmpty) {
        return await mistral.parseVoiceCommand(command, mistralKey);
      }
    } catch (e) {
      print('Mistral failed: \$e');
    }

    try {
      if (cerebrasKey.isNotEmpty) {
        return await cerebras.parseVoiceCommand(command, cerebrasKey);
      }
    } catch (e) {
      print('Cerebras failed: \$e');
    }

    throw Exception('All AI providers failed or no keys provided');
  }
}

class GoogleSttProvider {
  Future<String> transcribeAudio(String filePath, String apiKey, String primaryLang) async {
    final bytes = await File(filePath).readAsBytes();
    final base64Audio = base64Encode(bytes);
    
    String langCode = primaryLang.replaceAll('_', '-');
    List<String> altLangs = ['en-IN', 'hi-IN', 'bn-IN'];
    altLangs.remove(langCode);

    final response = await http.post(
      Uri.parse('https://speech.googleapis.com/v1/speech:recognize?key=\$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'config': {
          'encoding': 'LINEAR16',
          'sampleRateHertz': 16000,
          'languageCode': langCode,
          'alternativeLanguageCodes': altLangs,
        },
        'audio': {
          'content': base64Audio,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['alternatives'][0]['transcript'];
      }
      return '';
    }
    throw Exception('Google Cloud STT API failed: \${response.body}');
  }
}
