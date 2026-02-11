import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/word_defination_dialog.dart';
import 'package:frontend/widgets/sentence_action_dialog.dart'; // New import

class ClickableWordsText extends StatefulWidget {
  final String word;
  final String paragraphText; // The full paragraph text
  final int wordIndex; // The index of this word in the paragraph

  const ClickableWordsText({
    super.key,
    required this.word,
    required this.paragraphText,
    required this.wordIndex,
  });

  @override
  State<ClickableWordsText> createState() => _ClickableWordsTextState();
}

class _ClickableWordsTextState extends State<ClickableWordsText> {
  String? _selectedWord; // State to hold the currently selected word

  Future<void> _handleDoubleTap(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.instance.segmentSentences(widget.paragraphText);
      final List<String> sentences = List<String>.from(response['sentences']);

      String selectedSentence = '';
      int currentWordCount = 0;
      for (String sentence in sentences) {
        final wordsInSentence = sentence.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
        if (widget.wordIndex >= currentWordCount && widget.wordIndex < currentWordCount + wordsInSentence.length) {
          selectedSentence = sentence;
          break;
        }
        currentWordCount += wordsInSentence.length;
      }

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (selectedSentence.isNotEmpty) {
        await showDialog(
          context: context,
          builder: (context) => SentenceActionDialog(sentence: selectedSentence),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not identify the sentence.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error segmenting sentence: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHighlighted = _selectedWord == widget.word;
    return GestureDetector(
      onLongPress: () async {
        setState(() {
          _selectedWord = widget.word; // Set the selected word
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        final data = await ApiService.instance.lookupWordData(widget.word);

        if (!context.mounted) return; // Add this check
        Navigator.pop(context); // close loading dialog

        // Type-safe conversion
        final partsRaw = data['parts'];
        final parts = partsRaw is List
            ? partsRaw.map((e) => Map<String, dynamic>.from(e)).toList()
            : <Map<String, dynamic>>[];

        final featsRaw = data['feats'];
        final feats = featsRaw is List ? featsRaw.cast<String>() : null; // Cast to List<String>

        final displayWord = data['word'] ?? widget.word;

        if (!context.mounted) return; // Add this check
        await showDialog( // Use await to know when dialog is dismissed
          context: context,
          builder: (context) => WordDefinitionDialog(
            displayWord: displayWord,
            parts: parts,
            combinedWord: widget.word,
            feats: feats, // Pass List<String>?
          ),
        );

        setState(() {
          _selectedWord = null; // Clear the selected word when dialog is dismissed
        });
      },
      onDoubleTap: () => _handleDoubleTap(context), // Handle double-tap
      child: Text(
        widget.word,
        style: TextStyle(
          color: Colors.black87,
          decoration: TextDecoration.none,
          backgroundColor: isHighlighted ? Colors.yellow.withOpacity(0.5) : Colors.transparent, // Highlight
        ),
      ),
    );
  }
}
