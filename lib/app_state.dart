import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// ASR 引擎选项
enum AsrEngine {
  auto,   // 自动选择（根据语言推荐）
  qwen,   // 通义千问（云端，速度快，支持英/俄/土/阿）
  whisper, // Whisper 本地（支持全部 8 种语言）
}

/// 全局状态，对应 React 版本的 AppContext
class AppState extends ChangeNotifier {
  // ---------- 用户设置 ----------
  String _language = 'en';
  String _level = 'beginner';
  int _dailyGoal = 15;
  bool _isOnboarded = false;
  String _username = '';
  AsrEngine _asrEngine = AsrEngine.auto; // 第二步语义评分 ASR 引擎
  AsrEngine _chineseAsrEngine = AsrEngine.qwen; // 第一步中文语音识别引擎（默认千问）

  // ---------- 学习统计 ----------
  int _streak = 0;
  int _totalDays = 0;
  int _totalMinutes = 0; // 累计学习分钟数

  // ---------- 今日学习时长 ----------
  int _learningTime = 0;

  // ---------- 计时器相关 ----------
  DateTime? _sessionStartTime; // 本次学习会话开始时间
  DateTime? _lastLearningDate; // 上次学习日期,用于计算连续天数
  bool _goalReachedToday = false; // 今天是否已达成目标

  // ---------- 收藏（List 保留收藏顺序，越后面的越新） ----------
  List<String> _favorites = [];

  // ---------- 已掌握（List 保留掌握顺序，越后面的越新） ----------
  List<String> _masteredWordIds = [];
  List<String> _masteredIdiomIds = [];
  Set<String> _masteredProverbIds = {};

  // ---------- 诗词已学习（中文释义和母语释义都点过才标记） ----------
  Set<String> _learnedPoemIds = {};

  // ---------- 已访问的学习内容类型（用于 explorer 徽章） ----------
  Set<String> _visitedSections = {};

  // ---------- 已解锁徽章 ----------
  Set<String> _unlockedBadgeIds = {};
  // ---------- 徽章解锁时间（用于确定最新成就） ----------
  Map<String, DateTime> _badgeUnlockTimes = {};

  // ---------- Getters ----------
  String get language => _language;
  String get level => _level;
  int get dailyGoal => _dailyGoal;
  bool get isOnboarded => _isOnboarded;
  String get username => _username.isEmpty ? 'Learner' : _username;
  AsrEngine get asrEngine => _asrEngine;
  AsrEngine get chineseAsrEngine => _chineseAsrEngine;
  int get streak => _streak;
  int get totalDays => _totalDays;
  /// 累计学习时长（小时），每 30 分钟进 0.5 小时
  double get totalHours => (_totalMinutes / 30).ceilToDouble() * 0.5;
  int get masteredWords => _masteredWordIds.length;
  int get masteredIdioms => _masteredIdiomIds.length;
  int get masteredProverbs => _masteredProverbIds.length;
  int get learningTime => _learningTime;
  Set<String> get favorites => _favorites.toSet();
  List<String> get favoritesOrdered => _favorites; // 有序列表，供收藏页倒序使用
  List<String> get masteredWordIds => _masteredWordIds;
  List<String> get masteredIdiomIds => _masteredIdiomIds;
  Set<String> get masteredProverbIds => _masteredProverbIds;
  Set<String> get learnedPoemIds => _learnedPoemIds;
  int get learnedPoems => _learnedPoemIds.length;
  Set<String> get visitedSections => _visitedSections;
  Set<String> get unlockedBadgeIds => _unlockedBadgeIds;
  Map<String, DateTime> get badgeUnlockTimes => _badgeUnlockTimes;

  /// 获取最新解锁的N个成就ID（按解锁时间倒序）
  List<String> getLatestUnlockedBadges(int count) {
    final sorted = _badgeUnlockTimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // 最新的在前
    return sorted.take(count).map((e) => e.key).toList();
  }

  // ---------- 初始化（从 SharedPreferences 读取） ----------
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('language') ?? 'en';
    _level = prefs.getString('level') ?? 'beginner';
    _dailyGoal = prefs.getInt('dailyGoal') ?? 15;
    _isOnboarded = prefs.getBool('isOnboarded') ?? false;
    _username = prefs.getString('username') ?? '';
    // 读取 ASR 引擎设置
    final asrEngineStr = prefs.getString('asrEngine');
    if (asrEngineStr != null) {
      _asrEngine = AsrEngine.values.firstWhere(
        (e) => e.name == asrEngineStr,
        orElse: () => AsrEngine.auto,
      );
    }
    // 读取中文语音识别引擎设置
    final chineseAsrEngineStr = prefs.getString('chineseAsrEngine');
    if (chineseAsrEngineStr != null) {
      _chineseAsrEngine = AsrEngine.values.firstWhere(
        (e) => e.name == chineseAsrEngineStr,
        orElse: () => AsrEngine.qwen,
      );
    }
    _streak = prefs.getInt('streak') ?? 0;
    _totalDays = prefs.getInt('totalDays') ?? 0;
    // 兼容旧版 totalHours（int，单位小时），转为分钟数
    final oldTotalHours = prefs.getInt('totalHours') ?? 0;
    _totalMinutes = prefs.getInt('totalMinutes') ?? (oldTotalHours * 60);
    _learningTime = prefs.getInt('todayLearningTime') ?? 0;
    final lastDateStr = prefs.getString('lastLearningDate');
    if (lastDateStr != null) {
      _lastLearningDate = DateTime.parse(lastDateStr);
    }
    _goalReachedToday = prefs.getBool('goalReachedToday') ?? false;

    // 检查是否是新的一天,重置今日学习时间
    _checkNewDay();

    final favJson = prefs.getString('favorites');
    if (favJson != null) {
      final List list = jsonDecode(favJson);
      _favorites = list.cast<String>().toList();
    }

    final masteredJson = prefs.getString('masteredWordIds');
    if (masteredJson != null) {
      final List list = jsonDecode(masteredJson);
      _masteredWordIds = list.cast<String>().toList();
    }

    final idiomJson = prefs.getString('masteredIdiomIds');
    if (idiomJson != null) {
      final List list = jsonDecode(idiomJson);
      _masteredIdiomIds = list.cast<String>().toList();
    }

    final proverbJson = prefs.getString('masteredProverbIds');
    if (proverbJson != null) {
      final List list = jsonDecode(proverbJson);
      _masteredProverbIds = list.cast<String>().toSet();
    }

    final learnedPoemJson = prefs.getString('learnedPoemIds');
    if (learnedPoemJson != null) {
      final List list = jsonDecode(learnedPoemJson);
      _learnedPoemIds = list.cast<String>().toSet();
    }

    final badgeJson = prefs.getString('unlockedBadgeIds');
    if (badgeJson != null) {
      final List list = jsonDecode(badgeJson);
      _unlockedBadgeIds = list.cast<String>().toSet();
    }

    // 读取徽章解锁时间
    final badgeTimeJson = prefs.getString('badgeUnlockTimes');
    if (badgeTimeJson != null) {
      final Map<String, dynamic> map = jsonDecode(badgeTimeJson);
      _badgeUnlockTimes = map.map((k, v) => MapEntry(k, DateTime.parse(v as String)));
    }

    final visitedJson = prefs.getString('visitedSections');
    if (visitedJson != null) {
      final List list = jsonDecode(visitedJson);
      _visitedSections = list.cast<String>().toSet();
    }
  }

  // 检查是否是新的学习日期,并处理连续学习天数
  void _checkNewDay() {
    if (_lastLearningDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastDate = DateTime(_lastLearningDate!.year, _lastLearningDate!.month, _lastLearningDate!.day);

      final difference = today.difference(lastDate).inDays;

      if (difference > 1) {
        // 如果超过一天没有学习,连续天数归零
        if (_streak > 0) {
          _streak = 0;
          _save((p) async => p.setInt('streak', 0));
        }
      }

      if (difference >= 1) {
        // 新的一天,重置今日学习时间和达成目标标志
        _learningTime = 0;
        _goalReachedToday = false;
        _save((p) async {
          p.setInt('todayLearningTime', 0);
          p.setBool('goalReachedToday', false);
        });
      }
    }
  }

  Future<void> _save(Future<void> Function(SharedPreferences) fn) async {
    final prefs = await SharedPreferences.getInstance();
    await fn(prefs);
  }

  void setLanguage(String lang) {
    _language = lang;
    _save((p) async => p.setString('language', lang));
    notifyListeners();
  }

  void setLevel(String lvl) {
    _level = lvl;
    _save((p) async => p.setString('level', lvl));
    notifyListeners();
  }

  void setDailyGoal(int goal) {
    _dailyGoal = goal;
    _save((p) async => p.setInt('dailyGoal', goal));
    notifyListeners();
  }

  void setIsOnboarded(bool value) {
    _isOnboarded = value;
    _save((p) async => p.setBool('isOnboarded', value));
    notifyListeners();
  }

  // 重置引导状态(用于测试)
  void resetOnboarding() {
    _isOnboarded = false;
    _save((p) async => p.setBool('isOnboarded', false));
    notifyListeners();
  }

  // 重置学习记录（保留用户设置，只清除学习数据）
  void resetLearningData() {
    // 清除已掌握的词语/成语/谚语/诗词
    _masteredWordIds = [];
    _masteredIdiomIds = [];
    _masteredProverbIds = {};
    _learnedPoemIds = {};

    // 清除收藏
    _favorites = [];

    // 清除学习统计
    _streak = 0;
    _totalDays = 0;
    _totalMinutes = 0;

    // 清除今日学习状态
    _learningTime = 0;
    _goalReachedToday = false;
    _sessionStartTime = null;
    _lastLearningDate = null;

    // 清除已解锁的徽章
    _unlockedBadgeIds = {};
    _badgeUnlockTimes = {};

    _save((p) async {
      // 已掌握数据
      await p.remove('masteredWordIds');
      await p.remove('masteredIdiomIds');
      await p.remove('masteredProverbIds');
      await p.remove('learnedPoemIds');
      // 收藏
      await p.remove('favorites');
      // 学习统计
      await p.setInt('streak', 0);
      await p.setInt('totalDays', 0);
      await p.setInt('totalMinutes', 0);
      // 今日学习状态
      await p.setInt('todayLearningTime', 0);
      await p.setBool('goalReachedToday', false);
      await p.remove('lastLearningDate');
      // 徽章 & 访问记录
      await p.remove('unlockedBadgeIds');
      await p.remove('badgeUnlockTimes');
      await p.remove('visitedSections');
    });
    notifyListeners();
  }

  void setUsername(String name) {
    _username = name;
    _save((p) async => p.setString('username', name));
    notifyListeners();
  }

  void setAsrEngine(AsrEngine engine) {
    _asrEngine = engine;
    _save((p) async => p.setString('asrEngine', engine.name));
    notifyListeners();
  }

  void setChineseAsrEngine(AsrEngine engine) {
    _chineseAsrEngine = engine;
    _save((p) async => p.setString('chineseAsrEngine', engine.name));
    notifyListeners();
  }

  void toggleFavorite(String item) {
    final newList = List<String>.from(_favorites);
    if (newList.contains(item)) {
      newList.remove(item);
    } else {
      newList.add(item); // 追加到末尾，越新收藏越靠后
    }
    _favorites = newList;
    _save((p) async => p.setString('favorites', jsonEncode(newList)));
    notifyListeners();
  }

  /// 将词语标记为已掌握（两步测评都通过后调用）
  void markWordMastered(String wordId) {
    if (_masteredWordIds.contains(wordId)) return;
    _masteredWordIds.add(wordId);  // 追加到末尾，越新掌握的越靠后
    _save((p) async {
      p.setString('masteredWordIds', jsonEncode(_masteredWordIds));
    });
    notifyListeners();
  }

  /// 将成语标记为已掌握
  void markIdiomMastered(String idiomId) {
    if (_masteredIdiomIds.contains(idiomId)) return;
    _masteredIdiomIds.add(idiomId); // 追加到末尾，越新掌握越靠后
    _save((p) async {
      p.setString('masteredIdiomIds', jsonEncode(_masteredIdiomIds));
    });
    notifyListeners();
  }

  /// 将谚语标记为已掌握
  void markProverbMastered(String proverbId) {
    if (_masteredProverbIds.contains(proverbId)) return;
    _masteredProverbIds.add(proverbId);
    _save((p) async {
      p.setString('masteredProverbIds', jsonEncode(_masteredProverbIds.toList()));
    });
    notifyListeners();
  }

  /// 标记诗词为已学习（中文释义和母语释义都查看后才调用）
  void markPoemLearned(String poemId) {
    if (_learnedPoemIds.contains(poemId)) return;
    _learnedPoemIds.add(poemId);
    _save((p) async {
      p.setString('learnedPoemIds', jsonEncode(_learnedPoemIds.toList()));
    });
    notifyListeners();
  }

  /// 标记已访问某学习内容类型（用于 explorer 徽章）
  void markSectionVisited(String section) {
    if (_visitedSections.contains(section)) return;
    _visitedSections.add(section);
    _save((p) async {
      p.setString('visitedSections', jsonEncode(_visitedSections.toList()));
    });
    notifyListeners();
  }

  // 开始学习计时(进入学习页面时调用)
  void startLearningSession() {
    _checkNewDay(); // 检查是否是新的一天
    _sessionStartTime ??= DateTime.now();
  }

  // 结束学习计时(退出学习页面时调用)
  void endLearningSession() {
    if (_sessionStartTime != null) {
      final now = DateTime.now();
      final duration = now.difference(_sessionStartTime!).inMinutes;

      if (duration > 0) {
        addLearningTime(duration);
      }

      _sessionStartTime = null;

      // 更新最后学习日期
      _lastLearningDate = DateTime.now();
      _save((p) async => p.setString('lastLearningDate', _lastLearningDate!.toIso8601String()));
    }
  }

  // 手动添加学习时间
  void addLearningTime(int minutes) {
    final prev = _learningTime;
    _learningTime += minutes;
    _totalMinutes += minutes;

    // 如果达到目标且今天还没达到过，更新连续天数和累计天数
    if (prev < _dailyGoal && _learningTime >= _dailyGoal && !_goalReachedToday) {
      _goalReachedToday = true;
      _streak++;
      _totalDays++;
      _save((p) async {
        p.setInt('streak', _streak);
        p.setInt('totalDays', _totalDays);
        p.setBool('goalReachedToday', _goalReachedToday);
      });
    }

    _save((p) async {
      p.setInt('todayLearningTime', _learningTime);
      p.setInt('totalMinutes', _totalMinutes);
    });
    notifyListeners();
  }

  // ---------- 徽章解锁 ----------

  /// 解锁指定徽章（已解锁则忽略）
  void unlockBadge(String badgeId) {
    if (_unlockedBadgeIds.contains(badgeId)) return;
    _unlockedBadgeIds.add(badgeId);
    _badgeUnlockTimes[badgeId] = DateTime.now();
    _save((p) async {
      p.setString('unlockedBadgeIds', jsonEncode(_unlockedBadgeIds.toList()));
      p.setString('badgeUnlockTimes', jsonEncode(
        _badgeUnlockTimes.map((k, v) => MapEntry(k, v.toIso8601String())),
      ));
    });
    notifyListeners();
  }

  /// 检查并解锁徽章（在学习数据变化后调用）
  /// [totalWords] 当前难度总词数（用于检查全部掌握）
  void checkAndUnlockBadges({int totalWords = 0}) {
    // ── 类别1: 词语 ──
    // 掌握 10 个词语
    if (_masteredWordIds.length >= 10) unlockBadge('word10');
    // 掌握 50 个词语
    if (_masteredWordIds.length >= 50) unlockBadge('word50');
    // 掌握 100 个词语
    if (_masteredWordIds.length >= 100) unlockBadge('word100');
    // 掌握 500 个词语
    if (_masteredWordIds.length >= 500) unlockBadge('word500');
    // 掌握 1000 个词语
    if (_masteredWordIds.length >= 1000) unlockBadge('word1000');
    // 掌握 3000 个词语
    if (_masteredWordIds.length >= 3000) unlockBadge('word3000');

    // ── 类别2: 成语 ──
    // 掌握 10 个成语
    if (_masteredIdiomIds.length >= 10) unlockBadge('idiom10');
    // 掌握 50 个成语
    if (_masteredIdiomIds.length >= 50) unlockBadge('idiom50');
    // 掌握 100 个成语
    if (_masteredIdiomIds.length >= 100) unlockBadge('idiom100');
    // 掌握 500 个成语
    if (_masteredIdiomIds.length >= 500) unlockBadge('idiom500');

    // ── 类别3: 谚语 ──
    // 掌握 10 个谚语
    if (_masteredProverbIds.length >= 10) unlockBadge('proverb10');
    // 掌握 30 个谚语
    if (_masteredProverbIds.length >= 30) unlockBadge('proverb30');
    // 掌握 50 个谚语
    if (_masteredProverbIds.length >= 50) unlockBadge('proverb50');
    // 掌握 100 个谚语
    if (_masteredProverbIds.length >= 100) unlockBadge('proverb100');

    // ── 类别4: 诗词 ──
    // 学习 5 首诗词
    if (_learnedPoemIds.length >= 5) unlockBadge('poem5');
    // 学习 10 首诗词
    if (_learnedPoemIds.length >= 10) unlockBadge('poem10');
    // 学习 50 首诗词
    if (_learnedPoemIds.length >= 50) unlockBadge('poem50');
    // 学习 100 首诗词
    if (_learnedPoemIds.length >= 100) unlockBadge('poem100');

    // ── 类别5: 收藏 ──
    // 收藏 10 个
    if (_favorites.length >= 10) unlockBadge('fav10');
    // 收藏 50 个
    if (_favorites.length >= 50) unlockBadge('fav50');
    // 收藏 100 个
    if (_favorites.length >= 100) unlockBadge('fav100');
    // 收藏 500 个
    if (_favorites.length >= 500) unlockBadge('fav500');
    // 收藏 1000 个
    if (_favorites.length >= 1000) unlockBadge('fav1000');
    // 收藏 3000 个
    if (_favorites.length >= 3000) unlockBadge('fav3000');

    // ── 类别6: 连续学习 ──
    // 连续学习 3 天
    if (_streak >= 3) unlockBadge('streak3');
    // 连续学习 7 天
    if (_streak >= 7) unlockBadge('streak7');
    // 连续学习 14 天
    if (_streak >= 14) unlockBadge('streak14');
    // 连续学习 30 天
    if (_streak >= 30) unlockBadge('streak30');

    // ── 类别7: 累计学习天数 ──
    // 累计学习 3 天
    if (_totalDays >= 3) unlockBadge('totalDays3');
    // 累计学习 7 天
    if (_totalDays >= 7) unlockBadge('totalDays7');
    // 累计学习 15 天
    if (_totalDays >= 15) unlockBadge('totalDays15');
    // 累计学习 30 天
    if (_totalDays >= 30) unlockBadge('totalDays30');
    // 累计学习 100 天
    if (_totalDays >= 100) unlockBadge('totalDays100');
    // 累计学习 365 天
    if (_totalDays >= 365) unlockBadge('totalDays365');
  }
}
