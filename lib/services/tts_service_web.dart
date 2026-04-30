// Stub implementation for Web platform
// dart:io is not available on Web

import 'package:flutter/foundation.dart';

/// TTS Service stub for Web platform.
/// TTS playback is not supported on Web due to edge_tts dependency on dart:io.
class TtsService {
  /// Web stub: TTS is not supported on Web platform.
  Future<void> speak(
    String text, {
    String voice = 'zh-CN-XiaoxiaoNeural',
    String rate = '-10%',
  }) async {
    debugPrint('🔊 TTS (Web): Not supported, text="$text"');
  }

  /// Stop playback (stub).
  Future<void> stop() async {}

  /// Dispose (stub).
  void dispose() {}
}
