import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:programming_learn_app/core/constants/api_constants.dart';
import 'package:programming_learn_app/core/exceptions/app_exception.dart';
import 'package:programming_learn_app/data/local/fallback_content.dart';

class GroqService {
  GroqService({http.Client? client}) : _client = client ?? http.Client();

  final String _apiKey = kGroqApiKey;
  final String _baseUrl = kGroqBaseUrl;
  final http.Client _client;

  Box<dynamic> get _cacheBox => Hive.box<dynamic>('ai_cache_box');

  String _cacheKey(String prompt, String model) {
    final bytes = utf8.encode('$model:$prompt');
    return md5.convert(bytes).toString();
  }

  String? _getCached(String key) {
    final value = _cacheBox.get(key);
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  Future<void> _saveCache(String key, String response) async {
    await _cacheBox.put(key, response);
  }

  Future<bool> _isOffline() async {
    final dynamic result = await Connectivity().checkConnectivity();

    if (result is ConnectivityResult) {
      return result == ConnectivityResult.none;
    }

    if (result is List<ConnectivityResult>) {
      return result.isEmpty || result.every((entry) => entry == ConnectivityResult.none);
    }

    return false;
  }

  Future<String> complete({
    required String prompt,
    required String model,
    int maxTokens = 1024,
    double temperature = 0.7,
    bool useCache = true,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw const AuthException('Missing Groq API key. Pass it with --dart-define=GROQ_API_KEY=...');
    }

    final key = _cacheKey(prompt, model);

    if (useCache) {
      final cached = _getCached(key);
      if (cached != null) {
        return cached;
      }
    }

    if (await _isOffline()) {
      return _fallbackTextForPrompt(prompt);
    }

    final headers = <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer $_apiKey',
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'max_tokens': maxTokens,
      'temperature': temperature,
      'stream': false,
    });

    try {
      final response = await _client
          .post(Uri.parse(_baseUrl), headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401) {
        throw const AuthException();
      }
      if (response.statusCode == 429) {
        throw const RateLimitException();
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Groq request failed: HTTP ${response.statusCode}.');
      }

      final decoded = jsonDecode(response.body);
      final content = _extractMessageContent(decoded);
      if (content == null || content.trim().isEmpty) {
        throw const ApiException('Groq returned an empty response.');
      }

      await _saveCache(key, content);
      return content;
    } on SocketException {
      return _fallbackTextForPrompt(prompt);
    } on async.TimeoutException {
      return _fallbackTextForPrompt(prompt);
    }
  }

  Stream<String> streamComplete({
    required String prompt,
    required String model,
    int maxTokens = 2048,
  }) async* {
    if (_apiKey.trim().isEmpty) {
      throw const AuthException('Missing Groq API key. Pass it with --dart-define=GROQ_API_KEY=...');
    }

    final key = _cacheKey(prompt, model);
    final cached = _getCached(key);
    if (cached != null) {
      yield cached;
      return;
    }

    if (await _isOffline()) {
      final fallback = _fallbackTextForPrompt(prompt);
      if (fallback.isNotEmpty) {
        yield fallback;
      }
      return;
    }

    final request = http.Request('POST', Uri.parse(_baseUrl))
      ..headers.addAll({
        HttpHeaders.authorizationHeader: 'Bearer $_apiKey',
        HttpHeaders.contentTypeHeader: 'application/json',
      })
      ..body = jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': maxTokens,
        'stream': true,
      });

    final responseBuffer = StringBuffer();

    try {
      final response = await _client.send(request).timeout(const Duration(seconds: 30));

      if (response.statusCode == 401) {
        throw const AuthException();
      }
      if (response.statusCode == 429) {
        throw const RateLimitException();
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Groq streaming failed: HTTP ${response.statusCode}.');
      }

      await for (final line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (!line.startsWith('data:')) {
          continue;
        }

        final raw = line.substring(5).trim();
        if (raw.isEmpty || raw == '[DONE]') {
          continue;
        }

        try {
          final payload = jsonDecode(raw) as Map<String, dynamic>;
          final choices = payload['choices'];
          if (choices is List && choices.isNotEmpty) {
            final firstChoice = choices.first;
            if (firstChoice is Map<String, dynamic>) {
              final delta = firstChoice['delta'];
              if (delta is Map<String, dynamic>) {
                final chunk = delta['content'];
                if (chunk is String && chunk.isNotEmpty) {
                  responseBuffer.write(chunk);
                  yield chunk;
                }
              }
            }
          }
        } catch (_) {
          // Ignore malformed event chunks and continue consuming stream.
        }
      }

      final fullResponse = responseBuffer.toString().trim();
      if (fullResponse.isNotEmpty) {
        await _saveCache(key, fullResponse);
      }
    } on SocketException {
      final fallback = _fallbackTextForPrompt(prompt);
      if (fallback.isNotEmpty) {
        yield fallback;
      }
    } on async.TimeoutException {
      final fallback = _fallbackTextForPrompt(prompt);
      if (fallback.isNotEmpty) {
        yield fallback;
      }
    }
  }

  Future<Map<String, dynamic>> completeJson({
    required String prompt,
    required String model,
    int maxTokens = 2048,
  }) async {
    final jsonPrompt =
        '$prompt\n\nRespond ONLY with valid JSON. No markdown, no explanation.';

    String firstTry;
    try {
      firstTry = await complete(
        prompt: jsonPrompt,
        model: model,
        maxTokens: maxTokens,
        useCache: false,
      );
    } on OfflineException {
      return _fallbackJsonForPrompt(prompt);
    } on TimeoutException {
      return _fallbackJsonForPrompt(prompt);
    }

    final parsedFirst = _tryParseJson(firstTry);
    if (parsedFirst != null) {
      return parsedFirst;
    }

    final strictPrompt =
        '$prompt\n\nReturn strict JSON only. Do not include code fences, markdown, or prose. The first character must be "{" and the last must be "}".';

    String secondTry;
    try {
      secondTry = await complete(
        prompt: strictPrompt,
        model: model,
        maxTokens: maxTokens,
        useCache: false,
      );
    } on OfflineException {
      return _fallbackJsonForPrompt(prompt);
    } on TimeoutException {
      return _fallbackJsonForPrompt(prompt);
    }

    final parsedSecond = _tryParseJson(secondTry);
    if (parsedSecond != null) {
      return parsedSecond;
    }

    return _fallbackJsonForPrompt(prompt);
  }

  String _fallbackTextForPrompt(String prompt) {
    final lower = prompt.toLowerCase();

    if (lower.contains('hint')) {
      return 'Try breaking the problem into smaller steps and explain your reasoning clearly.';
    }

    if (lower.contains('interview')) {
      return 'Offline mode: using fallback interview content.';
    }

    if (lower.contains('roadmap')) {
      return 'Offline mode: loading your saved roadmap template.';
    }

    return 'Offline mode active. Showing saved content.';
  }

  Map<String, dynamic> _fallbackJsonForPrompt(String prompt) {
    final lower = prompt.toLowerCase();

    if (lower.contains('interview')) {
      return {
        'questions': kFallbackInterviewQuestions,
      };
    }

    if (lower.contains('full stack') || lower.contains('fullstack')) {
      return kFallbackDomainRoadmaps.firstWhere(
        (entry) => entry['domainId'] == 'fullstack',
        orElse: () => kFallbackDomainRoadmaps.first,
      );
    }

    if (lower.contains('data analyst')) {
      return kFallbackDomainRoadmaps.firstWhere(
        (entry) => entry['domainId'] == 'data_analyst',
        orElse: () => kFallbackDomainRoadmaps.first,
      );
    }

    if (lower.contains('machine learning') || lower.contains('ml/ai') || lower.contains('ai')) {
      return kFallbackDomainRoadmaps.firstWhere(
        (entry) => entry['domainId'] == 'ml_ai',
        orElse: () => kFallbackDomainRoadmaps.first,
      );
    }

    if (lower.contains('android') || lower.contains('mobile')) {
      return kFallbackDomainRoadmaps.firstWhere(
        (entry) => entry['domainId'] == 'android_dev',
        orElse: () => kFallbackDomainRoadmaps.first,
      );
    }

    if (lower.contains('cyber') || lower.contains('security')) {
      return kFallbackDomainRoadmaps.firstWhere(
        (entry) => entry['domainId'] == 'cybersecurity',
        orElse: () => kFallbackDomainRoadmaps.first,
      );
    }

    return kFallbackPythonRoadmap;
  }

  Map<String, dynamic>? _tryParseJson(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractMessageContent(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    final choices = payload['choices'];
    if (choices is! List || choices.isEmpty) {
      return null;
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      return null;
    }

    final message = firstChoice['message'];
    if (message is! Map<String, dynamic>) {
      return null;
    }

    final content = message['content'];
    return content is String ? content : null;
  }

  void dispose() {
    _client.close();
  }
}
