import 'package:frontend/asr_service_interface.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';

class ASRServiceMobile implements ASRServiceInterface {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String? _lastError;
  String? _lastRecognizedWords;

  @override
  Future<void> init() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (errorNotification) {
        _lastError = errorNotification.errorMsg;
        print('ASR Error: $_lastError');
      },
      onStatus: (status) {
        print('ASR Status: $status');
      },
    );
    if (!_speechEnabled) {
      _lastError = 'Speech recognition not available.';
      print('ASR Initialization Failed: $_lastError');
    }
  }

  @override
  Future<bool> hasPermission() async {
    var status = await Permission.microphone.status;
    // If already granted, return true
    if (status.isGranted) return true;

    // If the user has permanently denied the permission, we should guide them to the app settings
    if (status.isPermanentlyDenied) {
      print('Opening app settings for microphone permission.');
      await openAppSettings();
      // After opening settings, wait a bit for the user to potentially change settings
      // and then re-check the status. This is a heuristic.
      await Future.delayed(const Duration(seconds: 2));
      status = await Permission.microphone.status;
      if (status.isGranted) return true; // Permission granted after user interaction
      return false; // Still not granted
    }

    // Try requesting permission again
    status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<String?> startListening(String languageCode) async {
    if (_speechEnabled) {
      _lastRecognizedWords = null;
      _lastError = null;
      await _speechToText.listen(
        onResult: (result) {
          _lastRecognizedWords = result.recognizedWords;
        },
        localeId: languageCode,
      );
      return null; // Result will come via onResult callback
    } else {
      _lastError = 'Speech recognition not initialized or available.';
      return null;
    }
  }

  @override
  Future<void> stopListening() async {
    await _speechToText.stop();
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