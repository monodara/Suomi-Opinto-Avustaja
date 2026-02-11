import 'dart:convert';
import 'package:frontend/models/news_item.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../repositories/word_repository.dart';

class ApiService {
  // Singleton pattern
  ApiService._privateConstructor();
  static final ApiService _instance = ApiService._privateConstructor();
  static ApiService get instance => _instance;

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
        await WordRepository.instance.cacheWordData(word, data); // save in cache
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
}
