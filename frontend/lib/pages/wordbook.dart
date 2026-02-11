import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:frontend/models/saved_word.dart';
import 'word_detail.dart';

class WordbookPage extends StatefulWidget {
  const WordbookPage({super.key});

  @override
  State<WordbookPage> createState() => _WordbookPageState();
}

class _WordbookPageState extends State<WordbookPage> {
  late Box<SavedWord> _wordBox;
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _wordBox = await Hive.openBox<SavedWord>('wordbook');
    setState(() {
      _isLoading = false; // Set loading to false after box is open
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final words = _wordBox.values.toList();

    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Sanakirja on tyhjä',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Lisää sanoja lukemalla uutisia',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            title: Text(
              word.word,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${word.pos}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  word.definition,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _wordBox.deleteAt(index);
                setState(() {});
              },
            ),
            onTap: () {
              // Navigate to word detail page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordDetailPage(word: word),
                ),
              ).then((_) {
                // Refresh the list when returning from word detail page
                setState(() {});
              });
            },
          ),
        );
      },
    );
  }
}
