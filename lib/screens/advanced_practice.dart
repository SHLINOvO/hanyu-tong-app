import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import '../utils/platform_helper.dart';
import '../utils/file_helper.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/idiom_model.dart';
import '../models/idiom_repository.dart';
import '../models/proverb_model.dart';
import '../models/proverb_repository.dart';
import '../models/poetry_model.dart';
import '../models/poetry_repository.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';
import '../widgets/sound_wave_button.dart';

class AdvancedPractice extends StatefulWidget {
  final String type;
  const AdvancedPractice({super.key, required this.type});

  @override
  State<AdvancedPractice> createState() => _AdvancedPracticeState();
}

class _AdvancedPracticeState extends State<AdvancedPractice> {
  // 成语真实数据
  List<IdiomModel> _idioms = [];
  // 成语全部数据（含已掌握），用于跳转序号
  List<IdiomModel> _allIdioms = [];
  // 谚语真实数据
  List<ProverbModel> _proverbs = [];
  // 谚语全部数据（含已掌握），用于跳转序号
  List<ProverbModel> _allProverbs = [];
  // 诗词真实数据
  List<PoetryModel> _poems = [];
  bool _isLoading = true;
  String? _loadError;

  // 示例数据（诗词/文化，方便后续导入真实数据时替换）
  static const Map<String, List<Map<String, String>>> _sampleData = {
    'poetry': [
      {'word': '床前明月光', 'pinyin': 'chuáng qián míng yuè guāng', 'explanation': '出自李白《静夜思》。月光洒在床前的地上，好像铺了一层白霜。'},
      {'word': '举头望明月', 'pinyin': 'jǔ tóu wàng míng yuè', 'explanation': '出自李白《静夜思》。抬起头来，看到天上明亮的月亮。'},
      {'word': '春眠不觉晓', 'pinyin': 'chūn mián bù jué xiǎo', 'explanation': '出自孟浩然《春晓》。春天的夜晚睡得香甜，不知不觉天就亮了。'},
    ],
    'culture': [
      {'word': '春节', 'pinyin': 'chūn jié', 'explanation': '中国最重要的传统节日，农历正月初一，象征新的一年开始。'},
      {'word': '中秋节', 'pinyin': 'zhōng qiū jié', 'explanation': '农历八月十五，中国传统节日之一，象征团圆和丰收。'},
      {'word': '端午节', 'pinyin': 'duān wǔ jié', 'explanation': '农历五月初五，为纪念爱国诗人屈原而设，有赛龙舟、吃粽子等习俗。'},
    ],
  };

  String _step = 'pronunciation';
  int _currentIndex = 0;
  bool _isRecording = false;
  bool _isCancelling = false;
  double _dragStartY = 0;
  bool _showPronScore = false;
  bool _showMeaningScore = false;
  bool _showAnswer = false;
  bool _showChineseExplanation = false;
  bool _isEvaluating = false; // 正在调用 AI 评分
  bool _showPoetryChineseMeaning = false;
  bool _showPoetryNativeMeaning = false;
  /// 追踪每首诗词的释义查看状态 {poemId: {chinese: bool, native: bool}}
  final Map<String, Map<String, bool>> _poemMeaningTapped = {};
  int _pronScore = 85; // 中文发音评分（单条，方便接入大模型）
  int _meaningScore = 80; // 含义评分（合并为单条）

  // ── 录音 ──
  final AudioRecorder _audioRecorder = AudioRecorder();
  // ignore: unused_field  （预留字段：接入评分后端时使用）
  String? _recordedPath;

  // ── TTS 语音播放 ──
  final TtsService _tts = TtsService();
  final AiService _aiService = AiService();
  final GlobalKey<SoundWaveButtonState> _idiomSpeakerKey = GlobalKey();

  @override
  void dispose() {
    _audioRecorder.dispose();
    _tts.dispose();
    super.dispose();
  }

  /// 获取当前成语（仅 idioms 类型使用真实数据）
  IdiomModel? get _currentIdiom {
    if (widget.type == 'idioms' && _idioms.isNotEmpty) {
      return _idioms[_currentIndex];
    }
    return null;
  }

  /// 获取当前谚语（仅 proverbs 类型使用真实数据）
  ProverbModel? get _currentProverb {
    if (widget.type == 'proverbs' && _proverbs.isNotEmpty) {
      return _proverbs[_currentIndex];
    }
    return null;
  }

  /// 获取当前诗词（仅 poetry 类型使用真实数据）
  PoetryModel? get _currentPoem {
    if (widget.type == 'poetry' && _poems.isNotEmpty) {
      return _poems[_currentIndex];
    }
    return null;
  }

  /// 获取当前示例数据（文化类型使用）
  Map<String, String>? get _currentSample {
    if (widget.type == 'culture' && _sampleData.containsKey(widget.type)) {
      final list = _sampleData[widget.type]!;
      if (_currentIndex < list.length) {
        return list[_currentIndex];
      }
    }
    return null;
  }

  /// 获取当前条目的显示文本（成语/谚语/诗词真实数据 or 示例数据）
  String get _currentChinese =>
      _currentPoem?.displayText ?? _currentIdiom?.word ?? _currentProverb?.sentence ?? _currentSample?['word'] ?? '—';
  String get _currentPinyin => _currentIdiom?.pinyin ?? _currentProverb?.pinyin ?? _currentSample?['pinyin'] ?? '';
  String get _currentExplanation => _currentIdiom?.explanation ?? _currentProverb?.explanation ?? _currentSample?['explanation'] ?? '';
  String get _currentTranslation {
    if (_currentIdiom != null) {
      final state = context.read<AppState>();
      return _currentIdiom!.translationFor(state.language);
    }
    if (_currentProverb != null) {
      final state = context.read<AppState>();
      return _currentProverb!.translationFor(state.language);
    }
    return ''; // 示例数据暂无翻译
  }
  /// 诗词中文释义
  String get _currentPoetryChineseMeaning => _currentPoem?.chineseMeaning ?? '';
  /// 诗词母语释义（根据用户选择的语言）
  String get _currentPoetryNativeMeaning {
    if (_currentPoem != null) {
      final state = context.read<AppState>();
      return _currentPoem!.translationFor(state.language);
    }
    return '';
  }
  String get _currentId => _currentPoem?.id ?? _currentIdiom?.id ?? _currentProverb?.id ?? '${widget.type}_sample_$_currentIndex';

  @override
  void initState() {
    super.initState();
    if (widget.type == 'idioms') {
      _loadIdioms();
    } else if (widget.type == 'proverbs') {
      _loadProverbs();
    } else if (widget.type == 'poetry') {
      _loadPoetry();
    } else {
      // 文化类型使用示例数据，无需加载
      _isLoading = false;
    }
  }

  Future<void> _loadIdioms() async {
    try {
      final state = context.read<AppState>();
      final idioms = await IdiomRepository.loadIdioms();
      // 过滤掉已掌握的成语
      final availableIdioms = idioms
          .where((w) => !state.masteredIdiomIds.contains(w.id))
          .toList();
      if (mounted) {
        setState(() {
          _allIdioms = idioms;
          _idioms = availableIdioms;
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

  Future<void> _loadProverbs() async {
    try {
      final state = context.read<AppState>();
      final proverbs = await ProverbRepository.loadProverbs();
      // 过滤掉已掌握的谚语
      final availableProverbs = proverbs
          .where((w) => !state.masteredProverbIds.contains(w.id))
          .toList();
      if (mounted) {
        setState(() {
          _allProverbs = proverbs;
          _proverbs = availableProverbs;
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

  Future<void> _loadPoetry() async {
    try {
      final poems = await PoetryRepository.loadPoetry();
      if (mounted) {
        setState(() {
          _poems = poems;
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

  /// 跳转：弹出输入框让用户输入序号（支持成语/谚语/诗词）
  void _showJumpDialog() {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final total = switch (widget.type) {
      'idioms' => _allIdioms.length,
      'proverbs' => _allProverbs.length,
      'poetry' => _poems.length,
      _ => 0,
    };
    final title = switch (widget.type) {
      'idioms' => loc.jumpToIdiom,
      'proverbs' => loc.jumpToProverb,
      'poetry' => loc.jumpToPoem,
      _ => loc.jumpToPoem,
    };

    showDialog(
      context: context,
      builder: (ctx) {
        String? errorText;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(title),
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

                    if (widget.type == 'idioms') {
                      final targetIdiom = _allIdioms[num - 1];
                      // 在 _idioms 中找到对应索引
                      final idx = _idioms.indexWhere((w) => w.id == targetIdiom.id);
                      Navigator.pop(ctx);
                      if (idx == -1) {
                        // 已掌握的成语，加入临时列表并跳转
                        setState(() {
                          _idioms.insert(num - 1, targetIdiom);
                          _currentIndex = num - 1;
                          _showPronScore = false;
                          _showMeaningScore = false;
                          _showAnswer = false;
                          _showChineseExplanation = false;
                          _step = 'pronunciation';
                        });
                      } else {
                        setState(() {
                          _currentIndex = idx;
                          _showPronScore = false;
                          _showMeaningScore = false;
                          _showAnswer = false;
                          _showChineseExplanation = false;
                          _step = 'pronunciation';
                        });
                      }
                    } else if (widget.type == 'proverbs') {
                      final targetProverb = _allProverbs[num - 1];
                      final idx = _proverbs.indexWhere((w) => w.id == targetProverb.id);
                      Navigator.pop(ctx);
                      if (idx == -1) {
                        setState(() {
                          _proverbs.insert(num - 1, targetProverb);
                          _currentIndex = num - 1;
                          _showPronScore = false;
                          _showMeaningScore = false;
                          _showAnswer = false;
                          _showChineseExplanation = false;
                          _step = 'pronunciation';
                        });
                      } else {
                        setState(() {
                          _currentIndex = idx;
                          _showPronScore = false;
                          _showMeaningScore = false;
                          _showAnswer = false;
                          _showChineseExplanation = false;
                          _step = 'pronunciation';
                        });
                      }
                    } else {
                      // 诗词：直接跳转（不自动标记，需用户手动查看释义）
                      Navigator.pop(ctx);
                      setState(() => _currentIndex = num - 1);
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

  // ── 申请麦克风权限 ──
  Future<bool> _requestMicPermission() async {
    if (isDesktop) {
      return await _audioRecorder.hasPermission();
    }
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

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

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final dy = details.globalPosition.dy - _dragStartY;
    final cancelling = dy < -50;
    if (cancelling != _isCancelling) {
      setState(() => _isCancelling = cancelling);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) async {
    final path = await _audioRecorder.stop();

    if (_isCancelling) {
      if (path != null) {
        try {
          await deleteFileIfExists(path);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isCancelling = false;
          _recordedPath = null;
        });
      }
    } else {
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
    // 诗词/文化类型无评测，跳过
    if (widget.type == 'poetry' || widget.type == 'culture') return;
    if (path == null) return;

    setState(() => _isEvaluating = true);

    try {
      final state = context.read<AppState>();

      if (_step == 'pronunciation') {
        // 第一步：发音评分（录音 → ASR 转文字 → 与正确答案对比 → 评分）
        final score = await _aiService.evaluatePronunciation(
          audioPath: path,
          correctChinese: _currentChinese,
          pinyin: _currentPinyin,
        );
        if (mounted) {
          setState(() {
            _pronScore = score;
            _showPronScore = true;
            _isEvaluating = false;
          });
        }
      } else {
        // 第二步：语义评分（录音 → ASR 转文字 → 与标准翻译对比 → 评分）
        final score = await _aiService.evaluateMeaning(
          audioPath: path,
          correctTranslation: _currentTranslation,
          languageCode: state.language,
          chineseWord: _currentChinese,
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
            _showPronScore = true;
          } else {
            _meaningScore = rnd.nextInt(30) + 70;
            _showMeaningScore = true;
          }
          _isEvaluating = false;
        });
      }
    }
  }

  void _handleNextStep() => setState(() { _showPronScore = false; _step = 'meaning'; });

  /// 第一步发音重试：关闭评分弹窗，留在发音步骤
  void _handlePronRetry() => setState(() => _showPronScore = false);

  void _handleContinue() {
    final state = context.read<AppState>();
    // 标记当前条目为已掌握
    final id = _currentId;
    if (id.isNotEmpty) {
      switch (widget.type) {
        case 'idioms':
          state.markIdiomMastered(id);
          break;
        case 'proverbs':
          state.markProverbMastered(id);
          break;
      }
    }

    setState(() { _showMeaningScore = false; _step = 'pronunciation'; });
    if (widget.type == 'idioms') {
      // 掌握后从列表移除该成语
      if (_currentIndex < _idioms.length) {
        _idioms.removeAt(_currentIndex);
      }
      if (_idioms.isEmpty) {
        context.pop();
      } else if (_currentIndex >= _idioms.length) {
        setState(() => _currentIndex = 0);
      }
    } else if (widget.type == 'proverbs') {
      // 掌握后从列表移除该谚语
      if (_currentIndex < _proverbs.length) {
        _proverbs.removeAt(_currentIndex);
      }
      if (_proverbs.isEmpty) {
        context.pop();
      } else if (_currentIndex >= _proverbs.length) {
        setState(() => _currentIndex = 0);
      }
    } else if (widget.type == 'poetry') {
      // 诗词没有掌握功能，只做翻页
      if (_currentIndex < _poems.length - 1) {
        setState(() => _currentIndex++);
      } else {
        context.pop();
      }
    } else {
      // 文化示例数据翻页
      final list = _sampleData[widget.type];
      if (list != null && _currentIndex < list.length - 1) {
        setState(() => _currentIndex++);
      } else {
        context.pop();
      }
    }
  }

  void _handleRetry() => setState(() => _showMeaningScore = false);

  /// 当诗词的某个释义按钮被点击时调用，两个都点过则标记为已学习
  void _onPoemMeaningTapped({bool chinese = false, bool native = false}) {
    final poemId = _currentId;
    if (poemId.isEmpty) return;
    _poemMeaningTapped.putIfAbsent(poemId, () => {'chinese': false, 'native': false});
    if (chinese) _poemMeaningTapped[poemId]!['chinese'] = true;
    if (native) _poemMeaningTapped[poemId]!['native'] = true;
    // 两个都点过了才标记为已学习
    if (_poemMeaningTapped[poemId]!['chinese']! && _poemMeaningTapped[poemId]!['native']!) {
      final state = context.read<AppState>();
      state.markPoemLearned(poemId);
    }
  }

  void _handleSkip() {
    if (widget.type == 'idioms') {
      // 成语类型：弹出对话框询问是否已掌握
      final loc = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            loc.skipIdiomMasteredTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _doSkipIdiom(mastered: false);
              },
              child: Text(loc.skipMasteredNo,
                  style: const TextStyle(color: Color(0xFF999999))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _doSkipIdiom(mastered: true);
              },
              child: Text(loc.skipMasteredYes,
                  style: const TextStyle(
                      color: Color(0xFF4285F4), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else if (widget.type == 'proverbs') {
      // 谚语类型：同样弹出对话框询问是否已掌握
      final loc = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            loc.skipProverbMasteredTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _doSkipProverb(mastered: false);
              },
              child: Text(loc.skipMasteredNo,
                  style: const TextStyle(color: Color(0xFF999999))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _doSkipProverb(mastered: true);
              },
              child: Text(loc.skipMasteredYes,
                  style: const TextStyle(
                      color: Color(0xFF4285F4), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      // 非成语类型：保持原有跳过逻辑
      _doSkipOther();
    }
  }

  /// 成语跳过逻辑
  void _doSkipIdiom({required bool mastered}) {
    if (mastered && _currentIdiom != null) {
      final state = context.read<AppState>();
      state.markIdiomMastered(_currentIdiom!.id);
      setState(() {
        _idioms.removeAt(_currentIndex);
        _showPronScore = false;
        _showMeaningScore = false;
        _showAnswer = false;
        _showChineseExplanation = false;
        _step = 'pronunciation';
      });
    } else {
      setState(() {
        _showPronScore = false;
        _showMeaningScore = false;
        _showAnswer = false;
        _showChineseExplanation = false;
        _step = 'pronunciation';
      });
    }
    if (_idioms.isEmpty) {
      context.pop();
    } else if (_currentIndex >= _idioms.length) {
      setState(() => _currentIndex = 0);
    } else if (!mastered && _currentIndex < _idioms.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  /// 谚语跳过逻辑
  void _doSkipProverb({required bool mastered}) {
    if (mastered && _currentProverb != null) {
      final state = context.read<AppState>();
      state.markProverbMastered(_currentProverb!.id);
      setState(() {
        _proverbs.removeAt(_currentIndex);
        _showPronScore = false;
        _showMeaningScore = false;
        _showAnswer = false;
        _showChineseExplanation = false;
        _step = 'pronunciation';
      });
    } else {
      setState(() {
        _showPronScore = false;
        _showMeaningScore = false;
        _showAnswer = false;
        _showChineseExplanation = false;
        _step = 'pronunciation';
      });
    }
    if (_proverbs.isEmpty) {
      context.pop();
    } else if (_currentIndex >= _proverbs.length) {
      setState(() => _currentIndex = 0);
    } else if (!mastered && _currentIndex < _proverbs.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  /// 非成语/谚语类型跳过逻辑（诗词/文化）
  void _doSkipOther() {
    setState(() {
      _showPronScore = false;
      _showMeaningScore = false;
      _showAnswer = false;
      _showChineseExplanation = false;
      _step = 'pronunciation';
    });
    final list = _sampleData[widget.type];
    if (list != null && _currentIndex < list.length - 1) {
      setState(() => _currentIndex++);
    } else {
      context.pop();
    }
  }

  Color _scoreColor(int s) {
    if (s >= 80) return Colors.green;
    if (s >= 60) return Colors.orange;
    return Colors.red;
  }

  int get _avgMeaning => _meaningScore;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final loc = AppLocalizations.of(context)!;
    final isFav = state.favorites.contains(_currentId);

    // Web 平台提示
    if (kIsWeb) {
      final title = switch (widget.type) {
        'idioms' => loc.idioms,
        'proverbs' => loc.proverbs,
        'poetry' => loc.poetry,
        _ => loc.culture,
      };
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

    // 加载中状态
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4285F4)),
              const SizedBox(height: 16),
              Text(loc.loading, style: const TextStyle(color: Color(0xFF999999))),
            ],
          ),
        ),
      );
    }

    // 加载错误
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(loc.noData, style: const TextStyle(color: Color(0xFF999999))),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() { _isLoading = true; _loadError = null; });
                  _loadIdioms();
                },
                child: Text(loc.retry),
              ),
            ],
          ),
        ),
      );
    }

    // 非成语/谚语/诗词类型，且无示例数据，显示"即将推出"
    if (widget.type != 'idioms' && widget.type != 'proverbs' && widget.type != 'poetry' && !_sampleData.containsKey(widget.type)) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_empty, color: Color(0xFF999999), size: 64),
              const SizedBox(height: 16),
              Text(loc.comingSoon,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF666666))),
              const SizedBox(height: 8),
              Text(loc.featureInDevelopment,
                  style: const TextStyle(color: Color(0xFF999999))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
                        ),
                        Text(
                          widget.type == 'idioms' ? loc.idioms
                              : widget.type == 'proverbs' ? loc.proverbs
                              : widget.type == 'poetry' ? loc.poetry
                              : loc.culture,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        (widget.type == 'poetry' && _poems.isNotEmpty) ||
                        (widget.type == 'idioms' && _allIdioms.isNotEmpty) ||
                        (widget.type == 'proverbs' && _allProverbs.isNotEmpty)
                            ? GestureDetector(
                                onTap: _showJumpDialog,
                                child: Text(
                                  widget.type == 'idioms'
                                      ? '${_currentIdiom != null ? _allIdioms.indexWhere((w) => w.id == _currentIdiom!.id) + 1 : 1}/${_allIdioms.length}'
                                      : widget.type == 'proverbs'
                                          ? '${_currentProverb != null ? _allProverbs.indexWhere((w) => w.id == _currentProverb!.id) + 1 : 1}/${_allProverbs.length}'
                                          : '${_currentIndex + 1}/${_poems.length}',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF4285F4), decoration: TextDecoration.underline),
                                ),
                              )
                            : Text(
                                widget.type == 'idioms'
                                    ? '${_currentIdiom != null ? _allIdioms.indexWhere((w) => w.id == _currentIdiom!.id) + 1 : 1}/${_allIdioms.length}'
                                    : widget.type == 'proverbs'
                                        ? '${_currentProverb != null ? _allProverbs.indexWhere((w) => w.id == _currentProverb!.id) + 1 : 1}/${_allProverbs.length}'
                                        : '${_currentIndex + 1}/${_sampleData[widget.type]?.length ?? 0}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              // Step Bar (诗词类型不显示)
              if (widget.type != 'poetry')
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 步骤1
                        Row(
                          children: [
                            Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: _step == 'pronunciation'
                                    ? const Color(0xFF4285F4)
                                    : const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text('1',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold,
                                        color: _step == 'pronunciation' ? Colors.white : const Color(0xFF999999))),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(loc.step1ReadChinese,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _step == 'pronunciation' ? FontWeight.bold : FontWeight.normal,
                                      color: _step == 'pronunciation' ? const Color(0xFF4285F4) : const Color(0xFF999999))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 步骤2
                        Row(
                          children: [
                            Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: _step == 'meaning'
                                    ? const Color(0xFF4285F4)
                                    : const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text('2',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold,
                                        color: _step == 'meaning' ? Colors.white : const Color(0xFF999999))),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(loc.step2Explain,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _step == 'meaning' ? FontWeight.bold : FontWeight.normal,
                                      color: _step == 'meaning' ? const Color(0xFF4285F4) : const Color(0xFF999999))),
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
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // ===== 诗词类型：大显示框 + 释义按钮 =====
                      if (widget.type == 'poetry') ...[
                        // Card — 大显示框，小字号
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(20, 48, 20, 48),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCEAFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _currentChinese,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Star — 收藏按钮
                            Positioned(
                              top: 8, right: 8,
                              child: IconButton(
                                onPressed: () => state.toggleFavorite(_currentId),
                                icon: Icon(isFav ? Icons.star : Icons.star_border,
                                    color: isFav ? Colors.amber : Colors.grey, size: 24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // 两个释义按钮（上下分布）
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _showPoetryChineseMeaning = true);
                              _onPoemMeaningTapped(chinese: true);
                            },
                            icon: const Icon(Icons.menu_book, size: 20),
                            label: Text(loc.showChineseMeaning,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4285F4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _showPoetryNativeMeaning = true);
                              _onPoemMeaningTapped(native: true);
                            },
                            icon: const Icon(Icons.translate, size: 20),
                            label: Text(loc.showNativeMeaning,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF333333),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // 翻页按钮（上一首 + 下一首）
                        Row(
                          children: [
                            // 上一首
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _currentIndex > 0
                                    ? () => setState(() => _currentIndex--)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  foregroundColor: const Color(0xFF333333),
                                  disabledBackgroundColor: const Color(0xFFF0F0F0),
                                  disabledForegroundColor: const Color(0xFFCCCCCC),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  loc.prevItem,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 下一首
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_currentIndex < _poems.length - 1) {
                                    setState(() => _currentIndex++);
                                  } else {
                                    context.pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4285F4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  _currentIndex < _poems.length - 1 ? loc.nextItem : loc.close,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // ===== 成语/谚语/文化类型：原有卡片 + 麦克风 =====
                        // Card
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(20, widget.type == 'proverbs' ? 48 : 24, 20, 48),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCEAFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text(_currentChinese,
                                      style: TextStyle(
                                          fontSize: widget.type == 'proverbs' ? 28 : 44, fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
                                  const SizedBox(height: 8),
                                  Text(_currentPinyin,
                                      style: const TextStyle(fontSize: 18, color: Color(0xFF999999))),
                                ],
                              ),
                            ),
                            // Star
                            Positioned(
                              top: 8, right: 8,
                              child: IconButton(
                                onPressed: () => state.toggleFavorite(_currentId),
                                icon: Icon(isFav ? Icons.star : Icons.star_border,
                                    color: isFav ? Colors.amber : Colors.grey, size: 24),
                              ),
                            ),
                            // 中文释义 button
                            Positioned(
                              bottom: 8, left: 12,
                              child: TextButton.icon(
                                onPressed: () => setState(() => _showChineseExplanation = true),
                                icon: const Icon(Icons.menu_book, size: 16, color: Color(0xFF666666)),
                                label: Text(loc.chineseExplanation,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                ),
                              ),
                            ),
                            // Speaker — 点击播放中文语音
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: SoundWaveButton(
                                key: _idiomSpeakerKey,
                                size: 36,
                                onTap: () {
                                  _tts.speak(_currentChinese).then((_) {
                                    _idiomSpeakerKey.currentState?.stopAnimation();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Mic — 按住录音，上滑取消（评分中禁用）
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
                              ? '...'
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
                          _step == 'pronunciation' ? loc.tapMicToRead : loc.explainInNativeLanguage,
                          style: const TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _handleSkip,
                              child: Text(loc.skip, style: const TextStyle(color: Color(0xFF999999))),
                            ),
                            if (_step == 'meaning')
                              TextButton(
                                onPressed: () => setState(() => _showAnswer = true),
                                child: Text(loc.showAnswer, style: const TextStyle(color: Color(0xFF999999))),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Pronunciation Score
          if (_showPronScore)
            _bottomSheet(
              title: loc.pronunciationScore,
              items: [
                _scoreRow(loc.pronunciationAccuracy, _pronScore, _scoreColor(_pronScore)),
              ],
              action: Row(
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
            ),

          // Meaning Score
          if (_showMeaningScore)
            _bottomSheet(
              title: loc.meaningScore,
              items: [
                _scoreRow(loc.meaningAccuracy, _meaningScore, _scoreColor(_meaningScore)),
              ],
              action: _avgMeaning >= 70
                  ? Column(children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(left: BorderSide(color: Colors.green, width: 4))),
                        child: Text(loc.masteredSuccess,
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: double.infinity,
                          child: ElevatedButton(onPressed: _handleContinue, style: _blueBtn,
                              child: Text(loc.continueBtn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                    ])
                  : Column(children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(left: BorderSide(color: Colors.orange, width: 4))),
                        child: Text(loc.tryAgain,
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: double.infinity,
                          child: ElevatedButton(onPressed: _handleRetry,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: Text(loc.reRecord, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                    ]),
            ),

          // Chinese Explanation Dialog — 显示真实中文释义
          if (_showChineseExplanation)
            _dialog(loc.chineseExplanation, _currentExplanation,
                () => setState(() => _showChineseExplanation = false)),

          // Answer Dialog — 显示对应语言的翻译
          if (_showAnswer)
            _dialog(loc.meaningBelow, _currentTranslation,
                () => setState(() => _showAnswer = false)),

          // Poetry Chinese Meaning Dialog — 诗词中文释义
          if (_showPoetryChineseMeaning)
            _dialog(loc.chineseExplanation, _currentPoetryChineseMeaning,
                () => setState(() => _showPoetryChineseMeaning = false)),

          // Poetry Native Meaning Dialog — 诗词母语释义
          if (_showPoetryNativeMeaning)
            _dialog(loc.showNativeMeaning, _currentPoetryNativeMeaning,
                () => setState(() => _showPoetryNativeMeaning = false)),
        ],
      ),
    );
  }

  Widget _bottomSheet({required String title, required List<Widget> items, required Widget action}) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...items,
            const SizedBox(height: 4),
            action,
          ],
        ),
      ),
    );
  }

  Widget _dialog(String title, String content, VoidCallback onClose) {
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(content, style: const TextStyle(color: Color(0xFF666666))),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0E0E0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(loc.close, style: const TextStyle(color: Color(0xFF666666))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _scoreRow(String label, int score, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          Text('$score%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
              value: score / 100.0, backgroundColor: const Color(0xFFE0E0E0), color: color, minHeight: 8),
        ),
      ],
    ),
  );
}

final _blueBtn = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF4285F4),
  padding: const EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);
