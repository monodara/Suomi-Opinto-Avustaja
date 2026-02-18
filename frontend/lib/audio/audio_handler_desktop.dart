import 'package:frontend/audio/audio_handler_interface.dart';

class AudioHandlerDesktop implements AudioHandlerInterface {
  @override
  Future<void> init() async {
    // Desktop recording might require specific setup or is not supported
  }

  @override
  Future<bool> hasPermission() async {
    return false; // No permission as recording is not supported
  }

  @override
  Future<void> startRecording(String filePath) async {
    // Not supported
  }

  @override
  Future<String?> stopRecording() async {
    return null; // No recording
  }

  @override
  Future<void> dispose() async {
    // Clean up resources if any
  }

  @override
  bool isRecording() {
    return false; // Never recording
  }

  @override
  bool isSupported() {
    return false; // Recording not supported on desktop
  }
}

AudioHandlerInterface getAudioHandler() => AudioHandlerDesktop();
