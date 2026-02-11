import 'dart:convert';
import 'package:frontend/models/news_item.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../repositories/word_repository.dart';
import 'package:hive/hive.dart'; // New import

class ApiService {
  // Singleton pattern
  ApiService._privateConstructor();
  static final ApiService _instance = ApiService._privateConstructor();
  static ApiService get instance => _instance;

  Box? _llmAnalysisCacheBox; // Declare the Hive box as nullable

  // Initialize Hive box
  Future<void> init() async {
    if (_llmAnalysisCacheBox == null || !_llmAnalysisCacheBox!.isOpen) {
      _llmAnalysisCacheBox = await Hive.openBox('llmAnalysisCache');
    }
  }

  Future<NewsItem?> fetchNews() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/latest-news'));

      if (response.statusCode == 200) {
        return NewsItem.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> lookupWordData(String word) async {
    // Check cache first
    final cachedData = await WordRepository.instance.getCachedWordData(word);
    if (cachedData != null) {
      return cachedData;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/define?word=$word'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await WordRepository.instance.cacheWordData(
          word,
          data,
        ); // save in cache
        return data;
      } else {
        return {"word": word, "parts": [], "feats": null};
      }
    } catch (e) {
      // offline also can't find
      return {"word": word, "parts": [], "feats": null};
    }
  }

  Future<Map<String, dynamic>> segmentSentences(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/segment-sentences'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to segment sentences: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error segmenting sentences: $e');
    }
  }

  Future<Map<String, dynamic>> translateText(
    String text, {
    String targetLanguage = 'EN-GB',
    String sourceLanguage = 'fi',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'target_language': targetLanguage,
          'source_language': sourceLanguage,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to translate text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error translating text: $e');
    }
  }

  Future<Map<String, dynamic>> llmAnalyzeText(String text) async {
    // Ensure the cache box is initialized
    if (_llmAnalysisCacheBox == null || !_llmAnalysisCacheBox!.isOpen) {
      await init();
    }

    // Check cache first
    if (_llmAnalysisCacheBox!.containsKey(text)) {
      return {'analysis_result': _llmAnalysisCacheBox!.get(text)};
    }

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/llm-analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // Store raw analysis_result string in cache
        await _llmAnalysisCacheBox!.put(text, result['analysis_result']);
        return result;
      } else {
        throw Exception(
          'Failed to perform LLM analysis: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error during LLM analysis: $e');
    }
  }
}
