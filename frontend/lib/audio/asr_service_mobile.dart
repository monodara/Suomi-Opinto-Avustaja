import 'package:frontend/audio/asr_service_interface.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async'; // Import for Completer

class ASRServiceMobile implements ASRServiceInterface {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String? _lastError;
  String? _lastRecognizedWords;
  Completer<String?>? _completer; // Completer to hold the result of startListening

  @override
  Future<void> init() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (errorNotification) {
        _lastError = errorNotification.errorMsg;
        print('ASR Error: $_lastError');
        if (_completer != null && !_completer!.isCompleted) {
          _completer!.completeError(errorNotification.errorMsg);
        }
      },
      onStatus: (status) {
        print('ASR Status: $status');
        if (status == 'done' && _completer != null && !_completer!.isCompleted) {
          print('ASR: Completing with recognized words: $_lastRecognizedWords');
          _completer!.complete(_lastRecognizedWords);
        }
      },
    );
    if (!_speechEnabled) {
      _lastError = 'Speech recognition not available.';
      print('ASR Initialization Failed: $_lastError');
    }
  }

  @override
  Future<String?> startListening(String languageCode) async {
    if (!_speechEnabled) {
      _lastError = 'Speech recognition not initialized or available.';
      print('ASR: startListening failed - $_lastError');
      return null;
    }

    _lastRecognizedWords = null;
    _lastError = null;
    _completer = Completer<String?>(); // Create a new completer
    print('ASR: Starting listening...');

    await _speechToText.listen(
      onResult: (result) {
        _lastRecognizedWords = result.recognizedWords;
        print('ASR: Recognized words (partial/final): $_lastRecognizedWords');
      },
      localeId: languageCode,
    );
    return _completer!.future; // Return the future from the completer
  }

  @override
  Future<void> stopListening() async {
    print('ASR: Stopping listening...');
    await _speechToText.stop();
    if (_completer != null && !_completer!.isCompleted) {
      print('ASR: Completing with recognized words from stop: $_lastRecognizedWords');
      _completer!.complete(_lastRecognizedWords); // Complete with the last recognized words
    }
  }

  @override
  bool isListening() {
    return _speechToText.isListening;
  }

  @override
  bool isSupported() {
    return _speechEnabled;
  }

  @override
  String? get lastError => _lastError;

  @override
  String? get lastRecognizedWords => _lastRecognizedWords;
}

ASRServiceInterface getASRService() => ASRServiceMobile();