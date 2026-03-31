import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BadgeCategory { streak, workout, variety, time }

class AchievementBadge {
  final String id;
  final String icon;
  final BadgeCategory category;
  final Color color;

  const AchievementBadge({
    required this.id,
    required this.icon,
    required this.category,
    required this.color,
  });
}

class UserLevel {
  final int level;
  final String titleKey; // translation key
  final String icon;
  final int minBadges;
  final int maxBadges; // badges needed to reach next level
  final Color color;

  const UserLevel({
    required this.level,
    required this.titleKey,
    required this.icon,
    required this.minBadges,
    required this.maxBadges,
    required this.color,
  });
}

class BadgeCheckResult {
  final List<String> newBadges;
  final bool leveledUp;
  final UserLevel? newLevel;

  BadgeCheckResult({
    required this.newBadges,
    required this.leveledUp,
    this.newLevel,
  });
}

class GamificationService extends ChangeNotifier {
  static const bool _useDummyData = true; // TODO: set to false for production

  Set<String> _unlockedBadges = {};
  int _currentStreak = 0;
  int _bestStreak = 0;

  Set<String> get unlockedBadges => _unlockedBadges;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;

  static const List<UserLevel> levels = [
    UserLevel(level: 1, titleKey: 'level_1', icon: '🌱', minBadges: 0, maxBadges: 2, color: Colors.grey),
    UserLevel(level: 2, titleKey: 'level_2', icon: '🔥', minBadges: 2, maxBadges: 5, color: Colors.green),
    UserLevel(level: 3, titleKey: 'level_3', icon: '⚡', minBadges: 5, maxBadges: 8, color: Colors.blue),
    UserLevel(level: 4, titleKey: 'level_4', icon: '💪', minBadges: 8, maxBadges: 11, color: Colors.purple),
    UserLevel(level: 5, titleKey: 'level_5', icon: '🏆', minBadges: 11, maxBadges: 14, color: Colors.orange),
    UserLevel(level: 6, titleKey: 'level_6', icon: '👑', minBadges: 14, maxBadges: 17, color: Colors.amber),
    UserLevel(level: 7, titleKey: 'level_7', icon: '🐉', minBadges: 17, maxBadges: 17, color: Color(0xFFFFD700)),
  ];

  UserLevel get currentLevel {
    final count = _unlockedBadges.length;
    for (int i = levels.length - 1; i >= 0; i--) {
      if (count >= levels[i].minBadges) return levels[i];
    }
    return levels[0];
  }

  bool get isMaxLevel => currentLevel.level == levels.last.level;

  double get levelProgress {
    final lvl = currentLevel;
    final count = _unlockedBadges.length;
    if (isMaxLevel) return 1.0;
    if (lvl.maxBadges == lvl.minBadges) return 1.0;
    return (count - lvl.minBadges) / (lvl.maxBadges - lvl.minBadges);
  }

  int get badgesForNextLevel {
    if (isMaxLevel) return 0;
    final lvl = currentLevel;
    return lvl.maxBadges - _unlockedBadges.length;
  }

  static const List<AchievementBadge> allBadges = [
    // Streak badges
    AchievementBadge(id: 'streak_3', icon: '🔥', category: BadgeCategory.streak, color: Colors.orange),
    AchievementBadge(id: 'streak_7', icon: '💥', category: BadgeCategory.streak, color: Colors.deepOrange),
    AchievementBadge(id: 'streak_14', icon: '⚡', category: BadgeCategory.streak, color: Colors.amber),
    AchievementBadge(id: 'streak_30', icon: '🏆', category: BadgeCategory.streak, color: Color(0xFFFFD700)),

    // Workout count badges
    AchievementBadge(id: 'wod_1', icon: '💪', category: BadgeCategory.workout, color: Colors.blue),
    AchievementBadge(id: 'wod_10', icon: '🥊', category: BadgeCategory.workout, color: Colors.indigo),
    AchievementBadge(id: 'wod_25', icon: '🦾', category: BadgeCategory.workout, color: Colors.purple),
    AchievementBadge(id: 'wod_50', icon: '👑', category: BadgeCategory.workout, color: Color(0xFFFFD700)),
    AchievementBadge(id: 'wod_100', icon: '🐉', category: BadgeCategory.workout, color: Colors.red),

    // Variety badges
    AchievementBadge(id: 'all_types', icon: '🌟', category: BadgeCategory.variety, color: Colors.teal),
    AchievementBadge(id: 'amrap_10', icon: '🔄', category: BadgeCategory.variety, color: Colors.orange),
    AchievementBadge(id: 'emom_10', icon: '⏱️', category: BadgeCategory.variety, color: Colors.blue),
    AchievementBadge(id: 'tabata_10', icon: '🔴', category: BadgeCategory.variety, color: Colors.red),
    AchievementBadge(id: 'running_10', icon: '🏃', category: BadgeCategory.variety, color: Colors.purple),

    // Time badges
    AchievementBadge(id: 'time_1h', icon: '⏳', category: BadgeCategory.time, color: Colors.green),
    AchievementBadge(id: 'time_5h', icon: '🕐', category: BadgeCategory.time, color: Colors.teal),
    AchievementBadge(id: 'time_10h', icon: '💎', category: BadgeCategory.time, color: Colors.cyan),
  ];

  static AchievementBadge getBadge(String id) {
    return allBadges.firstWhere((b) => b.id == id);
  }

  GamificationService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (_useDummyData) {
      // Dummy badges for preview — 4 badges = Level 2
      // Completing any workout will unlock 'wod_1' → 5 badges = Level 3 (level up!)
      _unlockedBadges = {
        'streak_3', 'streak_7',
        'time_1h', 'all_types',
      };
      await prefs.setStringList('unlocked_badges', _unlockedBadges.toList());
    } else {
      _unlockedBadges = (prefs.getStringList('unlocked_badges') ?? []).toSet();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlocked_badges', _unlockedBadges.toList());
  }

  /// Check for new badges after a workout is completed.
  /// Returns ({newBadges, leveledUp, newLevel}).
  Future<BadgeCheckResult> checkAndUnlockBadges() async {
    final previousLevel = currentLevel.level;
    final prefs = await SharedPreferences.getInstance();
    final historyStrings = prefs.getStringList('workout_history') ?? [];

    if (historyStrings.isEmpty) {
      return BadgeCheckResult(newBadges: [], leveledUp: false);
    }

    // Parse workout history
    final workouts = historyStrings.map((s) {
      final parts = s.split('|');
      return _WorkoutData(
        type: parts[0],
        duration: int.parse(parts[1]),
        date: DateTime.parse(parts[3]),
      );
    }).toList();

    final totalWorkouts = workouts.length;
    final totalSeconds = workouts.fold<int>(0, (sum, w) => sum + w.duration);

    // Count by type
    final typeCounts = <String, int>{};
    final typesSeen = <String>{};
    for (final w in workouts) {
      typeCounts[w.type] = (typeCounts[w.type] ?? 0) + 1;
      typesSeen.add(w.type);
    }

    // Calculate streaks
    final workoutDays = workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .toList()
      ..sort();

    _currentStreak = _calculateCurrentStreak(workoutDays);
    _bestStreak = _calculateBestStreak(workoutDays);

    // Check all badge conditions
    final newBadges = <String>[];

    void check(String id, bool condition) {
      if (condition && !_unlockedBadges.contains(id)) {
        _unlockedBadges.add(id);
        newBadges.add(id);
      }
    }

    // Streak badges
    final maxStreak = _bestStreak;
    check('streak_3', maxStreak >= 3);
    check('streak_7', maxStreak >= 7);
    check('streak_14', maxStreak >= 14);
    check('streak_30', maxStreak >= 30);

    // Workout count badges
    check('wod_1', totalWorkouts >= 1);
    check('wod_10', totalWorkouts >= 10);
    check('wod_25', totalWorkouts >= 25);
    check('wod_50', totalWorkouts >= 50);
    check('wod_100', totalWorkouts >= 100);

    // Variety badges
    check('all_types', typesSeen.containsAll(['AMRAP', 'EMOM', 'TABATA', 'COUNTDOWN', 'RUNNING']));
    check('amrap_10', (typeCounts['AMRAP'] ?? 0) >= 10);
    check('emom_10', (typeCounts['EMOM'] ?? 0) >= 10);
    check('tabata_10', (typeCounts['TABATA'] ?? 0) >= 10);
    check('running_10', (typeCounts['RUNNING'] ?? 0) >= 10);

    // Time badges (in hours)
    final totalHours = totalSeconds / 3600;
    check('time_1h', totalHours >= 1);
    check('time_5h', totalHours >= 5);
    check('time_10h', totalHours >= 10);

    if (newBadges.isNotEmpty) {
      await _save();
      notifyListeners();
    }

    final newLevelNum = currentLevel.level;
    final didLevelUp = newLevelNum > previousLevel;

    return BadgeCheckResult(
      newBadges: newBadges,
      leveledUp: didLevelUp,
      newLevel: didLevelUp ? currentLevel : null,
    );
  }

  int _calculateCurrentStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final daySet = sortedDays.toSet();

    if (!daySet.contains(today) && !daySet.contains(yesterday)) {
      return 0;
    }

    var checkDate = daySet.contains(today) ? today : yesterday;
    int streak = 0;

    while (daySet.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _calculateBestStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) return 0;
    if (sortedDays.length == 1) return 1;

    int best = 1;
    int current = 1;

    for (int i = 1; i < sortedDays.length; i++) {
      if (sortedDays[i].difference(sortedDays[i - 1]).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }

    return best;
  }
}

class _WorkoutData {
  final String type;
  final int duration;
  final DateTime date;

  _WorkoutData({
    required this.type,
    required this.duration,
    required this.date,
  });
}
