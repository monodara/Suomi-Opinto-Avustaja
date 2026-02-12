import 'package:flutter/material.dart';
import 'package:frontend/models/saved_word.dart';
import 'package:frontend/pages/flashcard_list.dart';
import 'package:frontend/pages/word_detail.dart'; // New import

class TodaysVocabularySection extends StatelessWidget {
  final List<SavedWord> todayVocabulary;

  const TodaysVocabularySection({
    super.key,
    required this.todayVocabulary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Vocabulary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FlashcardListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.headphones, size: 20),
              label: Text('${todayVocabulary.length} words'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todayVocabulary.isEmpty)
          const Center(
            child: Text(
              'No vocabulary for today. Add some words to your wordbook!',
            ),
          )
        else
          ...todayVocabulary
              .map(
                (word) => GestureDetector( // Wrap Card with GestureDetector
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordDetailPage(word: word),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                word.word,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'New',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            word.pos,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            word.definition,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
      ],
    );
  }
}
