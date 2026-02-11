import 'package:flutter/material.dart';
import 'package:frontend/models/saved_word.dart';
import 'package:frontend/models/flashcard.dart';
import 'package:hive/hive.dart';
import '../utils/aurora_gradient.dart';
import '../widgets/clickable_words_text.dart';

class WordDetailPage extends StatelessWidget {
  final SavedWord word;

  const WordDetailPage({super.key, required this.word});

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_card, color: Colors.white),
                onPressed: () async {
                  try {
                    // Generate and save word flashcard
                    final flashcardBox = await Hive.openBox<Flashcard>('flashcards');
                    
                    // Check if the same flashcard already exists
                    final existingFlashcards = flashcardBox.values.toList();
                    final isAlreadyCreated = existingFlashcards.any((flashcard) => 
                      flashcard.word == word.word && flashcard.pos == word.pos);
                    
                    if (isAlreadyCreated) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sanakortti on jo luotu')),
                        );
                      }
                      return;
                    }
                    
                    final flashcard = Flashcard(
                      word: word.word,
                      pos: word.pos,
                      definition: word.definition,
                      example: word.example,
                      createdDate: DateTime.now(),
                      nextReviewDate: DateTime.now(), // Added nextReviewDate
                      imageUrl: word.imageUrl, // Include the image URL from the saved word
                    );
                    
                    await flashcardBox.add(flashcard);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sanakortti luotu')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Virhe sanakortin luomisessa')),
                      );
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  // Delete current word
                  final box = await Hive.openBox<SavedWord>('wordbook');
                  final index = box.values.toList().indexOf(word);
                  if (index != -1) {
                    await box.deleteAt(index);
                  }

                  // Send notification to update wordbook list
                  // Use Navigator.pop to return and refresh wordbook page
                  if (context.mounted) {
                    Navigator.pop(context); // Return to wordbook list page
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<Box<SavedWord>>(
        future: Hive.openBox<SavedWord>('wordbook'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final box = snapshot.data!;
            final words = box.values.toList();
            final currentIndex = words.indexOf(word);
            
            return PageView.builder(
              itemCount: words.length,
              controller: PageController(initialPage: currentIndex),
              itemBuilder: (context, index) {
                return _buildWordContent(context, words[index]);
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildWordContent(BuildContext context, SavedWord word) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word and part of speech
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word.pos,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Definition
              const Text(
                'Määritelmä',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  word.definition,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Example sentence
              const Text(
                'Esimerkki',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: () {
                      final paragraphText = word.example;
                      final words = paragraphText.split(RegExp(r'\s+'));
                      int currentWordIndex = 0;
                      return words.map((w) {
                        final index = currentWordIndex++;
                        return ClickableWordsText(
                          word: w,
                          paragraphText: paragraphText,
                          wordIndex: index,
                        );
                      }).toList();
                    }(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Display image if available
              if (word.imageUrl != null && word.imageUrl!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      word.imageUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
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
              // Save date
              Text(
                'Lisätty: ${word.dateAdded.day}.${word.dateAdded.month}.${word.dateAdded.year}',
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