import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/word_defination_dialog.dart';

class ClickableWordsText extends StatefulWidget {
  final String text;

  const ClickableWordsText({super.key, required this.text});

  @override
  State<ClickableWordsText> createState() => _ClickableWordsTextState();
}

class _ClickableWordsTextState extends State<ClickableWordsText> {
  String? _selectedWord; // State to hold the currently selected word

  @override
  Widget build(BuildContext context) {
    final words = widget.text.split(RegExp(r'\s+'));

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: words.map((word) {
        final isHighlighted = _selectedWord == word;
        return GestureDetector(
          onLongPress: () async {
            setState(() {
              _selectedWord = word; // Set the selected word
            });

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            final data = await ApiService.instance.lookupWordData(word);

            if (!context.mounted) return; // Add this check
            Navigator.pop(context); // close loading dialog

            // Type-safe conversion
            final partsRaw = data['parts'];
            final parts = partsRaw is List
                ? partsRaw.map((e) => Map<String, dynamic>.from(e)).toList()
                : <Map<String, dynamic>>[];

            final featsRaw = data['feats'];
            final feats = featsRaw is List ? featsRaw.cast<String>() : null; // Cast to List<String>

            final displayWord = data['word'] ?? word;

            if (!context.mounted) return; // Add this check
            await showDialog( // Use await to know when dialog is dismissed
              context: context,
              builder: (context) => WordDefinitionDialog(
                displayWord: displayWord,
                parts: parts,
                combinedWord: word,
                feats: feats, // Pass List<String>?
              ),
            );

            setState(() {
              _selectedWord = null; // Clear the selected word when dialog is dismissed
            });
          },
          child: Text(
            word,
            style: TextStyle(
              color: Colors.black87,
              decoration: TextDecoration.none,
              backgroundColor: isHighlighted ? Colors.yellow.withOpacity(0.5) : Colors.transparent, // Highlight
            ),
          ),
        );
      }).toList(),
    );
  }
}
