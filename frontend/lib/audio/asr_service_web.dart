import 'package:frontend/audio/asr_service_interface.dart';

class ASRServiceWeb implements ASRServiceInterface {
  @override
  Future<void> init() async {
    // Web Speech API initialization
  }

  @override
  Future<bool> hasPermission() async {
    // Web permissions are handled differently
    return false;
  }

  @override
  Future<String?> startListening(String languageCode) async {
    // Web Speech API listening
    return null;
  }

  @override
  Future<void> stopListening() async {
    // Stop web listening
  }

  @override
  bool isListening() {
    return false;
  }

  @override
  bool isSupported() {
    // Check if Web Speech API is available
    return false; // For now, assume not fully supported for recording
  }

  @override
  String? get lastError => 'Web ASR not fully implemented.';

  @override
  String? get lastRecognizedWords => null;
}

ASRServiceInterface getASRService() => ASRServiceWeb();