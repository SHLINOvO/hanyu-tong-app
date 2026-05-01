import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/culture_model.dart';
import '../models/culture_repository.dart';

/// 文化知识学习页 — 纯文本展示模式（无测评功能）
/// 布局：上面中文原文 → 中间中文释义 → 下面母语释义
class CulturePracticePage extends StatefulWidget {
  const CulturePracticePage({super.key});

  @override
  State<CulturePracticePage> createState() => _CulturePracticePageState();
}

class _CulturePracticePageState extends State<CulturePracticePage> {
  List<CultureModel> _items = [];
  bool _isLoading = true;
  String? _loadError;
  int _currentIndex = 0;

  CultureModel? get _current => _items.isNotEmpty ? _items[_currentIndex] : null;

  @override
  void initState() {
    super.initState();
    _loadCulture();
  }

  Future<void> _loadCulture() async {
    try {
      final items = await CultureRepository.loadCulture();
      if (mounted) {
        setState(() {
          _items = items;
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

  /// 跳转到指定序号
  void _showJumpDialog() {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final total = _items.length;

    showDialog(
      context: context,
      builder: (ctx) {
        String? errorText;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(loc.jumpToCulture),
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
                    setState(() => _currentIndex = num - 1);
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

  void _handleNext() {
    if (_currentIndex < _items.length - 1) {
      setState(() => _currentIndex++);
    } else {
      context.pop();
    }
  }

  void _handlePrev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
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
          title: Text(loc.culture,
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

    // 加载中
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
                  _loadCulture();
                },
                child: Text(loc.retry),
              ),
            ],
          ),
        ),
      );
    }

    final item = _current!;
    final isRTL = state.language == 'ar' || state.language == 'fa';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
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
                      loc.culture,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    // 序号跳转
                    GestureDetector(
                      onTap: _showJumpDialog,
                      child: Text(
                        '${_currentIndex + 1}/${_items.length}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF4285F4), decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 分类标签（节气/节日）
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isFestival ? const Color(0xFFFFEDD8) : const Color(0xFFDCEAFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.isFestival
                        ? (loc.cultureFestival)
                        : (loc.cultureSolarTerm),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: item.isFestival ? Colors.orange : const Color(0xFF4285F4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content — 可滚动
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 中文原文卡片（蓝色背景）
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCEAFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 名称（大字）
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        // 日期（仅节日显示）
                        if (item.isFestival && item.date != null && item.date!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.date!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. 中文释义
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book, size: 18, color: Color(0xFF4285F4)),
                            const SizedBox(width: 6),
                            Text(
                              loc.chineseExplanation,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.chinese,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF333333),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. 母语释义
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.translate, size: 18, color: Color(0xFF666666)),
                            const SizedBox(width: 6),
                            Text(
                              loc.nativeExplanation,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.translationFor(state.language),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF333333),
                            height: 1.6,
                          ),
                          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. 翻页按钮
                  Row(
                    children: [
                      // 上一条
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentIndex > 0 ? _handlePrev : null,
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
                      // 下一条
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4285F4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _currentIndex < _items.length - 1 ? loc.nextItem : loc.close,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
