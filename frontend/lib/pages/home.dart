import 'package:flutter/material.dart';
import '../models/news_item.dart';
import 'news_article.dart';
import '../utils/aurora_gradient.dart';
import '../models/saved_article.dart';
import 'package:hive/hive.dart';
import '../utils/navigation_controller.dart';
import 'saved_article_detail.dart';

class HomePage extends StatefulWidget {
  final Future<NewsItem?> Function() fetchNews;

  const HomePage({super.key, required this.fetchNews});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<NewsItem?>? _newsFuture;
  String? _error;

  @override
  void initState() {
    super.initState();
    _newsFuture = widget.fetchNews();
  }

  void _retry() {
    setState(() {
      _newsFuture = widget.fetchNews();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NewsItem?>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Ladataan uutisia...'),
              ],
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _error ?? "Failed to load news.",
                  style: const TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: _retry,
                  child: const Text('Yritä uudelleen'),
                ),
              ],
            ),
          );
        } else {
          final article = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () {
                      // Show news details via navigation controller
                      NavigationController().showArticleDetails(article);
                    },
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article.image != null &&
                              article.image!['url'] != '')
                            Container(
                              constraints: const BoxConstraints(
                                minHeight: 150,
                                maxHeight: 300,
                              ),
                              child: Image.network(
                                article.image!['url']!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
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
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  article.date,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FutureBuilder<Box<SavedArticle>>(
                future: Hive.openBox<SavedArticle>('saved_articles'),
                builder: (context, savedSnapshot) {
                  if (savedSnapshot.hasData) {
                    final savedArticles = savedSnapshot.data!.values
                        .toList()
                        .reversed
                        .toList();

                    if (savedArticles.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
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
                                          builder: (context) =>
                                              SavedArticleDetailPage(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
              ),
            ],
          );
        }
      },
    );
  }
}
