import 'package:frontend/audio_handler_interface.dart';

class AudioHandlerWeb implements AudioHandlerInterface {
  @override
  Future<void> init() async {
    // Web recording might require specific setup
  }

  @override
  Future<bool> hasPermission() async {
    // Web permissions are handled differently
    return false; 
  }

  @override
  Future<void> startRecording(String filePath) async {
    // Web recording implementation (e.g., MediaRecorder)
  }

  @override
  Future<String?> stopRecording() async {
    return null;
  }

  @override
  Future<void> dispose() async {
    // Clean up web resources
  }

  @override
  bool isRecording() {
    return false;
  }

  @override
  bool isSupported() {
    // Set to true if web recording is fully implemented, false otherwise
    return false; // For now, assume recording is not fully supported on web
  }
}

AudioHandlerInterface getAudioHandler() => AudioHandlerWeb();
