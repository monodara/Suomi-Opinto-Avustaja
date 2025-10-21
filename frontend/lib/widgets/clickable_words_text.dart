import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'word_defination_dialog.dart';
import '../config.dart';

class ClickableWordsText extends StatelessWidget {
  final String text;

  const ClickableWordsText({super.key, required this.text});

  Future<Map<String, dynamic>> lookupWordData(String word) async {
    final box = Hive.box('word_cache');

    // if found in cache, return directly
    if (box.containsKey(word)) {
      return Map<String, dynamic>.from(box.get(word));
    }

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/define?word=$word'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        box.put(word, data); // save in cache/Hive
        return data;
      } else {
        return {"word": word, "parts": [], "feats": null};
      }
    } catch (e) {
      // offline also can't find
      return {"word": word, "parts": [], "feats": null};
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = text.split(RegExp(r'\s+'));

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: words.map((word) {
        return GestureDetector(
          onLongPress: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            final data = await lookupWordData(word);

            Navigator.pop(context); // close loading dialog

            // Type-safe conversion
            final partsRaw = data['parts'];
            final parts = partsRaw is List
                ? partsRaw.map((e) => Map<String, dynamic>.from(e)).toList()
                : <Map<String, dynamic>>[];

            final feats = data['feats'] != null
                ? Map<String, dynamic>.from(data['feats'])['feats'] as String?
                : null;
            final displayWord = data['word'] ?? word;

            showDialog(
              context: context,
              builder: (context) => WordDefinitionDialog(
                displayWord: displayWord,
                parts: parts,
                combinedWord: word,
                feats: feats,
              ),
            );
          },
          child: Text(
            word,
            style: const TextStyle(
              color: Colors.black87,
              decoration: TextDecoration.none,
            ),
          ),
        );
      }).toList(),
    );
  }
}
