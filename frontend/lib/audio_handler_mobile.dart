import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/audio_handler_interface.dart';

class AudioHandlerMobile implements AudioHandlerInterface {
  FlutterSoundRecorder? _recorder;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (!_isInitialized) {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isInitialized = true;
    }
  }

  @override
  Future<bool> hasPermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isPermanentlyDenied) {
      // If permission is permanently denied, direct user to app settings
      await openAppSettings();
      return false;
    }
    // Request permission if not already granted or denied
    status = await Permission.microphone.request();
    print('Microphone permission status: $status'); // Debug print
    return status.isGranted;
  }

  @override
  Future<void> startRecording(String filePath) async {
    if (_recorder == null || !_isInitialized) {
      await init();
    }
    await _recorder!.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
    );
  }

  @override
  Future<String?> stopRecording() async {
    return await _recorder!.stopRecorder();
  }

  @override
  Future<void> dispose() async {
    if (_isInitialized) {
      await _recorder!.closeRecorder();
      _recorder = null;
      _isInitialized = false;
    }
  }

  @override
  bool isRecording() {
    return _recorder?.isRecording ?? false;
  }

  @override
  bool isSupported() {
    return true; // Supported on mobile platforms
  }
}

AudioHandlerInterface getAudioHandler() => AudioHandlerMobile();
