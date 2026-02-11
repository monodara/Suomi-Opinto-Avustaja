import 'package:flutter/material.dart';
import 'package:frontend/models/news_item.dart';
import 'package:frontend/utils/navigation_controller.dart';
import 'package:frontend/repositories/article_repository.dart';
import '../widgets/article_content_display.dart'; // New import

class NewsDetailPage extends StatelessWidget {
  final NewsItem article;

  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors
            .transparent, // Set to transparent to show flexibleSpace gradient
        foregroundColor: Colors.white,
        elevation: 0,
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
                final isAlreadySaved = await ArticleRepository.instance
                    .isArticleSaved(article);

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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4285F4), // Start color (original blue)
                Color(0xFF2A65CC), // Slightly darker blue for gradient effect
              ],
            ),
          ),
        ),
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
