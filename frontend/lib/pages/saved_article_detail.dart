import 'package:flutter/material.dart';
import '../models/saved_article.dart';
import '../utils/aurora_gradient.dart';
import '../widgets/clickable_words_text.dart';
import 'dart:convert';

class SavedArticleDetailPage extends StatelessWidget {
  final SavedArticle article;

  const SavedArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: AuroraGradient.createAuroraGradient(),
          ),
          child: AppBar(
            title: const Text('SisuHyy', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
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
                if (article.image != null && article.image!['url'] != '')
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        article.image!['url']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
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
                if (article.image != null && article.image!['caption'] != '' && article.image!['caption'] != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      article.image!['caption'] as String,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Display article using structured content
                ..._buildContentWidgets(article.structuredContent),
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
      ),
    );
  }

  List<Widget> _buildContentWidgets(List<Map<String, dynamic>> structuredContent) {
    final widgets = <Widget>[];
    
    for (final item in structuredContent) {
      final text = item['text'] as String? ?? '';
      if (text.trim().isEmpty) continue;
      
      final isHeader = item['type'] == 'h1' || item['type'] == 'h2';
      
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: isHeader ? 22 : 16,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
              height: 1.5,
            ),
            child: ClickableWordsText(text: text.trim()),
          ),
        ),
      );
    }
    
    return widgets;
  }
}