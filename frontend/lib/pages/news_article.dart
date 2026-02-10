import 'package:flutter/material.dart';
import 'package:frontend/models/news_item.dart';
import 'package:frontend/utils/navigation_controller.dart';
import 'package:frontend/repositories/article_repository.dart';
import '../widgets/clickable_words_text.dart';
import '../widgets/article_content_display.dart'; // New import

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
                final isAlreadySaved = await ArticleRepository.instance.isArticleSaved(article);

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

                await ArticleRepository.instance.saveArticle(article);

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
          child: ArticleContentDisplay(
            date: article.date,
            image: article.image,
            structuredContent: article.content,
          ),
        ),
      ),
    );
  }
}
