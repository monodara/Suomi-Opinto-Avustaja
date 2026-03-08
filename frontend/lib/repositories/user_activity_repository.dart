import 'package:hive/hive.dart';
import 'package:frontend/models/news_item.dart'; // Assuming NewsItem is needed to get content
import 'package:frontend/models/saved_article.dart'; // Assuming SavedArticle might be used

part 'user_activity_repository.g.dart'; // New part directive

// This model will store information about a viewed article
@HiveType(typeId: 4) // Assign a unique typeId
class ViewedArticle extends HiveObject {
  @HiveField(0)
  String articleId; // A unique identifier for the article (e.g., its title or a hash)

  @HiveField(1)
  DateTime viewDate;

  @HiveField(2)
  List<Map<String, dynamic>> structuredContent; // Store content to count sentences

  ViewedArticle({
    required this.articleId,
    required this.viewDate,
    required this.structuredContent,
  });
}

// New Hive model for practiced sentences
@HiveType(typeId: 6) // Assign a unique typeId
class PracticedSentence extends HiveObject {
  @HiveField(0)
  String sentence;

  @HiveField(1)
  DateTime practiceDate;

  @HiveField(2)
  double similarityScore;

  PracticedSentence({
    required this.sentence,
    required this.practiceDate,
    required this.similarityScore,
  });
}

class UserActivityRepository {
  // Singleton pattern
  UserActivityRepository._privateConstructor();
  static final UserActivityRepository _instance = UserActivityRepository._privateConstructor();
  static UserActivityRepository get instance => _instance;

  Future<Box<ViewedArticle>> get viewedArticlesBox async => await Hive.openBox<ViewedArticle>('viewed_articles');
  Future<Box<PracticedSentence>> get practicedSentencesBox async => await Hive.openBox<PracticedSentence>('practiced_sentences');

  Future<void> recordArticleView(NewsItem article) async {
    final box = await viewedArticlesBox;
    final now = DateTime.now();

    // Check if this article has already been viewed today
    final alreadyViewedToday = box.values.any((viewed) =>
        viewed.articleId == article.title && // Using title as a simple ID for now
        viewed.viewDate.year == now.year &&
        viewed.viewDate.month == now.month &&
        viewed.viewDate.day == now.day
    );

    if (!alreadyViewedToday) {
      final viewedArticle = ViewedArticle(
        articleId: article.title, // Using title as a simple ID
        viewDate: now,
        structuredContent: article.content,
      );
      await box.add(viewedArticle);
    }
  }

  Future<void> recordPracticedSentence(String sentence, double similarityScore) async {
    final box = await practicedSentencesBox;
    final now = DateTime.now();

    // Only record if similarity score is satisfying (e.g., >= 0.7)
    if (similarityScore >= 0.7) {
      // Check if this exact sentence has already been successfully practiced today
      final alreadyPracticedToday = box.values.any((practiced) =>
          practiced.sentence == sentence &&
          practiced.practiceDate.year == now.year &&
          practiced.practiceDate.month == now.month &&
          practiced.practiceDate.day == now.day &&
          practiced.similarityScore >= 0.7 // Only count if it was a satisfying score
      );

      if (!alreadyPracticedToday) {
        final practicedSentence = PracticedSentence(
          sentence: sentence,
          practiceDate: now,
          similarityScore: similarityScore,
        );
        await box.add(practicedSentence);
      }
    }
  }

  Future<int> getSentencesReadToday() async {
    final box = await practicedSentencesBox;
    final now = DateTime.now();

    // Count unique sentences practiced today with a satisfying score
    return box.values.where((practiced) =>
        practiced.practiceDate.year == now.year &&
        practiced.practiceDate.month == now.month &&
        practiced.practiceDate.day == now.day &&
        practiced.similarityScore >= 0.7
    ).length;
  }
}
