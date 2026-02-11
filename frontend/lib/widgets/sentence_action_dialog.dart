import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert'; // Import for jsonDecode

class SentenceActionDialog extends StatefulWidget {
  final String sentence;

  const SentenceActionDialog({super.key, required this.sentence});

  @override
  State<SentenceActionDialog> createState() => _SentenceActionDialogState();
}

class _SentenceActionDialogState extends State<SentenceActionDialog> {
  String? _translatedText;
  String? _llmAnalysisResult; // For grammatical structure
  String? _culturalNuancesResult; // For cultural nuances
  bool _isLoadingTranslation = false;
  bool _isLoadingLLMAnalysis = false;

  Future<void> _translateSentence() async {
    setState(() {
      _isLoadingTranslation = true;
      _translatedText = null; // Clear previous result
    });
    try {
      final result = await ApiService.instance.translateText(widget.sentence);
      setState(() {
        _translatedText = result['translated_text'];
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e')),
        );
      }
      _translatedText = 'Error: ${e.toString()}';
    } finally {
      setState(() {
        _isLoadingTranslation = false;
      });
    }
  }

  Future<void> _analyzeSentence() async {
    setState(() {
      _isLoadingLLMAnalysis = true;
      _llmAnalysisResult = null; // Clear previous result
      _culturalNuancesResult = null; // Clear previous result
    });
    try {
      final result = await ApiService.instance.llmAnalyzeText(widget.sentence);
      final String rawAnalysis = result['analysis_result'];
      
      try {
        final decoded = jsonDecode(rawAnalysis);
        if (decoded is Map<String, dynamic>) {
          final Map<String, dynamic> parsedAnalysis = decoded;
          
          // Extract grammatical_structure
          final dynamic grammaticalStructure = parsedAnalysis['grammatical_structure'];
          if (grammaticalStructure != null) {
            if (grammaticalStructure is String) {
              _llmAnalysisResult = grammaticalStructure.trim();
            } else if (grammaticalStructure is Map<String, dynamic>) {
              String formattedStructure = '';
              grammaticalStructure.forEach((key, value) {
                final capitalizedKey = key.replaceAll('_', ' ').capitalizeFirst;
                formattedStructure += '$capitalizedKey: $value\n';
              });
              _llmAnalysisResult = formattedStructure.trim();
            } else {
              _llmAnalysisResult = 'Grammatical structure has an unexpected format.';
            }
          } else {
            _llmAnalysisResult = 'Grammatical structure not found in analysis.';
          }

          // Extract cultural_nuances
          final String? culturalNuances = parsedAnalysis['cultural_nuances'];
          if (culturalNuances != null) {
            _culturalNuancesResult = culturalNuances;
          } else {
            _culturalNuancesResult = 'Cultural nuances not found in analysis.';
          }
        } else {
          // If decoded is not a Map, treat rawAnalysis as a plain string
          _llmAnalysisResult = 'AI analysis returned plain text:\n$rawAnalysis';
          _culturalNuancesResult = null;
        }

      } on FormatException catch (e) {
        // Handle malformed JSON from LLM
        _llmAnalysisResult = 'Error parsing AI analysis (malformed JSON): $e\nRaw response: $rawAnalysis';
        _culturalNuancesResult = null;
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Analysis failed: $e')),
        );
      }
      _llmAnalysisResult = 'Error: ${e.toString()}';
      _culturalNuancesResult = null;
    } finally {
      setState(() {
        _isLoadingLLMAnalysis = false;
      });
    }
  }

  void _clearResults() {
    setState(() {
      _translatedText = null;
      _llmAnalysisResult = null;
      _culturalNuancesResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sentence Actions'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              widget.sentence,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoadingTranslation ? null : _translateSentence,
              child: _isLoadingTranslation
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Käännä (Translate)'),
            ),
            if (_translatedText != null) ...[
              const SizedBox(height: 10),
              const Text('Translation:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_translatedText!),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoadingLLMAnalysis ? null : _analyzeSentence,
              child: _isLoadingLLMAnalysis
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tekoälyanalyysi (AI Analysis)'),
            ),
            if (_llmAnalysisResult != null) ...[
              const SizedBox(height: 10),
              const Text('Grammatical Structure:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_llmAnalysisResult!),
            ],
            if (_culturalNuancesResult != null) ...[
              const SizedBox(height: 10),
              const Text('Cultural Nuances:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_culturalNuancesResult!),
            ],
            if (_translatedText != null || _llmAnalysisResult != null || _culturalNuancesResult != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: _clearResults,
                child: const Text('Clear Results'),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
