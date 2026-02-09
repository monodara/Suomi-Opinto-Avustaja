import 'package:hive/hive.dart';
import 'package:frontend/models/news_item.dart';
import 'package:frontend/models/saved_article.dart';

class ArticleRepository {
  // Singleton pattern
  ArticleRepository._privateConstructor();
  static final ArticleRepository _instance = ArticleRepository._privateConstructor();
  static ArticleRepository get instance => _instance;

  Future<Box<SavedArticle>> get savedArticlesBox async => await Hive.openBox<SavedArticle>('saved_articles');

  Future<bool> isArticleSaved(NewsItem article) async {
    final box = await savedArticlesBox;
    return box.values.any(
      (savedArticle) =>
          savedArticle.title == article.title &&
          savedArticle.date == article.date,
    );
  }

  Future<void> saveArticle(NewsItem article) async {
    final box = await savedArticlesBox;

    // Convert article content to string
    final contentBuffer = StringBuffer();
    for (var item in article.content) {
      contentBuffer.write(item['text']);
      contentBuffer.write('\n\n');
    }

    final savedArticle = SavedArticle(
      title: article.title,
      date: article.date,
      content: contentBuffer.toString(),
      image: article.image,
      savedDate: DateTime.now(),
      structuredContent: article.content
          .map(
            (item) => {
              'type': item['type'] ?? 'p',
              'text': item['text'] ?? '',
            },
          )
          .toList(),
    );

    await box.add(savedArticle);
  }
}
