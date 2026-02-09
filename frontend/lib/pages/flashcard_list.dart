import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:frontend/models/flashcard.dart';
import 'package:frontend/pages/flashcard_detail.dart';
import '../utils/aurora_gradient.dart';

class FlashcardListPage extends StatefulWidget {
  const FlashcardListPage({super.key});

  @override
  State<FlashcardListPage> createState() => _FlashcardListPageState();
}

class _FlashcardListPageState extends State<FlashcardListPage> {
  List<Flashcard> _flashcards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final box = await Hive.openBox<Flashcard>('flashcards');
    setState(() {
      _flashcards = box.values.toList();
      _isLoading = false;
    });
  }

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
              'Sanakortit',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flashcards.isEmpty
              ? const Center(child: Text('Ei sanakortteja. Lisää sanoja sanakirjasta!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _flashcards.length,
                  itemBuilder: (context, index) {
                    final flashcard = _flashcards[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          flashcard.word,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          flashcard.definition,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlashcardDetailPage(
                                flashcard: flashcard,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}