import 'package:flutter/material.dart';
import '../models/saved_article.dart';
import '../utils/aurora_gradient.dart';
import '../widgets/clickable_words_text.dart';
import '../widgets/article_content_display.dart'; // New import

class SavedArticleDetailPage extends StatelessWidget {
  final SavedArticle article;

  const SavedArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Set to transparent to show flexibleSpace gradient
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('SisuHyy', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
          child: Column(
            children: [
              ArticleContentDisplay(
                date: article.date,
                image: article.image,
                structuredContent: article.structuredContent,
              ),
              const SizedBox(height: 16),
              Text(
                'Tallennettu: ${article.savedDate.day}.${article.savedDate.month}.${article.savedDate.year}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}