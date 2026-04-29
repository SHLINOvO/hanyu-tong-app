import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../config/app_languages.dart';
import '../l10n/app_localizations.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              children: [
                Expanded(
                  child: _TopButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.language, size: 18, color: Color(0xFF666666)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            getLanguage(state.language)?.nativeName ?? 'English',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF666666)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showLanguageSelector(context, state),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TopButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${state.dailyGoal} ${AppLocalizations.of(context)!.minutes}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF666666)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showGoalSelector(context, state),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _StatItem(
                    icon: '🔥', 
                    value: '${state.streak}', 
                    label1: '连续学习', 
                    label2: '天',
                    useLocalization: true,
                  ),
                  _StatItem(
                    icon: '📅', 
                    value: '${state.totalDays}', 
                    label1: '累计天数', 
                    label2: '天',
                    useLocalization: true,
                  ),
                  _StatItem(
                    icon: '⏱', 
                    value: state.totalHours % 1 == 0 ? '${state.totalHours.toInt()}' : '${state.totalHours}', 
                    label1: '学习时长', 
                    label2: '小时',
                    useLocalization: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mastered Card
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.mastered,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatItem(
                        icon: '📝',
                        value: '${state.masteredWords}',
                        label1: '字词',
                        label2: '个',
                        useLocalization: true,
                      ),
                      _StatItem(
                        icon: '📖',
                        value: '${state.masteredIdioms}',
                        label1: '成语',
                        label2: '个',
                        useLocalization: true,
                      ),
                      _StatItem(
                        icon: '💡',
                        value: '${state.masteredProverbs}',
                        label1: '谚语',
                        label2: '个',
                        useLocalization: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4285F4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppLocalizations.of(context)!.review,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Favorites Card
            GestureDetector(
              onTap: () => context.push('/favorites'),
              child: _Card(
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(AppLocalizations.of(context)!.myFavorites,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333))),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF999999)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, AppState state) {
    const langs = supportedLanguages;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF333333)),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          title: Text(
            AppLocalizations.of(context)!.chooseNativeLanguage,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: langs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final l = langs[i];
            final isSelected = state.language == l.code;
            return Directionality(
              textDirection: TextDirection.ltr,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4285F4).withValues(alpha: 0.1) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      l.code.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF4285F4) : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                title: Directionality(
                  textDirection: l.isRTL ? TextDirection.rtl : TextDirection.ltr,
                  child: Text(
                    l.nativeName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                      color: isSelected ? const Color(0xFF4285F4) : const Color(0xFF333333),
                    ),
                  ),
                ),
                subtitle: Text(
                  l.englishName,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF4285F4))
                    : const Icon(Icons.circle_outlined, color: Color(0xFFE0E0E0)),
                onTap: () {
                  state.setLanguage(l.code);
                  Navigator.pop(dialogContext);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showGoalSelector(BuildContext context, AppState state) {
    const goals = [5, 15, 30, 60];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppLocalizations.of(context)!.dailyGoalMinutes,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ...goals.map((g) => ListTile(
                title: Text('$g ${AppLocalizations.of(context)!.minutes}'),
                trailing: state.dailyGoal == g
                    ? const Icon(Icons.check, color: Color(0xFF4285F4))
                    : null,
                onTap: () {
                  state.setDailyGoal(g);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TopButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color.fromARGB(15, 0, 0, 0),
                blurRadius: 4,
                offset: Offset(0, 2))
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label1;
  final String label2;
  final bool useLocalization;
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label1,
    required this.label2,
    this.useLocalization = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4285F4))),
          Text(
            useLocalization && localizations != null ? _getLocalizedLabel1(localizations) : label1,
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
          Text(
            useLocalization && localizations != null ? _getLocalizedLabel2(localizations) : label2,
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
  
  String _getLocalizedLabel1(AppLocalizations localizations) {
    switch (label1) {
      case '连续学习':
        return localizations.streakLabel;
      case '累计天数':
        return localizations.totalDaysLabel;
      case '学习时长':
        return localizations.totalHoursLabel;
      case '字词':
        return localizations.wordsLabel;
      case '成语':
        return localizations.idiomsLabel;
      case '谚语':
        return localizations.proverbsLabel;
      default:
        return label1;
    }
  }
  
  String _getLocalizedLabel2(AppLocalizations localizations) {
    switch (label2) {
      case '天':
        return localizations.unitDays;
      case '小时':
        return localizations.unitHours;
      case '个':
        return localizations.unitItems;
      default:
        return label2;
    }
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color.fromARGB(15, 0, 0, 0),
              blurRadius: 6,
              offset: Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}
