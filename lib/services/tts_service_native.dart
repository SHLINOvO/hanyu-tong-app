import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:edge_tts/edge_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 封装 Edge TTS + audioplayers，提供简洁的中文语音播放接口。
///
/// 用法：
/// ```dart
/// final tts = TtsService();
/// await tts.speak('你好');   // 播放
/// await tts.stop();          // 停止
/// tts.dispose();             // 释放资源
/// ```
class TtsService {
  // 中文女声（Microsoft Edge 神经语音，自然度很高）
  static const String _defaultVoice = 'zh-CN-XiaoxiaoNeural';

  final AudioPlayer _player = AudioPlayer();

  /// 上一次播放的文本，用于去重（快速连点同一个词不重复请求）
  String? _lastSpokenText;
  DateTime? _lastSpeakTime;

  TtsService() {
    // 播放完成后的回调
    _player.onPlayerComplete.listen((_) {
      _lastSpokenText = null;
    });
  }

  /// 播放中文语音
  ///
  /// [text] 要朗读的中文文本
  /// [voice] 可选自定义语音（默认 zh-CN-XiaoxiaoNeural）
  /// [rate] 语速偏移，格式 '+0%'（范围 -50% ~ +100%）
  Future<void> speak(
    String text, {
    String voice = _defaultVoice,
    String rate = '-10%',
  }) async {
    if (text.trim().isEmpty) return;

    // 去重：200ms 内重复点击同一个文本不重复请求
    final now = DateTime.now();
    if (_lastSpokenText == text &&
        _lastSpeakTime != null &&
        now.difference(_lastSpeakTime!).inMilliseconds < 200) {
      return;
    }
    _lastSpokenText = text;
    _lastSpeakTime = now;

    try {
      debugPrint('🔊 TTS 开始: text="$text", voice=$voice');

      // 1. 通过 Edge TTS 获取 MP3 字节数据
      final bytes = await Communicate(
        text: text,
        voice: voice,
        rate: rate,
      ).toBytes();

      debugPrint('🔊 TTS 获取音频成功: ${bytes.length} bytes');

      // 2. 写入临时文件
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/tts_${now.millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(bytes);

      debugPrint('🔊 TTS 临时文件: ${file.path}');

      // 3. 播放
      await _player.play(DeviceFileSource(file.path));

      debugPrint('🔊 TTS 播放已触发');

      // 4. 播放完毕后删除临时文件（延迟清理）
      _player.onPlayerComplete.first.whenComplete(() {
        try {
          file.deleteSync();
        } catch (_) {}
      });
    } catch (e, stackTrace) {
      // 打印错误日志，方便调试
      debugPrint('🔊 TTS 播放失败: $e');
      debugPrint('🔊 TTS stackTrace: $stackTrace');
      _lastSpokenText = null;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    await _player.stop();
    _lastSpokenText = null;
  }

  /// 释放资源
  void dispose() {
    _player.dispose();
  }
}
