import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:frontend/services/api_service.dart';
import 'word_defination_dialog.dart';
import '../config.dart';

class ClickableWordsText extends StatelessWidget {
  final String text;

  const ClickableWordsText({super.key, required this.text});

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
            final data = await ApiService.instance.lookupWordData(word);

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
