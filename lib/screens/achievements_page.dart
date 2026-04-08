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
                  '$unlockedCount / $totalCount',
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
                // ── 类别1: 词语 ──
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.wordsLabel,
                  icon: Icons.auto_stories_rounded,
                  color: const Color(0xFF4285F4),
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'word10' ||
                    b.id.name == 'word50' ||
                    b.id.name == 'word100' ||
                    b.id.name == 'word500' ||
                    b.id.name == 'word1000' ||
                    b.id.name == 'word3000'
                  ).toList(),
                ),
                // ── 类别2: 成语 ──
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.idioms,
                  icon: Icons.lightbulb_outline_rounded,
                  color: Colors.orange,
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'idiom10' ||
                    b.id.name == 'idiom50' ||
                    b.id.name == 'idiom100' ||
                    b.id.name == 'idiom500'
                  ).toList(),
                ),
                // ── 类别3: 谚语 ──
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.proverbs,
                  icon: Icons.format_quote_rounded,
                  color: const Color(0xFF00796B),
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'proverb10' ||
                    b.id.name == 'proverb30' ||
                    b.id.name == 'proverb50' ||
                    b.id.name == 'proverb100'
                  ).toList(),
                ),
                // ── 类别4: 诗词 ──
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.poetry,
                  icon: Icons.nightlight_round,
                  color: const Color(0xFF5C6BC0),
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'poem5' ||
                    b.id.name == 'poem10' ||
                    b.id.name == 'poem50' ||
                    b.id.name == 'poem100'
                  ).toList(),
                ),
                // ── 类别5: 收藏 ──
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.favorites,
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFFE91E63),
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'fav10' ||
                    b.id.name == 'fav50' ||
                    b.id.name == 'fav100' ||
                    b.id.name == 'fav500' ||
                    b.id.name == 'fav1000' ||
                    b.id.name == 'fav3000'
                  ).toList(),
                ),
                // ── 类别6: 连续学习（倒数第二栏） ──
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
                    b.id.name == 'streak30'
                  ).toList(),
                ),
                // ── 类别7: 累计学习天数（最后一栏） ──
                _buildCategorySection(
                  context: context,
                  state: state,
                  title: loc.totalDaysLabel,
                  icon: Icons.calendar_today_rounded,
                  color: const Color(0xFF00BCD4),
                  badges: BadgeDef.all.where((b) =>
                    b.id.name == 'totalDays3' ||
                    b.id.name == 'totalDays7' ||
                    b.id.name == 'totalDays15' ||
                    b.id.name == 'totalDays30' ||
                    b.id.name == 'totalDays100' ||
                    b.id.name == 'totalDays365'
                  ).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      case 'word10':       return loc.badgeWord10;
      case 'word50':       return loc.badgeWord50;
      case 'word100':      return loc.badgeWord100;
      case 'word500':      return loc.badgeWord500;
      case 'word1000':     return loc.badgeWord1000;
      case 'word3000':     return loc.badgeWord3000;
      case 'idiom10':      return loc.badgeIdiom10;
      case 'idiom50':      return loc.badgeIdiom50;
      case 'idiom100':     return loc.badgeIdiom100;
      case 'idiom500':     return loc.badgeIdiom500;
      case 'proverb10':    return loc.badgeProverb10;
      case 'proverb30':    return loc.badgeProverb30;
      case 'proverb50':    return loc.badgeProverb50;
      case 'proverb100':   return loc.badgeProverb100;
      case 'poem5':        return loc.badgePoem5;
      case 'poem10':       return loc.badgePoem10;
      case 'poem50':       return loc.badgePoem50;
      case 'poem100':      return loc.badgePoem100;
      case 'fav10':        return loc.badgeFav10;
      case 'fav50':        return loc.badgeFav50;
      case 'fav100':       return loc.badgeFav100;
      case 'fav500':       return loc.badgeFav500;
      case 'fav1000':      return loc.badgeFav1000;
      case 'fav3000':      return loc.badgeFav3000;
      case 'streak3':      return loc.badgeStreak3;
      case 'streak7':      return loc.badgeStreak7;
      case 'streak14':     return loc.badgeStreak14;
      case 'streak30':     return loc.badgeStreak30;
      case 'totalDays3':   return loc.badgeTotalDays3;
      case 'totalDays7':   return loc.badgeTotalDays7;
      case 'totalDays15':  return loc.badgeTotalDays15;
      case 'totalDays30':  return loc.badgeTotalDays30;
      case 'totalDays100': return loc.badgeTotalDays100;
      case 'totalDays365': return loc.badgeTotalDays365;
      default:             return badgeId;
    }
  }

  /// 获取徽章描述
  String _getBadgeDesc(BuildContext context, String badgeId) {
    final loc = AppLocalizations.of(context)!;
    switch (badgeId) {
      case 'word10':       return loc.badgeWord10Desc;
      case 'word50':       return loc.badgeWord50Desc;
      case 'word100':      return loc.badgeWord100Desc;
      case 'word500':      return loc.badgeWord500Desc;
      case 'word1000':     return loc.badgeWord1000Desc;
      case 'word3000':     return loc.badgeWord3000Desc;
      case 'idiom10':      return loc.badgeIdiom10Desc;
      case 'idiom50':      return loc.badgeIdiom50Desc;
      case 'idiom100':     return loc.badgeIdiom100Desc;
      case 'idiom500':     return loc.badgeIdiom500Desc;
      case 'proverb10':    return loc.badgeProverb10Desc;
      case 'proverb30':    return loc.badgeProverb30Desc;
      case 'proverb50':    return loc.badgeProverb50Desc;
      case 'proverb100':   return loc.badgeProverb100Desc;
      case 'poem5':        return loc.badgePoem5Desc;
      case 'poem10':       return loc.badgePoem10Desc;
      case 'poem50':       return loc.badgePoem50Desc;
      case 'poem100':      return loc.badgePoem100Desc;
      case 'fav10':        return loc.badgeFav10Desc;
      case 'fav50':        return loc.badgeFav50Desc;
      case 'fav100':       return loc.badgeFav100Desc;
      case 'fav500':       return loc.badgeFav500Desc;
      case 'fav1000':      return loc.badgeFav1000Desc;
      case 'fav3000':      return loc.badgeFav3000Desc;
      case 'streak3':      return loc.badgeStreak3Desc;
      case 'streak7':      return loc.badgeStreak7Desc;
      case 'streak14':     return loc.badgeStreak14Desc;
      case 'streak30':     return loc.badgeStreak30Desc;
      case 'totalDays3':   return loc.badgeTotalDays3Desc;
      case 'totalDays7':   return loc.badgeTotalDays7Desc;
      case 'totalDays15':  return loc.badgeTotalDays15Desc;
      case 'totalDays30':  return loc.badgeTotalDays30Desc;
      case 'totalDays100': return loc.badgeTotalDays100Desc;
      case 'totalDays365': return loc.badgeTotalDays365Desc;
      default:             return '';
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

  String _getBadgeTitleFromLoc(AppLocalizations loc, String badgeId) {
    switch (badgeId) {
      case 'word10':       return loc.badgeWord10;
      case 'word50':       return loc.badgeWord50;
      case 'word100':      return loc.badgeWord100;
      case 'word500':      return loc.badgeWord500;
      case 'word1000':     return loc.badgeWord1000;
      case 'word3000':     return loc.badgeWord3000;
      case 'idiom10':      return loc.badgeIdiom10;
      case 'idiom50':      return loc.badgeIdiom50;
      case 'idiom100':     return loc.badgeIdiom100;
      case 'idiom500':     return loc.badgeIdiom500;
      case 'proverb10':    return loc.badgeProverb10;
      case 'proverb30':    return loc.badgeProverb30;
      case 'proverb50':    return loc.badgeProverb50;
      case 'proverb100':   return loc.badgeProverb100;
      case 'poem5':        return loc.badgePoem5;
      case 'poem10':       return loc.badgePoem10;
      case 'poem50':       return loc.badgePoem50;
      case 'poem100':      return loc.badgePoem100;
      case 'fav10':        return loc.badgeFav10;
      case 'fav50':        return loc.badgeFav50;
      case 'fav100':       return loc.badgeFav100;
      case 'fav500':       return loc.badgeFav500;
      case 'fav1000':      return loc.badgeFav1000;
      case 'fav3000':      return loc.badgeFav3000;
      case 'streak3':      return loc.badgeStreak3;
      case 'streak7':      return loc.badgeStreak7;
      case 'streak14':     return loc.badgeStreak14;
      case 'streak30':     return loc.badgeStreak30;
      case 'totalDays3':   return loc.badgeTotalDays3;
      case 'totalDays7':   return loc.badgeTotalDays7;
      case 'totalDays15':  return loc.badgeTotalDays15;
      case 'totalDays30':  return loc.badgeTotalDays30;
      case 'totalDays100': return loc.badgeTotalDays100;
      case 'totalDays365': return loc.badgeTotalDays365;
      default:             return badgeId;
    }
  }
}
