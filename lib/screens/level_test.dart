import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../widgets/step_indicator.dart';
import '../l10n/app_localizations.dart';

// 水平选项数据将在build方法中动态创建，以便使用本地化文本

class LevelTest extends StatefulWidget {
  const LevelTest({super.key});

  @override
  State<LevelTest> createState() => _LevelTestState();
}

class _LevelTestState extends State<LevelTest> {
  String? _selected;

  void _handleContinue() {
    if (_selected != null) {
      context.read<AppState>().setLevel(_selected!);
      context.go('/goal');
    }
  }

  List<Map<String, String>> _buildLevels(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      {
        'id': 'beginner',
        'emoji': '🌱',
        'title': loc.levelBeginner,
        'desc': '刚开始学习，认识少量汉字', // 这个描述也需要本地化，但目前没有对应的键
      },
      {
        'id': 'elementary',
        'emoji': '📗',
        'title': loc.levelElementary,
        'desc': '能进行简单日常对话', // 这个描述也需要本地化，但目前没有对应的键
      },
      {
        'id': 'intermediate',
        'emoji': '📘',
        'title': loc.levelIntermediate,
        'desc': '掌握常用词汇，能读短文', // 这个描述也需要本地化，但目前没有对应的键
      },
      {
        'id': 'advanced',
        'emoji': '🏆',
        'title': loc.levelAdvanced,
        'desc': '熟悉成语古诗，挑战深度中文', // 这个描述也需要本地化，但目前没有对应的键
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    const StepIndicator(total: 3, current: 1),
                    const SizedBox(height: 48),
                    Text(
                      AppLocalizations.of(context)!.whatsYourLevel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.selectBestOption,
                      style: const TextStyle(color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 32),
                    ..._buildLevels(context).map((lvl) => _LevelCard(
                          level: lvl,
                          isSelected: _selected == lvl['id'],
                          onTap: () =>
                              setState(() => _selected = lvl['id']),
                        )),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
              ),
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected != null ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    disabledBackgroundColor: const Color(0xFFCCCCCC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.nextStep,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Map<String, String> level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF4285F4), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.12 : 0.06),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(level['emoji']!, style: const TextStyle(fontSize: 44)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level['desc']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF4285F4) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4285F4)
                      : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
