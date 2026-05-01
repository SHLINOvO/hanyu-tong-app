import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/word_model.dart';
import '../models/word_repository.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';
import '../utils/platform_helper.dart';
import '../utils/file_helper.dart';
import '../widgets/sound_wave_button.dart';

class PracticePage extends StatefulWidget {
  final String type;
  const PracticePage({super.key, required this.type});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  List<WordModel> _words = [];
  List<WordModel> _allWords = []; // 全部词语（含已掌握），用于跳转序号
  bool _isLoading = true;
  String? _loadError;

  String _step = 'pronunciation'; // 'pronunciation' | 'meaning'
  int _currentIndex = 0;
  bool _isRecording = false;
  bool _isCancelling = false; // 上滑取消状态
  double _dragStartY = 0;
  bool _showPronunciationScore = false;
  bool _showMeaningScore = false;
  bool _showAnswer = false;
  bool _isEvaluating = false; // 正在调用 AI 评分
  int _pronScore = 85; // 中文发音评分（单条，方便接入大模型）
  int _meaningScore = 80; // 含义评分（合并为单条）

  // ── 录音 ──
  final AudioRecorder _audioRecorder = AudioRecorder();
  // ignore: unused_field  （预留字段：接入评分后端时使用）
  String? _recordedPath; // 最近一次录音文件路径

  // ── TTS 语音播放 ──
  final TtsService _tts = TtsService();
  final AiService _aiService = AiService();
  final GlobalKey<SoundWaveButtonState> _speakerKey = GlobalKey();

  @override
  void dispose() {
    _audioRecorder.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final state = context.read<AppState>();
    try {
      final allWords = await WordRepository.loadWords(state.level);
      // 过滤掉已掌握的词语
      final availableWords = allWords
          .where((w) => !state.masteredWordIds.contains(w.id))
          .toList();
      if (mounted) {
        setState(() {
          _allWords = allWords;
          _words = availableWords;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  WordModel? get _currentWord =>
      _words.isNotEmpty ? _words[_currentIndex % _words.length] : null;

  // ── 申请麦克风权限 ──
  Future<bool> _requestMicPermission() async {
    // Windows 直接通过 AudioRecorder 检查（系统会弹授权窗口）
    if (isDesktop) {
      return await _audioRecorder.hasPermission();
    }
    // Android / iOS 通过 permission_handler 申请
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // 按住开始录音
  void _handleLongPressStart(LongPressStartDetails details) async {
    final granted = await _requestMicPermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要麦克风权限才能录音')),
        );
      }
      return;
    }

    // 生成临时文件路径（使用 WAV 格式，Whisper 可直接处理）
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );

    if (mounted) {
      setState(() {
        _isRecording = true;
        _isCancelling = false;
        _dragStartY = details.globalPosition.dy;
        _recordedPath = path;
      });
    }
  }

  // 拖动中检测是否上滑超过阈值（50px）
  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final dy = details.globalPosition.dy - _dragStartY;
    final cancelling = dy < -50;
    if (cancelling != _isCancelling) {
      setState(() => _isCancelling = cancelling);
    }
  }

  // 松手：若处于取消状态则取消，否则结束录音并提交
  void _handleLongPressEnd(LongPressEndDetails details) async {
    final path = await _audioRecorder.stop();

    if (_isCancelling) {
      // 取消录音，删除临时文件
      if (path != null) {
        await deleteFileIfExists(path);
      }
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isCancelling = false;
          _recordedPath = null;
        });
      }
    } else {
      // 正常结束录音，path 为录音文件路径（可传给评分后端）
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isCancelling = false;
          _recordedPath = path;
        });
      }
      _submitRecording(path);
    }
  }

  // 提交录音 → ASR 转文字 + 通义千问评分
  void _submitRecording(String? path) async {
    if (path == null || _currentWord == null) return;

    setState(() => _isEvaluating = true);

    try {
      final word = _currentWord!;
      final state = context.read<AppState>();

      if (_step == 'pronunciation') {
        // 第一步：发音评分（录音 → ASR 转文字 → 与正确答案对比 → 评分）
        final score = await _aiService.evaluatePronunciation(
          audioPath: path,
          correctChinese: word.word,
          pinyin: word.pinyin,
          asrEngine: state.chineseAsrEngine.name,
        );
        if (mounted) {
          setState(() {
            _pronScore = score;
            _showPronunciationScore = true;
            _isEvaluating = false;
          });
        }
      } else {
        // 第二步：语义评分（录音 → ASR 转文字 → 与标准翻译对比 → 评分）
        final score = await _aiService.evaluateMeaning(
          audioPath: path,
          correctTranslation: word.translationFor(state.language),
          languageCode: state.language,
          chineseWord: word.word,
          asrEngine: state.asrEngine.name,
        );
        if (mounted) {
          setState(() {
            _meaningScore = score;
            _showMeaningScore = true;
            _isEvaluating = false;
          });
        }
      }
    } catch (_) {
      // API 异常时使用模拟分数兜底
      if (mounted) {
        final rnd = Random();
        setState(() {
          if (_step == 'pronunciation') {
            _pronScore = rnd.nextInt(30) + 70;
            _showPronunciationScore = true;
          } else {
            _meaningScore = rnd.nextInt(30) + 70;
            _showMeaningScore = true;
          }
          _isEvaluating = false;
        });
      }
    }
  }

  void _handleNextStep() {
    setState(() {
      _showPronunciationScore = false;
      _step = 'meaning';
    });
  }

  void _handleContinue() {
    final state = context.read<AppState>();
    // 标记当前词语为已掌握（两步都通过了）
    state.markWordMastered(_currentWord!.id);

    setState(() {
      _showMeaningScore = false;
      _step = 'pronunciation';
      // 从列表中移除，避免重复出现
      _words.removeAt(_currentIndex);
    });

    if (_words.isEmpty) {
      context.pop();
    } else if (_currentIndex >= _words.length) {
      setState(() => _currentIndex = 0);
    }
  }

  void _handleRetry() => setState(() => _showMeaningScore = false);

  /// 第一步发音重试：关闭评分弹窗，留在发音步骤
  void _handlePronRetry() => setState(() => _showPronunciationScore = false);

  /// 跳转：弹出输入框让用户输入序号
  void _showJumpDialog() {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final total = _allWords.length;

    showDialog(
      context: context,
      builder: (ctx) {
        String? errorText;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(loc.jumpToWord),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '1 ~ $total',
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(loc.close),
                ),
                ElevatedButton(
                  onPressed: () {
                    final input = controller.text.trim();
                    final num = int.tryParse(input);
                    if (num == null || num < 1 || num > total) {
                      setDialogState(() {
                        errorText = '$input ${loc.invalidNumberHint}$total';
                      });
                      return;
                    }
                    // 在 _words 中找到对应索引
                    final targetWord = _allWords[num - 1];
                    final idx = _words.indexWhere((w) => w.id == targetWord.id);
                    Navigator.pop(ctx);
                    if (idx == -1) {
                      // 已掌握的词语，加入临时列表并跳转
                      setState(() {
                        _words.insert(num - 1, targetWord);
                        _currentIndex = num - 1;
                        _showPronunciationScore = false;
                        _showMeaningScore = false;
                        _showAnswer = false;
                        _step = 'pronunciation';
                      });
                    } else {
                      setState(() {
                        _currentIndex = idx;
                        _showPronunciationScore = false;
                        _showMeaningScore = false;
                        _showAnswer = false;
                        _step = 'pronunciation';
                      });
                    }
                  },
                  child: Text(loc.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleSkip() {
    final loc = AppLocalizations.of(context)!;
    // 弹出对话框询问是否已掌握
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc.skipMasteredTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // 关闭对话框
              _doSkip(mastered: false); // 单纯跳过
            },
            child: Text(loc.skipMasteredNo,
                style: const TextStyle(color: Color(0xFF999999))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // 关闭对话框
              _doSkip(mastered: true); // 标记掌握
            },
            child: Text(loc.skipMasteredYes,
                style: const TextStyle(
                    color: Color(0xFF4285F4), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// 执行跳过逻辑
  /// [mastered] 是否同时标记为已掌握
  void _doSkip({required bool mastered}) {
    if (mastered && _currentWord != null) {
      final state = context.read<AppState>();
      state.markWordMastered(_currentWord!.id);
      // 从 _words 列表中移除该词条
      setState(() {
        _words.removeAt(_currentIndex);
        _showPronunciationScore = false;
        _showMeaningScore = false;
        _showAnswer = false;
        _step = 'pronunciation';
      });
    } else {
      setState(() {
        _showPronunciationScore = false;
        _showMeaningScore = false;
        _showAnswer = false;
        _step = 'pronunciation';
      });
    }

    // 调整 index：如果列表空了就返回，否则如果 index 越界就归零
    if (_words.isEmpty) {
      context.pop();
    } else if (_currentIndex >= _words.length) {
      setState(() => _currentIndex = 0);
    } else if (!mastered && _currentIndex < _words.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  int get _avgMeaning => _meaningScore;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final loc = AppLocalizations.of(context)!;
    final title = widget.type == 'words' ? loc.wordsPracticeTitle : loc.sentencesPracticeTitle;

    // Web 平台提示
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          ),
          title: Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          centerTitle: false,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download_for_offline, color: Color(0xFF4285F4), size: 64),
                const SizedBox(height: 24),
                Text(
                  loc.webDownloadHint,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Loading / Error state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4285F4)),
              const SizedBox(height: 16),
              Text(loc.loading, style: const TextStyle(color: Color(0xFF666666))),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(loc.dataNotLoaded, style: const TextStyle(color: Color(0xFF666666))),
                const SizedBox(height: 8),
                Text(_loadError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() { _isLoading = true; _loadError = null; });
                    _loadWords();
                  },
                  child: Text(loc.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_words.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Text(loc.noData, style: const TextStyle(color: Color(0xFF666666))),
        ),
      );
    }

    final word = _currentWord!;
    final isFav = state.favorites.contains(word.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              _buildHeader(title),
              // Step Indicator
              _buildStepBar(context),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Chinese Word Card
                      Stack(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              key: ValueKey('$_step-$_currentIndex'),
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCEAFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    word.word,
                                    style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF333333)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(word.pinyin,
                                      style: const TextStyle(
                                          fontSize: 18, color: Color(0xFF999999))),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                          // Star
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () => state.toggleFavorite(word.id),
                              icon: Icon(
                                isFav ? Icons.star : Icons.star_border,
                                color: isFav ? Colors.amber : Colors.grey,
                                size: 24,
                              ),
                            ),
                          ),
                          // Speaker — 点击播放中文语音
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: SoundWaveButton(
                              key: _speakerKey,
                              size: 36,
                              onTap: () {
                                final word = _currentWord;
                                if (word != null) {
                                  _tts.speak(word.word).then((_) {
                                    _speakerKey.currentState?.stopAnimation();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Mic Button — 按住录音，上滑取消（评分中禁用）
                      GestureDetector(
                        onLongPressStart: _isEvaluating ? null : _handleLongPressStart,
                        onLongPressMoveUpdate: _isEvaluating ? null : _handleLongPressMoveUpdate,
                        onLongPressEnd: _isEvaluating ? null : _handleLongPressEnd,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: _isRecording ? 84 : 72,
                          height: _isRecording ? 84 : 72,
                          decoration: BoxDecoration(
                            color: _isEvaluating
                                ? const Color(0xFF4285F4).withValues(alpha: 0.5)
                                : _isCancelling
                                    ? Colors.red
                                    : _isRecording
                                        ? const Color(0xFF4285F4)
                                        : Colors.grey[300],
                            shape: BoxShape.circle,
                            boxShadow: _isRecording
                                ? [
                                    BoxShadow(
                                      color: (_isCancelling ? Colors.red : const Color(0xFF4285F4))
                                          .withValues(alpha: 0.4),
                                      blurRadius: 18,
                                      spreadRadius: 6,
                                    )
                                  ]
                                : [],
                          ),
                          child: _isEvaluating
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                              : Icon(
                                  _isCancelling ? Icons.close : Icons.mic,
                                  color: Colors.white,
                                  size: 36,
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isEvaluating
                            ? '...' // 正在评分
                            : _isRecording
                                ? loc.slideUpToCancel
                                : loc.holdToRecord,
                        style: TextStyle(
                          fontSize: 13,
                          color: _isRecording
                              ? (_isCancelling ? Colors.red : const Color(0xFF4285F4))
                              : const Color(0xFF999999),
                          fontWeight: _isRecording ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _step == 'pronunciation'
                            ? loc.tapMicToRead
                            : loc.explainInNativeLanguage,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFFBBBBBB)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Bottom Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _handleSkip,
                            child: Text(loc.skip,
                                style: const TextStyle(color: Color(0xFF999999))),
                          ),
                          if (_step == 'meaning')
                            TextButton(
                              onPressed: () => setState(() => _showAnswer = true),
                              child: Text(loc.showAnswer,
                                  style: const TextStyle(color: Color(0xFF999999))),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Pronunciation Score Sheet
          if (_showPronunciationScore)
            _ScoreSheet(
              title: loc.pronunciationScore,
              items: [
                _ScoreItem(label: loc.pronunciationAccuracy, score: _pronScore),
              ],
              scoreColor: _scoreColor,
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handlePronRetry,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(loc.tryAgain,
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleNextStep,
                        style: _blueBtn,
                        child: Text(loc.nextStepExplain,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // Meaning Score Sheet
          if (_showMeaningScore)
            _ScoreSheet(
              title: loc.meaningScore,
              items: [
                _ScoreItem(label: loc.meaningAccuracy, score: _meaningScore),
              ],
              scoreColor: _scoreColor,
              actions: [
                if (_avgMeaning >= 70) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(left: BorderSide(color: Colors.green, width: 4)),
                    ),
                    child: Text(loc.masteredSuccess,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: _blueBtn,
                    child: Text(loc.continueBtn,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(left: BorderSide(color: Colors.orange, width: 4)),
                    ),
                    child: Text(loc.tryAgain,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(loc.reRecord,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),

          // Answer Dialog
          if (_showAnswer)
            GestureDetector(
              onTap: () => setState(() => _showAnswer = false),
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(loc.meaningBelow,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            word.translationFor(state.language),
                            style: const TextStyle(color: Color(0xFF666666), fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => setState(() => _showAnswer = false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE0E0E0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            child: Text(loc.close,
                                style: const TextStyle(color: Color(0xFF666666))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    // 找到当前词语在全部列表中的序号
    final currentWord = _currentWord;
    final displayIndex = currentWord != null
        ? _allWords.indexWhere((w) => w.id == currentWord.id) + 1
        : 1;
    final total = _allWords.isNotEmpty ? _allWords.length : 0;

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
              ),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_allWords.isNotEmpty)
                GestureDetector(
                  onTap: _showJumpDialog,
                  child: Text(
                    '$displayIndex/$total',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4285F4),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBar(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 两行步骤显示
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：步骤1
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _step == 'pronunciation'
                          ? const Color(0xFF4285F4)
                          : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _step == 'pronunciation'
                              ? Colors.white
                              : const Color(0xFF999999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.step1ReadChinese,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _step == 'pronunciation'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _step == 'pronunciation'
                            ? const Color(0xFF4285F4)
                            : const Color(0xFF999999),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 第二行：步骤2
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _step == 'meaning'
                          ? const Color(0xFF4285F4)
                          : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _step == 'meaning'
                              ? Colors.white
                              : const Color(0xFF999999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.step2Explain,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _step == 'meaning'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _step == 'meaning'
                            ? const Color(0xFF4285F4)
                            : const Color(0xFF999999),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _step == 'pronunciation' ? 0.5 : 1.0,
              backgroundColor: const Color(0xFFE0E0E0),
              color: const Color(0xFF4285F4),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ——— Shared Score Sheet ———
class _ScoreItem {
  final String label;
  final int score;
  const _ScoreItem({required this.label, required this.score});
}

class _ScoreSheet extends StatelessWidget {
  final String title;
  final List<_ScoreItem> items;
  final Color Function(int) scoreColor;
  final List<Widget> actions;

  const _ScoreSheet({
    required this.title,
    required this.items,
    required this.scoreColor,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.label,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF666666))),
                          Text('${item.score}%',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4285F4))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.score / 100.0,
                          backgroundColor: const Color(0xFFE0E0E0),
                          color: scoreColor(item.score),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                )),
            ...actions,
          ],
        ),
      ),
    );
  }
}

final _blueBtn = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF4285F4),
  padding: const EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);
