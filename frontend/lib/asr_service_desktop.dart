import 'package:frontend/asr_service_interface.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:typed_data';

class ASRServiceDesktop implements ASRServiceInterface {
  String? _lastError;
  String? _lastRecognizedWords;
  bool _isListening = false;

  @override
  Future<void> init() async {
    // No specific initialization needed for desktop ASR as it relies on backend
  }

  @override
  Future<bool> hasPermission() async {
    // Permissions for microphone are handled by the OS, not directly by Flutter on desktop
    return true; // Assume permission is handled externally or not strictly required by Flutter
  }

  @override
  Future<String?> startListening(String languageCode) async {
    // For desktop, we will send recorded audio to backend for ASR
    // This method will not directly start listening, but will be called after audio is recorded
    _lastError = 'Desktop ASR requires recorded audio to be sent to backend.';
    return null;
  }

  @override
  Future<void> stopListening() async {
    // No direct stop listening as it's a backend call
  }

  @override
  bool isListening() {
    return _isListening;
  }

  @override
  bool isSupported() {
    return true; // Supported via backend
  }

  @override
  String? get lastError => _lastError;

  @override
  String? get lastRecognizedWords => _lastRecognizedWords;

  // New method to transcribe audio bytes via backend
  Future<String?> transcribeAudioBytes(Uint8List audioBytes) async {
    _isListening = true;
    _lastError = null;
    _lastRecognizedWords = null;
    try {
      final response = await ApiService.instance.transcribeAudio(audioBytes.toList());
      _lastRecognizedWords = response['transcribed_text'];
      return _lastRecognizedWords;
    } catch (e) {
      _lastError = e.toString();
      return null;
    } finally {
      _isListening = false;
    }
  }
}

ASRServiceInterface getASRService() => ASRServiceDesktop();