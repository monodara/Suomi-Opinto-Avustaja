import 'package:hive/hive.dart';
import 'package:frontend/models/saved_word.dart';
import 'dart:math';

class WordRepository {
  // Singleton pattern
  WordRepository._privateConstructor();
  static final WordRepository _instance = WordRepository._privateConstructor();
  static WordRepository get instance => _instance;

  Future<Box<dynamic>> get wordCacheBox async => await Hive.openBox('word_cache');
  Future<Box<SavedWord>> get wordbookBox async => await Hive.openBox<SavedWord>('wordbook');

  Future<Map<String, dynamic>?> getCachedWordData(String word) async {
    final box = await wordCacheBox;
    if (box.containsKey(word)) {
      return Map<String, dynamic>.from(box.get(word));
    }
    return null;
  }

  Future<void> cacheWordData(String word, Map<String, dynamic> data) async {
    final box = await wordCacheBox;
    await box.put(word, data);
  }

  Future<bool> isWordSaved(String word) async {
    final box = await wordbookBox;
    return box.values.any((w) => w.word == word);
  }

  Future<void> saveWord(String word, String pos, List<dynamic> meanings) async {
    final box = await wordbookBox;
    final definition = meanings.isNotEmpty
        ? meanings[0]['definition'] ?? ''
        : '';
    final example = meanings.isNotEmpty ? meanings[0]['example'] ?? '' : '';
    final savedWord = SavedWord(
      word: word,
      pos: pos,
      definition: definition,
      example: example,
    );
    await box.add(savedWord);
  }

  Future<void> deleteWord(String word) async {
    final box = await wordbookBox;
    final keyToDelete = box.keys.firstWhere(
      (key) => box.get(key)?.word == word,
      orElse: () => null,
    );
    if (keyToDelete != null) {
      await box.delete(keyToDelete);
    }
  }

  Future<List<SavedWord>> getRandomWords(int count) async {
    final box = await wordbookBox;
    final allWords = box.values.toList();
    if (allWords.length <= count) {
      return allWords;
    }

    final random = Random();
    final selectedWords = <SavedWord>[];
    final indices = <int>{};

    while (selectedWords.length < count) {
      final index = random.nextInt(allWords.length);
      if (!indices.contains(index)) {
        selectedWords.add(allWords[index]);
        indices.add(index);
      }
    }
    return selectedWords;
  }
}
