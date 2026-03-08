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
    
    // Initialize SRS fields when saving a new word
    final savedWord = SavedWord(
      word: word,
      pos: pos,
      definition: definition,
      example: example,
      dateAdded: DateTime.now(),
      nextReviewDate: DateTime.now(), // Initially due today
      interval: 0,
      repetitions: 0,
      easeFactor: 2.5,
      isLearned: false,
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

  Future<List<SavedWord>> getWordsDueForReview(int count) async {
    final box = await wordbookBox;
    final allWords = box.values.toList();
    final now = DateTime.now();

    // Filter words that are due for review today or in the past
    final dueWords = allWords.where((word) =>
        word.nextReviewDate.isBefore(now) || word.nextReviewDate.isAtSameMomentAs(now)
    ).toList();

    // Sort due words by nextReviewDate (oldest first)
    dueWords.sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));

    if (dueWords.length >= count) {
      return dueWords.sublist(0, count);
    } else {
      // If not enough due words, fill with other unlearned words
      final otherWords = allWords.where((word) =>
          !dueWords.contains(word) && !word.isLearned
      ).toList();
      otherWords.shuffle(); // Shuffle to get some variety

      final wordsToReturn = [...dueWords];
      for (int i = 0; wordsToReturn.length < count && i < otherWords.length; i++) {
        wordsToReturn.add(otherWords[i]);
      }
      return wordsToReturn;
    }
  }

  // Basic SM-2 like algorithm for updating SRS parameters
  Future<void> updateWordSRS(SavedWord word, int quality) async {
    final box = await wordbookBox;
    final index = box.values.toList().indexOf(word);

    if (index == -1) return; // Word not found

    if (quality < 3) {
      // Incorrect recall
      word.repetitions = 0;
      word.interval = 1;
      word.isLearned = false;
      word.lastLearnedDate = null; // Clear last learned date if not learned
    } else {
      // Correct recall
      word.repetitions++;
      word.easeFactor = word.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (word.easeFactor < 1.3) word.easeFactor = 1.3; // Minimum ease factor

      if (word.repetitions == 1) {
        word.interval = 1;
      } else if (word.repetitions == 2) {
        word.interval = 6;
      } else {
        word.interval = (word.interval * word.easeFactor).round();
      }
      word.isLearned = true; // Mark as learned if successfully reviewed
      word.lastLearnedDate = DateTime.now(); // Set last learned date
    }

    word.nextReviewDate = DateTime.now().add(Duration(days: word.interval));
    await box.putAt(index, word);
  }

  Future<int> getWordsLearnedToday() async {
    final box = await wordbookBox;
    final allWords = box.values.toList();
    final now = DateTime.now();

    return allWords.where((word) =>
        word.isLearned &&
        word.lastLearnedDate != null && // Ensure lastLearnedDate is not null
        word.lastLearnedDate!.year == now.year &&
        word.lastLearnedDate!.month == now.month &&
        word.lastLearnedDate!.day == now.day
    ).length;
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
