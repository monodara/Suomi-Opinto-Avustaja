import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:frontend/models/saved_article.dart';
import 'package:frontend/pages/saved_article_detail.dart';

class SavedArticlesSection extends StatelessWidget {
  const SavedArticlesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box<SavedArticle>>(
      future: Hive.openBox<SavedArticle>('saved_articles'),
      builder: (context, savedSnapshot) {
        if (savedSnapshot.hasData) {
          final savedArticles =
              savedSnapshot.data!.values.toList().reversed.toList();

          if (savedArticles.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0, // Match padding of other sections
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Tallennetut artikkelit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: savedArticles.length,
                    itemBuilder: (context, index) {
                      final savedArticle = savedArticles[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SavedArticleDetailPage(
                                  article: savedArticle,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    savedArticle.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    savedArticle.date,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${savedArticle.savedDate.day}.${savedArticle.savedDate.month}.${savedArticle.savedDate.year}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        }

        return Container(); // Return empty container if there are no saved articles
      },
    );
  }
}