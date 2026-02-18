import 'package:frontend/audio/audio_handler_interface.dart';

export 'package:frontend/audio/audio_handler_desktop.dart' // Default for desktop (macOS, Windows, Linux)
    if (dart.library.io) 'package:frontend/audio/audio_handler_mobile.dart' // For mobile (iOS, Android)
    if (dart.library.html) 'package:frontend/audio/audio_handler_web.dart'; // For web

// The actual getAudioHandler function will be provided by one of the exported files.
// This file itself does not define it, but rather exports it from the correct platform-specific file.

