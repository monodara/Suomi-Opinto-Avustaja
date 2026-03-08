import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import '../models/news_item.dart';
import '../repositories/word_repository.dart'; // Import WordRepository
import '../repositories/user_activity_repository.dart'; // New import
import '../models/saved_word.dart'; // Import SavedWord
import '../widgets/todays_achievements_card.dart'; // New import
import '../widgets/todays_vocabulary_section.dart'; // New import
import '../widgets/latest_news_article_card.dart'; // New import
import '../widgets/saved_articles_section.dart'; // New import
import 'package:frontend/pages/writing_practice_page.dart'; // New import for WritingPracticePage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<NewsItem?>? _newsFuture;
  String? _error;
  List<SavedWord> _todayVocabulary = [];
  int _wordsLearnedToday = 0;
  int _sentencesReadToday = 0; // New state variable

  @override
  void initState() {
    super.initState();
    _newsFuture = ApiService.instance.fetchNews();
    _loadTodayVocabulary();
    _loadAchievements();
  }

  void _retry() {
    setState(() {
      _newsFuture = ApiService.instance.fetchNews();
      _error = null;
    });
  }

  Future<void> _loadTodayVocabulary() async {
    final words = await WordRepository.instance.getWordsDueForReview(5);
    setState(() {
      _todayVocabulary = words;
    });
  }

  Future<void> _loadAchievements() async {
    final wordsLearned = await WordRepository.instance.getWordsLearnedToday();
    final sentencesRead = await UserActivityRepository.instance.getSentencesReadToday();
    setState(() {
      _wordsLearnedToday = wordsLearned;
      _sentencesReadToday = sentencesRead;
    });
  }

  void _onWordStatusChanged() {
    _loadAchievements();
    _loadTodayVocabulary();
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
              TodaysAchievementsCard(
                wordsLearned: _wordsLearnedToday,
                sentencesRead: _sentencesReadToday,
              ),
              const SizedBox(height: 24),
              TodaysVocabularySection(
                todayVocabulary: _todayVocabulary,
                onWordStatusChanged: _onWordStatusChanged, // Pass callback
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WritingPracticePage(),
                    ),
                  );
                },
                child: const Text('Aloita kirjoitusharjoittelu'),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Uusimat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LatestNewsArticleCard(
                article: article,
                onSentencePracticed: _onWordStatusChanged, // Pass callback
              ),
              const SizedBox(height: 32),
              const SavedArticlesSection(), // Re-add the SavedArticlesSection
            ],
          );
        }
      },
    );
  }
}
