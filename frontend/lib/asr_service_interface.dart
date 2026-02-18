abstract class ASRServiceInterface {
  Future<void> init();
  Future<bool> hasPermission();
  Future<String?> startListening(String languageCode);
  Future<void> stopListening();
  bool isListening();
  bool isSupported(); // Indicates if ASR is supported on this platform
  String? get lastError;
  String? get lastRecognizedWords;
}