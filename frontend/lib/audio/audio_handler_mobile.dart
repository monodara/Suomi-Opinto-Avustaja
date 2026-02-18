import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/audio/audio_handler_interface.dart';

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
    var status = await Permission.microphone.status;

    // Request permission if it's denied or limited (iOS)
    if (status.isDenied || status.isLimited) {
      status = await Permission.microphone.request();
    }

    // Prompt the user to open app settings if permission is permanently denied
    if (status.isPermanentlyDenied) {
      print('Permission permanently denied, please enable it in settings');
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  @override
  Future<void> startRecording(String filePath) async {
    if (_recorder == null || !_isInitialized) {
      await init();
    }
    await _recorder!.startRecorder(toFile: filePath, codec: Codec.pcm16WAV);
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
