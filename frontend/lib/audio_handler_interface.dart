import 'dart:typed_data';

abstract class AudioHandlerInterface {
  Future<void> init();
  Future<bool> hasPermission();
  Future<void> startRecording(String filePath);
  Future<String?> stopRecording();
  Future<void> dispose();
  bool isRecording();
  bool isSupported(); // Indicates if recording is supported on this platform
}
