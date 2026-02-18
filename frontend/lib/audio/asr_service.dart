import 'package:frontend/audio/asr_service_interface.dart';

export 'package:frontend/audio/asr_service_desktop.dart' // Default for desktop (macOS, Windows, Linux)
    if (dart.library.io) 'package:frontend/audio/asr_service_mobile.dart' // For mobile (iOS, Android)
    if (dart.library.html) 'package:frontend/audio/asr_service_web.dart'; // For web

// The actual getASRService function will be provided by one of the exported files.
// This file itself does not define it, but rather exports it from the correct platform-specific file.