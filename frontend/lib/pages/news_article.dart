import 'package:flutter/material.dart';
import 'package:frontend/models/news_item.dart';
import 'package:frontend/models/saved_article.dart';
import 'package:frontend/utils/navigation_controller.dart';
import 'package:hive/hive.dart';
import '../widgets/clickable_words_text.dart';
import '../utils/aurora_gradient.dart';
import '../main.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsItem article;

  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF0A2463,
        ), // Use deep blue from aurora gradient
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Return to home
            NavigationController().returnToHome();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () async {
              try {
                final savedArticlesBox = await Hive.openBox<SavedArticle>(
                  'saved_articles',
                );

                // Check if article has already been saved
                final existingArticles = savedArticlesBox.values.toList();
                final isAlreadySaved = existingArticles.any(
                  (savedArticle) =>
                      savedArticle.title == article.title &&
                      savedArticle.date == article.date,
                );

                if (isAlreadySaved) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Artikkeli on jo tallennettu'),
                      ),
                    );
                  }
                  return;
                }

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

                await savedArticlesBox.add(savedArticle);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Artikkeli tallennettu')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Virhe artikkelin tallentamisessa'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    article.date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (article.image != null &&
                    (article.image?['url'] ?? '') != '')
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        (article.image?['url'] ?? '') as String,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (article.image != null &&
                    (article.image?['caption'] ?? '') != '')
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      (article.image?['caption'] ?? '') as String,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ...article.content.map<Widget>((item) {
                  final isHeader = item['type'] == 'h1' || item['type'] == 'h2';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: isHeader ? 22 : 16,
                        fontWeight: isHeader
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      child: ClickableWordsText(text: item['text'] ?? ''),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
