import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../widgets/step_indicator.dart';
import '../l10n/app_localizations.dart';

// 目标选项数据将在build方法中动态创建，以便使用本地化文本

class GoalSetting extends StatefulWidget {
  const GoalSetting({super.key});

  @override
  State<GoalSetting> createState() => _GoalSettingState();
}

class _GoalSettingState extends State<GoalSetting> {
  int _selected = 15;

  void _handleStart() {
    context.read<AppState>().setDailyGoal(_selected);
    context.read<AppState>().setIsOnboarded(true);
    context.go('/app');
  }

  List<Map<String, Object>> _buildGoals(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      {'value': 5, 'emoji': '⚡', 'title': loc.goal5min, 'desc': '轻松入门，随时随地'}, // 这个描述也需要本地化，但目前没有对应的键
      {'value': 15, 'emoji': '🎯', 'title': loc.goal15min, 'desc': '稳步提升，每日打卡'}, // 这个描述也需要本地化，但目前没有对应的键
      {'value': 30, 'emoji': '🔥', 'title': loc.goal30min, 'desc': '高效学习，快速进步'}, // 这个描述也需要本地化，但目前没有对应的键
      {'value': 60, 'emoji': '🏅', 'title': loc.goal60min, 'desc': '深度沉浸，全面突破'}, // 这个描述也需要本地化，但目前没有对应的键
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
                    const StepIndicator(total: 3, current: 2),
                    const SizedBox(height: 48),
                    Text(
                      AppLocalizations.of(context)!.setLearningGoal,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.dailyConsistency,
                      style: const TextStyle(color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 32),
                    ..._buildGoals(context).map((goal) => _GoalCard(
                          goal: goal,
                          isSelected: _selected == goal['value'],
                          onTap: () =>
                              setState(() => _selected = goal['value'] as int),
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
                  onPressed: _handleStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.startLearning,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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

class _GoalCard extends StatelessWidget {
  final Map<String, Object> goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
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
            Text(goal['emoji'] as String,
                style: const TextStyle(fontSize: 44)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal['title'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF333333))),
                  const SizedBox(height: 4),
                  Text(goal['desc'] as String,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF666666))),
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
