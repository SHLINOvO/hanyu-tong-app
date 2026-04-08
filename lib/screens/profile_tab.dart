import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/word_repository.dart';
import '../models/idiom_repository.dart';
import '../models/proverb_repository.dart';
import '../models/poetry_repository.dart';
import '../models/badge_model.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // 各类型总数据量
  int _totalWords = 0;
  int _totalIdioms = 0;
  int _totalProverbs = 0;
  int _totalPoems = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTotals();
  }

  Future<void> _loadTotals() async {
    final state = context.read<AppState>();
    // 根据用户当前难度加载对应的词语总数
    final words = await WordRepository.loadWords(state.level);
    // 成语、谚语、诗词加载全部
    final idioms = await IdiomRepository.loadIdioms();
    final proverbs = await ProverbRepository.loadProverbs();
    final poems = await PoetryRepository.loadPoetry();

    if (mounted) {
      setState(() {
        _totalWords = words.length;
        _totalIdioms = idioms.length;
        _totalProverbs = proverbs.length;
        _totalPoems = poems.length;
        _isLoading = false;
      });
      // 检查并解锁徽章
      state.checkAndUnlockBadges(totalWords: words.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final loc = AppLocalizations.of(context)!;

    // 计算各类型百分比
    final wordsPercent = _totalWords > 0 ? (state.masteredWords / _totalWords * 100).round() : 0;
    final idiomsPercent = _totalIdioms > 0 ? (state.masteredIdioms / _totalIdioms * 100).round() : 0;
    final proverbsPercent = _totalProverbs > 0 ? (state.masteredProverbs / _totalProverbs * 100).round() : 0;
    final poemsPercent = _totalPoems > 0 ? (state.learnedPoems / _totalPoems * 100).round() : 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4285F4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.username,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333))),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: const Icon(Icons.notifications_outlined,
                      color: Color(0xFF666666)),
                ),
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.settings_outlined,
                      color: Color(0xFF666666)),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Achievements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.myAchievements,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333))),
                TextButton(
                  onPressed: () => context.push('/achievements'),
                  child: Text(
                    loc.viewAll,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 最新4个成就横向展示
            _buildLatestBadges(state),
            const SizedBox(height: 32),

            // Learning Progress
            Text(loc.learningProgress,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333))),
            const SizedBox(height: 16),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF4285F4)),
                    ),
                  )
                : Column(
                    children: [
                      _buildProgressBar('📝 ${loc.wordsLabel}', wordsPercent, const Color(0xFF4285F4)),
                      _buildProgressBar('🀄 ${loc.idioms}', idiomsPercent, Colors.orange),
                      _buildProgressBar('📜 ${loc.proverbs}', proverbsPercent, Colors.green),
                      _buildProgressBar('🎋 ${loc.poetry}', poemsPercent, Colors.purple),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // ---------- 成就组件 ----------

  /// 构建最新成就展示（最多4个）
  Widget _buildLatestBadges(AppState state) {
    final loc = AppLocalizations.of(context)!;
    final latestBadges = state.getLatestUnlockedBadges(4);

    if (latestBadges.isEmpty) {
      // 无成就时显示提示
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            loc.startLearningToUnlockAchievements,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: Row(
        children: [
          for (int i = 0; i < latestBadges.length; i++) ...[
            Expanded(
              child: _buildMiniBadgeCard(
                badgeId: latestBadges[i],
                state: state,
              ),
            ),
            if (i < latestBadges.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  /// 小型成就卡片
  Widget _buildMiniBadgeCard({
    required String badgeId,
    required AppState state,
  }) {
    final badge = BadgeDef.all.firstWhere(
      (b) => b.id.name == badgeId,
      orElse: () => BadgeDef.all.first,
    );
    final unlocked = state.unlockedBadgeIds.contains(badgeId);

    return GestureDetector(
      onTap: () => _showBadgeDialog(context, badge, unlocked),
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
          padding: const EdgeInsets.all(10),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked
                      ? badge.color.withValues(alpha: 0.15)
                      : const Color(0xFFF0F0F0),
                ),
                child: Icon(
                  badge.icon,
                  size: 22,
                  color: unlocked ? badge.color : const Color(0xFFBDBDBD),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getBadgeTitle(badgeId),
                style: TextStyle(
                  fontSize: 11,
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

  /// 获取徽章标题（根据 badge id）
  String _getBadgeTitle(String badgeId) {
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
  String _getBadgeDesc(String badgeId) {
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
            // 徽章图标
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
            // 徽章名称
            Text(
              _getBadgeTitle(badge.id.name),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: unlocked ? const Color(0xFF333333) : const Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 8),
            // 徽章描述
            Text(
              _getBadgeDesc(badge.id.name),
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // 解锁状态标签
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

  Widget _buildProgressBar(String label, int percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666))),
              Text('$percent%',
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
              value: percent / 100.0,
              backgroundColor: const Color(0xFFE0E0E0),
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
