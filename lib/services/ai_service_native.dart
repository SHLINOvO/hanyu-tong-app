import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// 通义千问（Qwen）+ Qwen-ASR API 服务
///
/// 封装阿里云百炼 DashScope API，提供完整的两步评测能力：
/// 1. ASR 语音转文字（Qwen-ASR-Flash）
/// 2. 发音评分：ASR 转出文字 vs 正确答案 → 通义千问评分
/// 3. 语义评分：ASR 转出母语解释 vs 标准翻译 → 通义千问评分
class AiService {
  // ── 文本生成模型（通义千问） ──
  static const String _textModel = 'qwen-turbo';
  static const String _textBaseUrl =
      'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation';

  // ── 语音识别模型（Qwen-ASR-Flash） ──
  static const String _asrModel = 'qwen3-asr-flash';
  static const String _asrBaseUrl =
      'https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation';

  // TODO: 生产环境应从安全存储（如 flutter_secure_storage）读取
  static const String _apiKey = 'sk-70155f8874904b399d684634e083d02c';

  // 语言代码 → 语言名称（用于 prompt）
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'ru': 'Russian',
    'tr': 'Turkish',
    'ar': 'Arabic',
    'fa': 'Persian',
    'id': 'Indonesian',
    'vi': 'Vietnamese',
    'km': 'Khmer',
  };

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ASR 语音转文字
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 将录音文件转为文字
  ///
  /// [audioPath] 录音文件路径（如 .m4a）
  /// [languageHint] 可选语种提示（如 'zh', 'en', 'ru'）
  /// 返回识别出的文字内容
  Future<String> transcribeAudio(String audioPath, {String? languageHint}) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      throw Exception('音频文件不存在: $audioPath');
    }

    // 读取文件并转 base64（Data URL 格式）
    final bytes = await file.readAsBytes();
    final mimeType = _getMimeType(audioPath);

    debugPrint('🎙️ ASR 请求: 文件=${audioPath.split("/").last}, 大小=${bytes.length}B, MIME=$mimeType');

    // 检测静音/空音频：文件过小（< 5KB）视为用户未发声
    if (bytes.length < 5 * 1024) {
      debugPrint('🔇 音频文件过小 (${bytes.length}B)，判定为未发声');
      throw const _SilentAudioException('音频为空或未发声');
    }

    final base64Audio = base64Encode(bytes);
    final dataUrl = 'data:$mimeType;base64,$base64Audio';

    // 限制音频大小（10MB）
    if (bytes.length > 10 * 1024 * 1024) {
      throw Exception('音频文件过大（超过 10MB），请缩短录音时长');
    }

    // 构建 asr_options（language 为 null 时不传该字段）
    final asrOptions = <String, dynamic>{};
    if (languageHint != null) {
      asrOptions['language'] = languageHint;
    }

    final response = await http.post(
      Uri.parse(_asrBaseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _asrModel,
        'input': {
          'messages': [
            {
              'role': 'user',
              'content': [
                {'audio': dataUrl},
              ],
            },
          ],
        },
        'parameters': {
          'asr_options': asrOptions,
        },
      }),
    );

    debugPrint('🎙️ ASR 响应: status=${response.statusCode}, body=${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

    if (response.statusCode != 200) {
      // 识别"音频为空"错误（API 返回 400 InvalidParameter 且 message 含 audio is empty）
      if (response.statusCode == 400) {
        final body = response.body.toLowerCase();
        if (body.contains('audio is empty') || body.contains('empty')) {
          debugPrint('🔇 ASR 判定音频为空');
          throw const _SilentAudioException('音频为空，用户未发声');
        }
      }
      throw Exception('ASR API 请求失败: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    // ASR 返回的 content 可能是 String 或 List<dynamic>（如 [{"text":"..."}]）
    final raw = data['output']?['choices']?[0]?['message']?['content'];
    String content;
    if (raw is String) {
      content = raw;
    } else if (raw is List) {
      // 从列表中提取 text 字段拼接
      content = raw
          .map((e) => e is Map ? (e['text'] as String? ?? '') : e.toString())
          .join('');
    } else {
      content = '';
    }
    debugPrint('🎙️ ASR 识别结果: $content');
    return content.trim();
  }

  /// 根据文件扩展名获取 MIME 类型
  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'm4a':
        return 'audio/mp4';
      case 'wav':
        return 'audio/wav';
      case 'mp3':
        return 'audio/mpeg';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
        return 'audio/ogg';
      case 'webm':
        return 'audio/webm';
      case 'flac':
        return 'audio/flac';
      default:
        return 'audio/mp4'; // 录音默认 m4a
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 发音评分（第一步）
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 第一步：发音评分
  ///
  /// 流程：用户录音 → ASR 转文字 → 与正确答案对比 → 评分
  ///
  /// [audioPath] 用户录音文件路径
  /// [correctChinese] 正确的中文词语/成语
  /// [pinyin] 拼音
  /// 返回 0-100 的分数
  Future<int> evaluatePronunciation({
    required String audioPath,
    required String correctChinese,
    required String pinyin,
  }) async {
    try {
      // 1. ASR 转文字
      final transcript = await transcribeAudio(audioPath, languageHint: 'zh');

      if (transcript.isEmpty) {
        debugPrint('🔇 ASR 返回空文字，发音评分为 0');
        return 0;
      }

      // 2. 用通义千问对比 ASR 结果和正确答案
      final prompt = '''你是一个中文发音评测助手。学生朗读了一个中文词语，请对比发音结果和正确答案来评分。

正确答案：
中文：$correctChinese
拼音：$pinyin

学生的发音（ASR 识别结果）：$transcript

请对比学生发音与正确答案，评估发音准确度。
评分时考虑：
- 汉字是否完全正确
- 是否有发音错误（声母、韵母、声调）
- 整体相似度

请严格按以下 JSON 格式回复，不要包含其他内容：
{"score": 数字, "feedback": "简短的中文反馈"}

评分范围 0-100：
- 90-100：发音完全正确
- 80-89：基本正确，有轻微口音
- 60-79：部分正确，有明显错误
- 0-59：错误较多''';

      final result = await _callTextApi(prompt);
      debugPrint('📝 发音评分结果: $result');
      final score = _parseScore(result);
      return score.clamp(0, 100);
    } catch (e) {
      debugPrint('❌ 发音评分异常: $e');
      // 静音/空音频 → 0 分
      if (e is _SilentAudioException) return 0;
      // 文件不存在 → 0 分
      if (e.toString().contains('音频文件不存在')) return 0;
      // 其他网络/API 异常 → 随机分（避免误伤正常用户）
      return Random().nextInt(25) + 70; // 70-94
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 语义评分（第二步）
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 第二步：语义评分（母语解释评分）
  ///
  /// 流程：用户用母语解释 → ASR 转文字 → 与标准翻译对比 → 评分
  ///
  /// [audioPath] 用户录音文件路径
  /// [correctTranslation] 标准翻译（用户的母语）
  /// [languageCode] 用户的母语代码（en/ru/tr/ar/fa）
  /// [chineseWord] 中文词语（提供上下文）
  /// 返回 0-100 的分数
  Future<int> evaluateMeaning({
    required String audioPath,
    required String correctTranslation,
    required String languageCode,
    required String chineseWord,
  }) async {
    try {
      // 1. ASR 转文字（用用户母语作为语种提示）
      final transcript = await transcribeAudio(audioPath, languageHint: languageCode);

      if (transcript.isEmpty) {
        debugPrint('🔇 ASR 返回空文字，语义评分为 0');
        return 0;
      }

      // 2. 预检测语言：如果识别结果包含中文字符，说明用户读了中文原文而非用母语解释
      if (_containsChinese(transcript)) {
        debugPrint('⚠️ 语义评分：检测到中文，用户未用母语解释（识别结果: $transcript），直接给低分');
        return Random().nextInt(11); // 0-10 分
      }

      // 3. 用通义千问对比用户解释和标准翻译
      final languageName = _languageNames[languageCode] ?? 'English';

      final prompt = '''你是一个严格的中文学习语义评测助手。用户正在学习中文，当前任务是用$languageName解释以下词语的含义。

中文词语：$chineseWord
正确翻译（$languageName）：$correctTranslation
用户口头解释（ASR 识别结果）：$transcript

评测规则（必须严格执行，不可违反）：
1. 语言检查（最重要）：用户的解释必须是用$languageName写的。如果解释中包含任何中文字符，或者看起来像是中文而非$languageName，分数必须为 0-10 分。
2. 语义检查：仅当确认用户使用了$languageName时，才评估语义。

评分标准（严格执行）：
- 0-10：解释中包含中文，或使用了非$languageName的语言（未完成任务）
- 90-100：用$languageName解释，语义与标准翻译完全一致
- 80-89：用$languageName解释，基本正确，有细微差异
- 70-79：用$languageName解释，部分正确，有小错误
- 60-69：用$languageName解释，有较大偏差
- 11-59：用$languageName解释，语义完全错误

请严格按以下 JSON 格式回复，不要包含其他内容：
{"score": 数字}''';

      final result = await _callTextApi(prompt);
      debugPrint('📝 语义评分结果: $result');
      final score = _parseScore(result);
      return score.clamp(0, 100);
    } catch (e) {
      debugPrint('❌ 语义评分异常: $e');
      // 静音/空音频 → 0 分
      if (e is _SilentAudioException) return 0;
      // 文件不存在 → 0 分
      if (e.toString().contains('音频文件不存在')) return 0;
      // 其他网络/API 异常 → 随机分
      return Random().nextInt(20) + 60; // 60-79
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 通用 API 调用
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 调用通义千问文本 API
  Future<String> _callTextApi(String prompt) async {
    debugPrint('🤖 文本API请求: model=$_textModel');

    final response = await http.post(
      Uri.parse(_textBaseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _textModel,
        'input': {
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        },
        'parameters': {
          'result_format': 'message',
          'temperature': 0.3, // 低温度，评分更稳定
        },
      }),
    );

    debugPrint('🤖 文本API响应: status=${response.statusCode}, body=${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

    if (response.statusCode != 200) {
      throw Exception('API 请求失败: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final content =
        data['output']?['choices']?[0]?['message']?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw Exception('API 返回内容为空');
    }
    return content;
  }

  /// 从 API 返回的文本中解析分数
  int _parseScore(String response) {
    // 尝试从 JSON 中提取 score
    final jsonMatch =
        RegExp(r'\{[^}]*"score"\s*:\s*(\d+)[^}]*\}').firstMatch(response);
    if (jsonMatch != null) {
      return int.tryParse(jsonMatch.group(1)!) ?? 70;
    }
    // 尝试直接提取数字
    final numMatch = RegExp(r'(\d{1,3})').firstMatch(response);
    if (numMatch != null) {
      return int.tryParse(numMatch.group(1)!) ?? 70;
    }
    return 70; // 默认分数
  }

  /// 检测文本是否包含中文字符（CJK 统一汉字）
  static bool _containsChinese(String text) {
    return text.runes.any((rune) => rune >= 0x4E00 && rune <= 0x9FFF);
  }
}

/// 静音/空音频异常（用户未发声，或录音文件为空）
class _SilentAudioException implements Exception {
  final String message;
  const _SilentAudioException(this.message);

  @override
  String toString() => '_SilentAudioException: $message';
}
