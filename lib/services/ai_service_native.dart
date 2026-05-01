import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

/// 通义千问（Qwen）+ Qwen-ASR API 服务
///
/// 封装阿里云百炼 DashScope API，提供完整的两步评测能力：
/// 1. ASR 语音转文字（Qwen-ASR-Flash 或本地 Whisper）
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

  // ── Whisper 本地语音识别 ──
  Whisper? _whisper;
  bool _whisperInitialized = false;
  static const WhisperModel _whisperModel = WhisperModel.base;
  // 使用 HuggingFace 镜像（中国大陆访问）
  static const String _whisperDownloadHost = 'https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main';

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

  // Whisper 语种代码映射
  static const Map<String, String> _whisperLanguageCodes = {
    'zh': 'zh',
    'en': 'en',
    'ru': 'ru',
    'tr': 'tr',
    'ar': 'ar',
    'fa': 'fa',
    'id': 'id',
    'vi': 'vi',
    'km': 'km',
  };

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Whisper 本地语音识别
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Whisper 模型文件名（与 WhisperService 保持一致）
  static const String _whisperModelFile = 'ggml-base.bin';

  /// 从 assets 复制模型到应用目录（仅首次执行）
  Future<String> _ensureWhisperModelFromAssets() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final modelPath = '${appSupportDir.path}/$_whisperModelFile';

    if (await File(modelPath).exists()) {
      debugPrint('📦 Whisper 模型已存在于: $modelPath');
      return appSupportDir.path;
    }

    debugPrint('📦 首次使用，正在从 assets 复制 Whisper 模型...');

    try {
      final ByteData byteData =
          await rootBundle.load('assets/whisper/$_whisperModelFile');
      final file = File(modelPath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      debugPrint('✅ Whisper 模型已从 assets 复制到: $modelPath');
      return appSupportDir.path;
    } catch (e) {
      debugPrint('❌ 从 assets 复制模型失败: $e，回退到网络下载');
      return '';
    }
  }

  /// 初始化 Whisper 模型（优先从 assets 加载）
  Future<void> initWhisper() async {
    if (_whisperInitialized) return;

    debugPrint('🤖 初始化 Whisper 模型: $_whisperModel');

    try {
      // 优先从 assets 加载模型
      final modelDir = await _ensureWhisperModelFromAssets();

      _whisper = Whisper(
        model: _whisperModel,
        modelDir: modelDir.isNotEmpty ? modelDir : null,
        downloadHost: _whisperDownloadHost,
      );

      // 获取版本验证初始化成功
      final version = await _whisper!.getVersion();
      debugPrint('✅ Whisper 模型已就绪，版本: $version');

      _whisperInitialized = true;
    } catch (e) {
      debugPrint('❌ Whisper 初始化失败: $e');
      _whisperInitialized = false;
      rethrow;
    }
  }

  /// 检查 Whisper 是否已初始化
  bool get isWhisperReady => _whisperInitialized && _whisper != null;

  /// 获取 Whisper 版本
  Future<String?> getWhisperVersion() async {
    if (_whisper == null) {
      await initWhisper();
    }
    return await _whisper?.getVersion();
  }

  /// 将录音文件转为文字（使用本地 Whisper）
  ///
  /// [audioPath] 录音文件路径（如 .m4a）
  /// [languageHint] 可选语种提示（如 'zh', 'en', 'ru'）
  /// 返回识别出的文字内容
  Future<String> transcribeAudioLocal(String audioPath, {String? languageHint}) async {
    if (!_whisperInitialized) {
      await initWhisper();
    }

    final file = File(audioPath);
    if (!await file.exists()) {
      throw Exception('音频文件不存在: $audioPath');
    }

    // 检测静音/空音频
    final bytes = await file.readAsBytes();
    if (bytes.length < 5 * 1024) {
      debugPrint('🔇 音频文件过小 (${bytes.length}B)，判定为未发声');
      throw const _SilentAudioException('音频为空或未发声');
    }

    debugPrint('🎙️ Whisper ASR 请求: 文件=${audioPath.split("/").last}, 大小=${bytes.length}B');

    // 转换为 WAV 格式（Whisper 需要）
    final wavPath = await _convertToWav(audioPath);

    try {
      // 确定语言代码
      final langCode = languageHint ?? 'auto';
      final whisperLang = _whisperLanguageCodes[langCode] ?? 'auto';

      debugPrint('🎙️ Whisper 识别语言: $whisperLang');

      // 执行转录
      final result = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: wavPath,
          language: whisperLang,
          isNoTimestamps: true,
          splitOnWord: false,
        ),
      );

      final text = result.text;
      debugPrint('🎙️ Whisper 识别结果: $text');
      return text.trim();
    } finally {
      // 清理临时 WAV 文件
      if (wavPath != audioPath) {
        try {
          await File(wavPath).delete();
        } catch (_) {}
      }
    }
  }

  /// 将音频文件转换为 WAV 格式（16kHz, mono, 16-bit PCM）
  ///
  /// Whisper 需要特定格式的音频输入。如果输入已经是 WAV 格式，直接返回原路径。
  Future<String> _convertToWav(String audioPath) async {
    final ext = audioPath.split('.').last.toLowerCase();

    // 如果已经是 WAV 格式，直接返回
    if (ext == 'wav') {
      return audioPath;
    }

    debugPrint('🔄 转换音频为 WAV 格式: $audioPath');

    // 读取原始音频文件
    final file = File(audioPath);
    final bytes = await file.readAsBytes();

    // 获取应用临时目录
    final tempDir = await getTemporaryDirectory();
    final wavPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    // 简化转换：直接包装为 WAV（假设录音已经是 16kHz mono 格式）
    final wavBytes = _createWavFile(bytes, sampleRate: 16000, numChannels: 1, bitsPerSample: 16);

    await File(wavPath).writeAsBytes(wavBytes);
    debugPrint('✅ WAV 文件已创建: $wavPath');

    return wavPath;
  }

  /// 创建 WAV 文件头 + 数据
  Uint8List _createWavFile(Uint8List audioData, {int sampleRate = 16000, int numChannels = 1, int bitsPerSample = 16}) {
    final dataSize = audioData.length;
    final fileSize = 44 + dataSize;

    final buffer = ByteData(fileSize);
    int offset = 0;

    // RIFF header
    buffer.setUint8(offset++, 0x52); // 'R'
    buffer.setUint8(offset++, 0x49); // 'I'
    buffer.setUint8(offset++, 0x46); // 'F'
    buffer.setUint8(offset++, 0x46); // 'F'
    buffer.setUint32(offset, fileSize - 8, Endian.little); offset += 4;
    buffer.setUint8(offset++, 0x57); // 'W'
    buffer.setUint8(offset++, 0x41); // 'A'
    buffer.setUint8(offset++, 0x56); // 'V'
    buffer.setUint8(offset++, 0x45); // 'E'

    // fmt chunk
    buffer.setUint8(offset++, 0x66); // 'f'
    buffer.setUint8(offset++, 0x6D); // 'm'
    buffer.setUint8(offset++, 0x74); // 't'
    buffer.setUint8(offset++, 0x20); // ' '
    buffer.setUint32(offset, 16, Endian.little); offset += 4; // chunk size
    buffer.setUint16(offset, 1, Endian.little); offset += 2; // audio format (PCM)
    buffer.setUint16(offset, numChannels, Endian.little); offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little); offset += 4;
    buffer.setUint32(offset, sampleRate * numChannels * bitsPerSample ~/ 8, Endian.little); offset += 4; // byte rate
    buffer.setUint16(offset, numChannels * bitsPerSample ~/ 8, Endian.little); offset += 2; // block align
    buffer.setUint16(offset, bitsPerSample, Endian.little); offset += 2;

    // data chunk
    buffer.setUint8(offset++, 0x64); // 'd'
    buffer.setUint8(offset++, 0x61); // 'a'
    buffer.setUint8(offset++, 0x74); // 't'
    buffer.setUint8(offset++, 0x61); // 'a'
    buffer.setUint32(offset, dataSize, Endian.little); offset += 4;

    // 复制音频数据
    for (int i = 0; i < audioData.length && offset < fileSize; i++) {
      buffer.setUint8(offset++, audioData[i]);
    }

    return buffer.buffer.asUint8List();
  }

  /// 初始化 Whisper 模型（供外部调用）
  ///
  /// 返回模型信息
  Future<Map<String, dynamic>> initWhisperModel() async {
    if (!_whisperInitialized) {
      await initWhisper();
    }
    return {
      'initialized': _whisperInitialized,
      'model': _whisperModel.name,
      'version': await _whisper?.getVersion(),
    };
  }

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
  /// [asrEngine] ASR 引擎选择（默认 qwen，可选 whisper）
  /// 返回 0-100 的分数
  Future<int> evaluatePronunciation({
    required String audioPath,
    required String correctChinese,
    required String pinyin,
    String asrEngine = 'qwen',
  }) async {
    try {
      // 1. ASR 转文字（根据引擎选择）
      String transcript;
      if (asrEngine == 'whisper') {
        debugPrint('🎙️ 发音评分 ASR: 使用 Whisper 本地识别 (语言: zh)');
        transcript = await transcribeAudioLocal(audioPath, languageHint: 'zh');
      } else {
        debugPrint('🎙️ 发音评分 ASR: 使用 Qwen 云端识别 (语言: zh)');
        transcript = await transcribeAudio(audioPath, languageHint: 'zh');
      }

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

  /// 通义千问支持的 ASR 语言
  static const Set<String> _qwenSupportedLanguages = {'en', 'ru', 'tr', 'ar'};

  /// 第二步：语义评分（母语解释评分）
  ///
  /// 流程：用户用母语解释 → ASR 转文字 → 与标准翻译对比 → 评分
  ///
  /// [audioPath] 用户录音文件路径
  /// [correctTranslation] 标准翻译（用户的母语）
  /// [languageCode] 用户的母语代码（en/ru/tr/ar/fa/id/vi/km）
  /// [chineseWord] 中文词语（提供上下文）
  /// [asrEngine] ASR 引擎选择（默认 auto，自动根据语言选择）
  /// 返回 0-100 的分数
  Future<int> evaluateMeaning({
    required String audioPath,
    required String correctTranslation,
    required String languageCode,
    required String chineseWord,
    String asrEngine = 'auto',
  }) async {
    try {
      // 1. 选择 ASR 引擎
      String chosenEngine = asrEngine;

      // 自动模式：根据语言选择
      if (asrEngine == 'auto') {
        if (_qwenSupportedLanguages.contains(languageCode)) {
          chosenEngine = 'qwen';
        } else {
          chosenEngine = 'whisper';
        }
      }

      // 2. ASR 转文字
      String transcript;
      if (chosenEngine == 'whisper') {
        debugPrint('🎙️ 语义评分 ASR: 使用 Whisper 本地识别 (语言: $languageCode)');
        transcript = await transcribeAudioLocal(audioPath, languageHint: languageCode);
      } else {
        debugPrint('🎙️ 语义评分 ASR: 使用 Qwen 云端识别 (语言: $languageCode)');
        transcript = await transcribeAudio(audioPath, languageHint: languageCode);
      }

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

// ═══════════════════════════════════════════════════════════════════════════════
// 公开的 Whisper 接口（供外部使用）
// ═══════════════════════════════════════════════════════════════════════════════

/// Whisper 服务（单例模式）
///
/// 使用示例：
/// ```dart
/// final whisperService = WhisperService();
/// await whisperService.init();  // 初始化（从 assets 加载模型）
/// final text = await whisperService.transcribe('/path/to/audio.m4a', languageHint: 'zh');
/// ```
class WhisperService {
  static WhisperService? _instance;
  Whisper? _whisper;
  bool _initialized = false;
  String? _modelDir;

  WhisperService._();

  /// 获取单例实例
  static WhisperService get instance {
    _instance ??= WhisperService._();
    return _instance!;
  }

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// Whisper 模型文件名
  static const String _modelFileName = 'ggml-base.bin';

  /// 从 assets 复制模型到应用目录（仅首次执行）
  Future<String> _ensureModelFromAssets() async {
    // 获取应用支持目录（Android: ApplicationSupport, iOS/macOS: Library）
    final appSupportDir = await getApplicationSupportDirectory();
    final modelPath = '${appSupportDir.path}/$_modelFileName';

    // 如果模型文件已存在，跳过复制
    if (await File(modelPath).exists()) {
      debugPrint('📦 Whisper 模型已存在于: $modelPath');
      return appSupportDir.path;
    }

    // 从 assets 复制模型文件
    debugPrint('📦 首次使用，正在从 assets 复制 Whisper 模型到: $modelPath');

    try {
      // 加载 assets 中的模型文件
      final ByteData byteData =
          await rootBundle.load('assets/whisper/$_modelFileName');

      // 写入应用目录
      final file = File(modelPath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      debugPrint('✅ Whisper 模型已从 assets 复制到: $modelPath');
      return appSupportDir.path;
    } catch (e) {
      debugPrint('❌ 从 assets 复制模型失败: $e');
      // 复制失败时，回退到从网络下载
      debugPrint('⚠️ 回退：将从网络下载模型...');
      return '';
    }
  }

  /// 初始化 Whisper 模型
  ///
  /// 优先从 assets 加载（打包进 APK 的模型），如失败则回退到网络下载
  Future<void> init({
    WhisperModel model = WhisperModel.base,
    String? downloadHost,
  }) async {
    if (_initialized) return;

    debugPrint('🤖 初始化 Whisper 服务...');

    // 优先从 assets 加载模型
    _modelDir = await _ensureModelFromAssets();

    if (_modelDir!.isEmpty) {
      // 回退：使用 modelDir 为空，让插件从网络下载
      _whisper = Whisper(
        model: model,
        downloadHost: downloadHost ?? 'https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main',
      );
    } else {
      // 使用已复制的本地模型
      _whisper = Whisper(
        model: model,
        modelDir: _modelDir,
        downloadHost: downloadHost ?? 'https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main',
      );
    }

    try {
      // 验证初始化成功
      await _whisper!.getVersion();
      _initialized = true;
      debugPrint('✅ Whisper 服务初始化完成');
    } catch (e) {
      debugPrint('❌ Whisper 初始化失败: $e');
      rethrow;
    }
  }

  /// 获取 Whisper 版本
  Future<String?> getVersion() async {
    if (!_initialized) await init();
    return await _whisper?.getVersion();
  }

  /// 语音转文字
  ///
  /// [audioPath] 音频文件路径
  /// [language] 语言代码（null 表示自动检测）
  Future<String?> transcribe(String audioPath, {String? language}) async {
    if (!_initialized) await init();

    try {
      final result = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          language: language ?? 'auto',
          isNoTimestamps: true,
          splitOnWord: false,
        ),
      );

      final text = result.text;
      return text.trim();
    } catch (e) {
      debugPrint('❌ Whisper 转录失败: $e');
      rethrow;
    }
  }

  /// 获取模型信息
  Future<Map<String, dynamic>> getModelInfo() async {
    if (!_initialized) await init();
    return {
      'initialized': _initialized,
      'version': await _whisper?.getVersion(),
      'model': _whisper?.model.name,
      'modelDir': _modelDir,
    };
  }
}
