// Stub implementation for Web platform
// dart:io is not available on Web

class AiService {
  /// 将录音文件转为文字
  Future<String> transcribeAudio(String audioPath, {String? languageHint}) async {
    throw UnsupportedError('Audio transcription is not supported on Web');
  }

  /// 发音评分
  Future<int> evaluatePronunciation({
    required String audioPath,
    required String correctChinese,
    required String pinyin,
  }) async {
    throw UnsupportedError('Pronunciation evaluation is not supported on Web');
  }

  /// 语义评分
  Future<int> evaluateMeaning({
    required String audioPath,
    required String correctTranslation,
    required String languageCode,
    required String chineseWord,
  }) async {
    throw UnsupportedError('Meaning evaluation is not supported on Web');
  }
}
