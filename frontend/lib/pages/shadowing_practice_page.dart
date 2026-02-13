import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:frontend/audio_handler.dart'; // New import for conditional audio handler
import 'package:frontend/audio_handler_interface.dart'; // New import for the interface
import 'dart:io'; // For File operations
import 'package:path_provider/path_provider.dart'; // For temporary file path
import 'dart:async'; // For Timer

class ShadowingPracticePage extends StatefulWidget {
  final List<Map<String, dynamic>> articleContent;

  const ShadowingPracticePage({super.key, required this.articleContent});

  @override
  State<ShadowingPracticePage> createState() => _ShadowingPracticePageState();
}

class _ShadowingPracticePageState extends State<ShadowingPracticePage> {
  List<String> _sentences = [];
  int _currentSentenceIndex = 0;
  bool _isLoadingSentences = true;
  String? _errorMessage;

  late FlutterTts flutterTts;
  late AudioHandlerInterface _audioHandler; // Use the interface
  bool _isRecording = false;
  String? _recordedFilePath;

  String? _transcribedText;
  double? _similarityScore;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _loadSentences();
    flutterTts = FlutterTts();
    _initTts();
    _audioHandler =
        getAudioHandler(); // Get the platform-specific implementation
    _audioHandler.init();
  }

  Future<void> _loadSentences() async {
    setState(() {
      _isLoadingSentences = true;
      _errorMessage = null;
    });
    try {
      String fullText = widget.articleContent
          .map((item) => item['text'] as String? ?? '')
          .join(' ');
      final response = await ApiService.instance.segmentSentences(fullText);
      setState(() {
        _sentences = List<String>.from(response['sentences']);
        _isLoadingSentences = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load sentences: $e';
        _isLoadingSentences = false;
      });
    }
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("fi-FI");
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakCurrentSentence() async {
    if (_sentences.isNotEmpty) {
      await flutterTts.speak(_sentences[_currentSentenceIndex]);
    }
  }

  Future<void> _startRecording() async {
    if (!_audioHandler.isSupported()) {
      setState(() {
        _errorMessage = 'Audio recording is not supported on this platform.';
      });
      return;
    }

    try {
      if (await _audioHandler.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _recordedFilePath = '${directory.path}/shadowing_audio.wav';
        await _audioHandler.startRecording(_recordedFilePath!);
        setState(() {
          _isRecording = true;
          _transcribedText = null;
          _similarityScore = null;
          _errorMessage = null;
        });
      } else {
        // If permission is not granted, check if it's permanently denied
        // The audio_handler_mobile.dart already calls openAppSettings() if permanentlyDenied
        setState(() {
          _errorMessage =
              'Microphone permission not granted. Please enable it in your device settings.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_audioHandler.isSupported()) return;

    try {
      final path = await _audioHandler.stopRecording();
      if (path != null) {
        _recordedFilePath = path;
        setState(() {
          _isRecording = false;
        });
        _analyzeRecording();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to stop recording: $e';
      });
    }
  }

  Future<void> _analyzeRecording() async {
    if (_recordedFilePath == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final audioFile = File(_recordedFilePath!);
      final audioBytes = await audioFile.readAsBytes();

      // ASR
      final asrResponse = await ApiService.instance.transcribeAudio(audioBytes);
      _transcribedText = asrResponse['transcribed_text'];

      // Compare sentences
      if (_transcribedText != null && _transcribedText!.isNotEmpty) {
        final comparisonResponse = await ApiService.instance.compareSentences(
          _sentences[_currentSentenceIndex],
          _transcribedText!,
        );
        _similarityScore = comparisonResponse['similarity_score'];
      } else {
        _similarityScore = 0.0; // No transcription, no similarity
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Analysis failed: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _nextSentence() {
    setState(() {
      if (_currentSentenceIndex < _sentences.length - 1) {
        _currentSentenceIndex++;
        _transcribedText = null;
        _similarityScore = null;
        _errorMessage = null;
      }
    });
  }

  void _previousSentence() {
    setState(() {
      if (_currentSentenceIndex > 0) {
        _currentSentenceIndex--;
        _transcribedText = null;
        _similarityScore = null;
        _errorMessage = null;
      }
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    _audioHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shadowing Practice')),
      body: _isLoadingSentences
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sentence ${_currentSentenceIndex + 1} / ${_sentences.length}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _sentences[_currentSentenceIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          size: 40,
                          color: Colors.blue,
                        ),
                        onPressed: _speakCurrentSentence,
                      ),
                      const SizedBox(width: 20),
                      if (!_audioHandler.isSupported())
                        const Text(
                          'Recording not supported on this platform',
                          style: TextStyle(color: Colors.red),
                        )
                      else
                        _isRecording
                            ? IconButton(
                                icon: const Icon(
                                  Icons.stop,
                                  size: 40,
                                  color: Colors.red,
                                ),
                                onPressed: _stopRecording,
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.mic,
                                  size: 40,
                                  color: Colors.green,
                                ),
                                onPressed: _startRecording,
                              ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_isAnalyzing)
                    const CircularProgressIndicator()
                  else if (_transcribedText != null) ...[
                    const Text(
                      'Your recording:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_transcribedText!),
                    const SizedBox(height: 10),
                    if (_similarityScore != null)
                      Text(
                        'Similarity Score: ${(_similarityScore! * 100).toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _similarityScore! > 0.7
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                  ],
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _currentSentenceIndex > 0
                            ? _previousSentence
                            : null,
                        child: const Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: _currentSentenceIndex < _sentences.length - 1
                            ? _nextSentence
                            : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
