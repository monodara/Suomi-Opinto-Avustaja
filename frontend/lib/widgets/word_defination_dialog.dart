import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/saved_word.dart';
import 'package:frontend/repositories/word_repository.dart';

class WordDefinitionDialog extends StatefulWidget {
  final String displayWord;
  final List<Map<String, dynamic>> parts;
  final String combinedWord;
  final String? feats;
  final VoidCallback? onWordBookUpdated; // New callback

  const WordDefinitionDialog({
    super.key,
    required this.displayWord,
    required this.parts,
    required this.combinedWord,
    this.feats,
    this.onWordBookUpdated, // Constructor parameter
  });

  @override
  State<WordDefinitionDialog> createState() => _WordDefinitionDialogState();
}

class _WordDefinitionDialogState extends State<WordDefinitionDialog> {
  late Map<String, bool> _isSavedMap;

  @override
  void initState() {
    super.initState();
    _isSavedMap = {};
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    final map = <String, bool>{};
    for (var part in widget.parts) {
      final word = part['word'] ?? '';
      final exists = await WordRepository.instance.isWordSaved(word);
      map[word] = exists;
    }
    setState(() {
      _isSavedMap = map;
    });
  }

  Future<void> _toggleSave(
    String word,
    String pos,
    List<dynamic> meanings,
  ) async {
    final alreadyExists = _isSavedMap[word] ?? false;

    if (alreadyExists) {
      // Remove
      await WordRepository.instance.deleteWord(word);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Poistettu sanakirjasta: $word')));
    } else {
      // Add
      await WordRepository.instance.saveWord(word, pos, meanings);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lisätty sanakirjaan: $word')));
    }

    // Update status
    setState(() {
      _isSavedMap[word] = !alreadyExists;
    });

    // Call external refresh callback
    if (widget.onWordBookUpdated != null) {
      widget.onWordBookUpdated!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        widget.displayWord,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              ...widget.parts.map((part) {
                final word = part['word'] ?? '';
                final pos = part['pos'] ?? '';
                final meanings = (part['meanings'] as List<dynamic>?) ?? [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '$word: $pos',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isSavedMap[word] == true
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: _isSavedMap[word] == true
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              tooltip: _isSavedMap[word] == true ? 'Poista sanakirjasta' : 'Lisää sanakirjaan',
                              onPressed: () => _toggleSave(word, pos, meanings),
                            ),
                          ],
                        ),
                      ),
                      ...meanings.map((m) {
                        final definition = m['definition'] ?? '';
                        final example = m['example'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                definition,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                              if (example.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    example,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
              const Divider(),
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Taivutus',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    if (widget.feats != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          border: Border.all(color: Colors.blue[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.feats!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Sulje'),
        ),
      ],
    );
  }
}
