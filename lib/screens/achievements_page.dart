import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/badge_model.dart';

/// 全屏成就页面
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final loc = AppLocalizations.of(context)!;

    // 已解锁/总数统计
    final unlockedCount = state.unlockedBadgeIds.length;
    final totalCount = BadgeDef.all.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(loc.myAchievements),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 统计栏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  '$unlockedCount / $totalCount',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4285F4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${loc.badgeUnlocked} $unlockedCount / $totalCount',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          // 成就列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: _getCategoryTitle(loc, 'starter'),
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFFB300),
                  badges: BadgeDef.all.where((b) => b.id.name == 'beginner' || b.id.name == 'explorer').toList(),
                ),
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.wordsLabel,
                  icon: Icons.auto_stories_rounded,
                  color: const Color(0xFF4285F4),
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'wordLearner' ||
                    b.id.name == 'wordKnight' ||
                    b.id.name == 'wordMaster' ||
                    b.id.name == 'wordLegend'
                  ).toList(),
                ),
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.idioms,
                  icon: Icons.lightbulb_outline_rounded,
                  color: Colors.orange,
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'idiomFirst' ||
                    b.id.name == 'idiomAdept' ||
                    b.id.name == 'idiomMaster'
                  ).toList(),
                ),
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.proverbs,
                  icon: Icons.format_quote_rounded,
                  color: const Color(0xFF00796B),
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'proverbFirst' ||
                    b.id.name == 'proverbAdept' ||
                    b.id.name == 'proverbSage'
                  ).toList(),
                ),
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.streakLabel,
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF5722),
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'streak3' ||
                    b.id.name == 'streak7' ||
                    b.id.name == 'streak14' ||
                    b.id.name == 'streak30' ||
                    b.id.name == 'streak100'
                  ).toList(),
                ),
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.poetry,
                  icon: Icons.nightlight_round,
                  color: const Color(0xFF5C6BC0),
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'poemLover' ||
                    b.id.name == 'poemScholar'
                  ).toList(),
                ),
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.favorites,
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFFE91E63),
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'collector' ||
                    b.id.name == 'treasureHunter'
                  ).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取类别标题
  String _getCategoryTitle(AppLocalizations loc, String category) {
    switch (category) {
      case 'starter':
        return '入门';
      default:
        return category;
    }
  }

  /// 构建类别区块
  Widget _buildCategorySection({
    required BuildContext context,
    required AppState state,
    required String title,
    required IconData icon,
    required Color color,
    required List<BadgeDef> badges,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              Text(
                '${badges.where((b) => state.unlockedBadgeIds.contains(b.id.name)).length}/${badges.length}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final unlocked = state.unlockedBadgeIds.contains(badge.id.name);
            return _BadgeGridItem(
              badge: badge,
              unlocked: unlocked,
              onTap: () => _showBadgeDialog(context, badge, unlocked),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// 徽章详情弹窗
  void _showBadgeDialog(BuildContext context, BadgeDef badge, bool unlocked) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked
                    ? badge.color.withValues(alpha: 0.15)
                    : const Color(0xFFF0F0F0),
                border: Border.all(
                  color: unlocked ? badge.color : const Color(0xFFD0D0D0),
                  width: 3,
                ),
              ),
              child: Icon(
                badge.icon,
                size: 40,
                color: unlocked ? badge.color : const Color(0xFFBDBDBD),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getBadgeTitle(context, badge.id.name),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: unlocked ? const Color(0xFF333333) : const Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getBadgeDesc(context, badge.id.name),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: unlocked
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unlocked ? loc.badgeUnlocked : loc.badgeLocked,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? const Color(0xFF4CAF50) : const Color(0xFF888888),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// 获取徽章标题
  String _getBadgeTitle(BuildContext context, String badgeId) {
    final loc = AppLocalizations.of(context)!;
    switch (badgeId) {
      case 'beginner':       return loc.badgeBeginner;
      case 'explorer':       return loc.badgeExplorer;
      case 'wordLearner':    return loc.badgeWordLearner;
      case 'wordKnight':     return loc.badgeWordKnight;
      case 'wordMaster':     return loc.badgeWordMaster;
      case 'wordLegend':     return loc.badgeWordLegend;
      case 'idiomFirst':     return loc.badgeIdiomFirst;
      case 'idiomAdept':     return loc.badgeIdiomAdept;
      case 'idiomMaster':    return loc.badgeIdiomMaster;
      case 'proverbFirst':   return loc.badgeProverbFirst;
      case 'proverbAdept':   return loc.badgeProverbAdept;
      case 'proverbSage':    return loc.badgeProverbSage;
      case 'streak3':        return loc.badgeStreak3;
      case 'streak7':        return loc.badgeStreak7;
      case 'streak14':       return loc.badgeStreak14;
      case 'streak30':       return loc.badgeStreak30;
      case 'streak100':      return loc.badgeStreak100;
      case 'poemLover':      return loc.badgePoemLover;
      case 'poemScholar':    return loc.badgePoemScholar;
      case 'collector':      return loc.badgeCollector;
      case 'treasureHunter': return loc.badgeTreasureHunter;
      default:               return badgeId;
    }
  }

  /// 获取徽章描述
  String _getBadgeDesc(BuildContext context, String badgeId) {
    final loc = AppLocalizations.of(context)!;
    switch (badgeId) {
      case 'beginner':       return loc.badgeBeginnerDesc;
      case 'explorer':       return loc.badgeExplorerDesc;
      case 'wordLearner':    return loc.badgeWordLearnerDesc;
      case 'wordKnight':     return loc.badgeWordKnightDesc;
      case 'wordMaster':     return loc.badgeWordMasterDesc;
      case 'wordLegend':     return loc.badgeWordLegendDesc;
      case 'idiomFirst':     return loc.badgeIdiomFirstDesc;
      case 'idiomAdept':     return loc.badgeIdiomAdeptDesc;
      case 'idiomMaster':    return loc.badgeIdiomMasterDesc;
      case 'proverbFirst':   return loc.badgeProverbFirstDesc;
      case 'proverbAdept':   return loc.badgeProverbAdeptDesc;
      case 'proverbSage':    return loc.badgeProverbSageDesc;
      case 'streak3':        return loc.badgeStreak3Desc;
      case 'streak7':        return loc.badgeStreak7Desc;
      case 'streak14':       return loc.badgeStreak14Desc;
      case 'streak30':       return loc.badgeStreak30Desc;
      case 'streak100':      return loc.badgeStreak100Desc;
      case 'poemLover':      return loc.badgePoemLoverDesc;
      case 'poemScholar':    return loc.badgePoemScholarDesc;
      case 'collector':      return loc.badgeCollectorDesc;
      case 'treasureHunter': return loc.badgeTreasureHunterDesc;
      default:               return '';
    }
  }
}

/// 成就网格项组件
class _BadgeGridItem extends StatelessWidget {
  final BadgeDef badge;
  final bool unlocked;
  final VoidCallback onTap;

  const _BadgeGridItem({
    required this.badge,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final title = _getBadgeTitleFromLoc(loc, badge.id.name);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: unlocked ? 3 : 0.5,
        shadowColor: unlocked ? badge.color.withValues(alpha: 0.3) : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: unlocked ? badge.color.withValues(alpha: 0.3) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: unlocked
                ? badge.color.withValues(alpha: 0.05)
                : const Color(0xFFFAFAFA),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked
                      ? badge.color.withValues(alpha: 0.15)
                      : const Color(0xFFF0F0F0),
                ),
                child: Icon(
                  badge.icon,
                  size: 24,
                  color: unlocked ? badge.color : const Color(0xFFBDBDBD),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? const Color(0xFF333333) : const Color(0xFFAAAAAA),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getBadgeTitle(BuildContext context, String badgeId) {
    final loc = AppLocalizations.of(context)!;
    return _getBadgeTitleFromLoc(loc, badgeId);
  }

  String _getBadgeTitleFromLoc(AppLocalizations loc, String badgeId) {
    switch (badgeId) {
      case 'beginner':       return loc.badgeBeginner;
      case 'explorer':       return loc.badgeExplorer;
      case 'wordLearner':    return loc.badgeWordLearner;
      case 'wordKnight':     return loc.badgeWordKnight;
      case 'wordMaster':     return loc.badgeWordMaster;
      case 'wordLegend':     return loc.badgeWordLegend;
      case 'idiomFirst':     return loc.badgeIdiomFirst;
      case 'idiomAdept':     return loc.badgeIdiomAdept;
      case 'idiomMaster':    return loc.badgeIdiomMaster;
      case 'proverbFirst':   return loc.badgeProverbFirst;
      case 'proverbAdept':   return loc.badgeProverbAdept;
      case 'proverbSage':    return loc.badgeProverbSage;
      case 'streak3':        return loc.badgeStreak3;
      case 'streak7':        return loc.badgeStreak7;
      case 'streak14':       return loc.badgeStreak14;
      case 'streak30':       return loc.badgeStreak30;
      case 'streak100':      return loc.badgeStreak100;
      case 'poemLover':      return loc.badgePoemLover;
      case 'poemScholar':    return loc.badgePoemScholar;
      case 'collector':      return loc.badgeCollector;
      case 'treasureHunter': return loc.badgeTreasureHunter;
      default:               return badgeId;
    }
  }
}
