import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';

/// 语法学习页面
/// 支持 8 种语言（en/ru/tr/ar/fa/id/vi/km），按难度显示对应文件夹下的 PNG 图片（翻页浏览）
class GrammarPracticePage extends StatefulWidget {
  const GrammarPracticePage({super.key});

  @override
  State<GrammarPracticePage> createState() => _GrammarPracticePageState();
}

class _GrammarPracticePageState extends State<GrammarPracticePage> {
  int _currentIndex = 0;
  late int _totalItems;

  /// 难度 → assets 文件夹名映射
  static const Map<String, String> _levelFolderMap = {
    'beginner': 'hsk1_2',
    'elementary': 'hsk3',
    'intermediate': 'hsk4',
    'advanced': 'hsk5_6',
  };

  /// 支持 grammar 图片的语言列表
  static const _supportedLanguages = ['en', 'ru', 'tr', 'ar', 'fa', 'id', 'vi', 'km'];

  /// 各语言 × 各难度下的图片数量
  static const Map<String, Map<String, int>> _langLevelCountMap = {
    'en': {'beginner': 7, 'elementary': 5, 'intermediate': 5, 'advanced': 7},
    'ru': {'beginner': 8, 'elementary': 6, 'intermediate': 6, 'advanced': 7},
    'tr': {'beginner': 7, 'elementary': 5, 'intermediate': 5, 'advanced': 7},
    'ar': {'beginner': 6, 'elementary': 4, 'intermediate': 4, 'advanced': 6},
    'fa': {'beginner': 7, 'elementary': 4, 'intermediate': 4, 'advanced': 6},
    'id': {'beginner': 7, 'elementary': 6, 'intermediate': 4, 'advanced': 7},
    'vi': {'beginner': 6, 'elementary': 4, 'intermediate': 4, 'advanced': 6},
    'km': {'beginner': 7, 'elementary': 5, 'intermediate': 4, 'advanced': 7},
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    final langCounts = _langLevelCountMap[state.language];
    _totalItems = langCounts?[state.level] ?? 7;
  }

  /// 获取当前图片的 asset 路径
  String _currentImagePath() {
    final state = context.read<AppState>();
    final folder = _levelFolderMap[state.level] ?? 'hsk1_2';
    final lang = _supportedLanguages.contains(state.language) ? state.language : 'en';
    // Web 平台 assets 路径需要双重嵌套，原生平台只需单层
    final basePath = kIsWeb ? 'assets/assets/grammar/' : 'assets/grammar/';
    return '$basePath$lang/$folder/${_currentIndex + 1}.png';
  }

  /// 获取难度标题
  String _levelTitle(AppLocalizations loc) {
    final state = context.watch<AppState>();
    switch (state.level) {
      case 'beginner':
        return 'HSK1-2 ${loc.grammarLabel}';
      case 'elementary':
        return 'HSK3 ${loc.grammarLabel}';
      case 'intermediate':
        return 'HSK4 ${loc.grammarLabel}';
      case 'advanced':
        return 'HSK5-6 ${loc.grammarLabel}';
      default:
        return loc.grammarLearning;
    }
  }

  void _goToIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
          title: Text(_levelTitle(loc),
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

    // 所有支持的语言 → 图片翻页
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
        ),
        title: Text(_levelTitle(loc),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        centerTitle: false,
        elevation: 0,
        actions: [
          // 序号/跳转
          GestureDetector(
            onTap: _showJumpDialog,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentIndex + 1}/$_totalItems',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4285F4),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 图片区域（可滚动）
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 图片卡片
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 300,
                      ),
                      child: Image.asset(
                        _currentImagePath(),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('[GrammarPractice] image load error: $error');
                          debugPrint('[GrammarPractice] path: ${_currentImagePath()}');
                          return Container(
                            height: 200,
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, color: Color(0xFFCCCCCC), size: 64),
                                const SizedBox(height: 12),
                                Text(
                                  '${_currentIndex + 1}.png',
                                  style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _currentImagePath(),
                                  style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // 底部固定按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // 上一项
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
                  // 下一项
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentIndex < _totalItems - 1) {
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
                        _currentIndex < _totalItems - 1 ? loc.nextItem : loc.close,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 跳转对话框
  void _showJumpDialog() {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final total = _totalItems;

    showDialog(
      context: context,
      builder: (ctx) {
        String? errorText;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(loc.grammarLearning),
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
                    Navigator.pop(ctx);
                    _goToIndex(num - 1);
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
}
