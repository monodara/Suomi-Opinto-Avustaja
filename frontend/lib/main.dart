import 'package:flutter/material.dart';
import 'package:frontend/models/saved_article.dart';
import 'package:frontend/models/saved_word.dart';
import 'package:frontend/models/flashcard.dart';
import 'package:frontend/pages/news_article.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/home.dart';
import 'pages/wordbook.dart';
import 'pages/flashcard_list.dart';
import 'models/news_item.dart';
import 'config.dart';
import 'utils/aurora_gradient.dart';
import 'utils/navigation_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);
  
  // Clean up old Hive data to avoid type conflicts
  try {
    await Hive.deleteBoxFromDisk('wordbook');
    await Hive.deleteBoxFromDisk('saved_articles');
  } catch (e) {
    // Ignore deletion errors
  }
  
  Hive.registerAdapter(SavedWordAdapter());
  Hive.registerAdapter(SavedArticleAdapter());
  Hive.registerAdapter(FlashcardAdapter());
  await Hive.openBox('word_cache');
  await Hive.openBox<SavedWord>('wordbook');
  await Hive.openBox<SavedArticle>('saved_articles');
  await Hive.openBox<Flashcard>('flashcards');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<NewsItem> fetchNews() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/latest-news'));

    if (response.statusCode == 200) {
      return NewsItem.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Loading news failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SisuHyy!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: MainApp(fetchNews: fetchNews),
    );
  }
}

class MainApp extends StatefulWidget {
  final Future<NewsItem> Function() fetchNews;
  const MainApp({super.key, required this.fetchNews});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  NewsItem? _selectedArticle;

  @override
  void initState() {
    super.initState();
    // 设置导航控制器的回调
    NavigationController().onReturnToHome = _clearSelectedArticle;
    NavigationController().onShowArticleDetails = _setSelectedArticle;
  }

  // Private methods for navigation controller
  void _setSelectedArticle(NewsItem article) {
    setState(() {
      _selectedArticle = article;
    });
  }

  void _clearSelectedArticle() {
    setState(() {
      _selectedArticle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(fetchNews: widget.fetchNews),
      const WordbookPage(),
      const FlashcardListPage(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: AuroraGradient.createAuroraGradient(),
          ),
          child: AppBar(
            title: const Text(
              'SisuHyy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: _selectedArticle == null
          ? pages[_currentIndex]
          : NewsDetailPage(article: _selectedArticle!),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // 如果当前显示的是新闻详情页面，点击底部导航应该先返回主页
          if (_selectedArticle != null) {
            setState(() {
              _selectedArticle = null;
              _currentIndex = index;
            });
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Koti'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Sanakirja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: 'Sanakortit',
          ),
        ],
      ),
    );
  }

  // Public methods for other widgets to access
  void setSelectedArticle(NewsItem article) {
    setState(() {
      _selectedArticle = article;
    });
  }

  void clearSelectedArticle() {
    setState(() {
      _selectedArticle = null;
    });
  }
}
