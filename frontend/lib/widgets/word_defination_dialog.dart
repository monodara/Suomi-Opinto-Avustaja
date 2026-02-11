import 'package:flutter/material.dart';
import 'package:frontend/repositories/word_repository.dart';
import 'package:flutter_tts/flutter_tts.dart'; // New import

class WordDefinitionDialog extends StatefulWidget {
  final String displayWord;
  final List<Map<String, dynamic>> parts;
  final String combinedWord;
  final List<String>? feats; // Changed to List<String>
  final VoidCallback? onWordBookUpdated; // New callback

  const WordDefinitionDialog({
    super.key,
    required this.displayWord,
    required this.parts,
    required this.combinedWord,
    this.feats, // Now List<String>
    this.onWordBookUpdated, // Constructor parameter
  });

  @override
  State<WordDefinitionDialog> createState() => _WordDefinitionDialogState();
}

class _WordDefinitionDialogState extends State<WordDefinitionDialog> {
  late Map<String, bool> _isSavedMap;
  late FlutterTts flutterTts; // Declare FlutterTts

  @override
  void initState() {
    super.initState();
    _isSavedMap = {};
    _checkSavedStatus();
    flutterTts = FlutterTts(); // Initialize FlutterTts
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("fi-FI"); // Set language to Finnish
    await flutterTts.setSpeechRate(0.5); // Adjust speech rate
    await flutterTts.setVolume(1.0); // Set volume
    await flutterTts.setPitch(1.0); // Set pitch
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
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
      if (!mounted) return; // Add this check
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Poistettu sanakirjasta: $word')));
    } else {
      // Add
      await WordRepository.instance.saveWord(word, pos, meanings);
      if (!mounted) return; // Add this check
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
  void dispose() {
    flutterTts.stop(); // Stop TTS if speaking
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row( // Use Row to place word and speaker icon
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.displayWord,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Darker, more neutral color
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.blue),
            onPressed: () => _speak(widget.displayWord),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0), // Unified horizontal padding
        child: SizedBox(
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
                                child: Row( // Use Row to display word and pos
                                  children: [
                                    Text(
                                      word,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      ': $pos', // Separate pos text
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey[600], // Differentiate POS color
                                      ),
                                    ),
                                  ],
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

                          return Column( // Removed Container decoration
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
                                      color: Colors.black54, // Darker color for better readability
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8), // Spacing between meanings
                            ],
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
                          color: Colors.black87, // Consistent with other titles
                        ),
                      ),
                      if (widget.feats != null && widget.feats!.isNotEmpty)
                        Column( // Removed Container decoration
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.feats!.map((feat) => Padding(
                            padding: const EdgeInsets.only(top: 4.0), // Spacing between features
                            child: Text(
                              feat,
                              style: const TextStyle(fontSize: 14),
                            ),
                          )).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Sulje',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold), // Standard accent color
          ),
        ),
      ],
    );
  }
}
