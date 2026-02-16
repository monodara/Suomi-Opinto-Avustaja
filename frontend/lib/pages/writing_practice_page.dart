import 'package:flutter/material.dart';
import 'package:frontend/models/saved_word.dart';
import 'package:frontend/repositories/word_repository.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';

class WritingPracticePage extends StatefulWidget {
  const WritingPracticePage({super.key});

  @override
  State<WritingPracticePage> createState() => _WritingPracticePageState();
}

class _WritingPracticePageState extends State<WritingPracticePage> {
  final TextEditingController _paragraphController = TextEditingController();
  List<SavedWord> _todayVocabulary = [];
  String? _originalParagraph;
  String? _correctedParagraph;
  String? _correctionsExplanation;
  String? _vocabularyUsageFeedback;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodayVocabulary();
  }

  Future<void> _loadTodayVocabulary() async {
    try {
      final words = await WordRepository.instance.getRandomWords(5);
      setState(() {
        _todayVocabulary = words;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load vocabulary: $e';
      });
    }
  }

  Future<void> _submitForAnalysis() async {
    if (_paragraphController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please write a paragraph to analyze.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _originalParagraph = null;
      _correctedParagraph = null;
      _correctionsExplanation = null;
      _vocabularyUsageFeedback = null;
    });

    try {
      final vocabularyWords = _todayVocabulary
          .map((word) => word.word)
          .toList();
      final result = await ApiService.instance.writingPracticeAnalysis(
        _paragraphController.text,
        vocabularyWords,
      );

      final String rawAnalysis = result['analysis_result'];
      final decoded = jsonDecode(rawAnalysis);

      if (decoded is Map<String, dynamic>) {
        setState(() {
          _originalParagraph = decoded['original_paragraph'];
          _correctedParagraph = decoded['corrected_paragraph'];
          _correctionsExplanation = decoded['corrections_explanation'];
          _vocabularyUsageFeedback = decoded['vocabulary_usage_feedback'];
        });
      } else {
        setState(() {
          _errorMessage =
              'AI analysis returned unexpected format: $rawAnalysis';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during analysis: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _paragraphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4285F4), // Start color (original blue)
                Color(0xFF2A65CC), // Slightly darker blue for gradient effect
              ],
            ),
          ),
          child: AppBar(
            title: const Text(
              'Kirjoitusharjoitus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
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
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Päivän Sanasto:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _todayVocabulary
                  .map((word) => Chip(label: Text(word.word)))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kirjoita kappaleesi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _paragraphController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Käytä tämän päivän sanastoa ja kirjoita jotain, mitä haluat sanoa...',
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitForAnalysis,
                    child: const Text('Lähetä analysoitavaksi'),
                  ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_correctedParagraph != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Corrected Paragraph:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_correctedParagraph!),
            ],
            if (_correctionsExplanation != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Corrections Explanation:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_correctionsExplanation!),
            ],
            if (_vocabularyUsageFeedback != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Vocabulary Usage Feedback:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_vocabularyUsageFeedback!),
            ],
          ],
        ),
      ),
    );
  }
}
