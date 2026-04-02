import 'dart:convert';

import 'package:programming_learn_app/core/utils/date_utils.dart';
import 'package:programming_learn_app/data/models/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String keyTotalXP = 'totalXP';
  static const String keyCurrentStreak = 'currentStreak';
  static const String keyLastActiveDate = 'lastActiveDate';
  static const String keySelectedLevel = 'selectedLevel';
  static const String keyPlacementLevel = 'placementLevel';
  static const String keyPlacementScore = 'placementScore';
  static const String keyPlacementCompleted = 'placementCompleted';
  static const String keyLives = 'lives';
  static const String keyUserProfileJson = 'userProfileJson';
  static const String keyOnboardingCompleted = 'onboardingCompleted';
  static const String keyTodayXP = 'todayXP';
  static const String keyTodayXPDate = 'todayXPDate';
  static const String keyLastLivesResetDate = 'lastLivesResetDate';
  static const String keyLongestStreak = 'longestStreak';
  static const String keyLastFunFactIndex = 'lastFunFactIndex';
  static const String keyChallengesCompleted = 'challengesCompleted';
  static const String keyUnlockedAchievements = 'unlockedAchievements';
  static const String keyLastMascotMessage = 'lastMascotMessage';
  static const String keyAppLaunchDate = 'appLaunchDate';
  static const String keyFixTheBugCompleted = 'fixTheBugCompleted';

  String _todayActivityKey() {
    return 'activity_${AppDateUtils.todayIsoDate()}';
  }

  String _challengeDayKey(String date) {
    return 'challenge_done_$date';
  }

  Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyTotalXP) ?? 0;
  }

  Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyTotalXP) ?? 0;
    await _resetTodayXpIfNeeded(prefs);
    final today = prefs.getInt(keyTodayXP) ?? 0;
    await prefs.setInt(keyTotalXP, current + amount);
    await prefs.setInt(keyTodayXP, today + amount);
    final todayActivity = prefs.getInt(_todayActivityKey()) ?? 0;
    await prefs.setInt(_todayActivityKey(), todayActivity + amount);
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyCurrentStreak) ?? 0;
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = AppDateUtils.todayIsoDate();
    final lastActiveRaw = prefs.getString(keyLastActiveDate);
    final currentStreak = prefs.getInt(keyCurrentStreak) ?? 0;
    final longestStreak = prefs.getInt(keyLongestStreak) ?? 0;

    if (lastActiveRaw == null) {
      await prefs.setInt(keyCurrentStreak, 1);
      await prefs.setInt(keyLongestStreak, longestStreak < 1 ? 1 : longestStreak);
      await prefs.setString(keyLastActiveDate, today);
      return;
    }

    final lastActiveDate = AppDateUtils.parseIsoDate(lastActiveRaw);
    final now = AppDateUtils.parseIsoDate(today);
    final diff = AppDateUtils.dayDifference(lastActiveDate, now);

    if (diff == 0) {
      return;
    }

    if (diff == 1) {
      final nextStreak = currentStreak + 1;
      await prefs.setInt(keyCurrentStreak, nextStreak);
      await prefs.setInt(keyLongestStreak, nextStreak > longestStreak ? nextStreak : longestStreak);
    } else {
      await prefs.setInt(keyCurrentStreak, 1);
      await prefs.setInt(keyLongestStreak, longestStreak < 1 ? 1 : longestStreak);
    }

    await prefs.setString(keyLastActiveDate, today);
  }

  Future<int> getLongestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyLongestStreak) ?? 0;
  }

  Future<void> setLongestStreak(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLongestStreak, value);
  }

  Future<void> updateLongestStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyLongestStreak) ?? 0;
    if (streak > current) {
      await prefs.setInt(keyLongestStreak, streak);
    }
  }

  Future<int> getLives() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyLives) ?? 5;
  }

  Future<void> decrementLives() async {
    final prefs = await SharedPreferences.getInstance();
    final lives = prefs.getInt(keyLives) ?? 5;
    final next = lives > 0 ? lives - 1 : 0;
    await prefs.setInt(keyLives, next);
  }

  Future<void> resetLives() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLives, 5);
  }

  Future<void> resetLivesIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = AppDateUtils.todayIsoDate();
    final lastResetDate = prefs.getString(keyLastLivesResetDate);

    if (lastResetDate == today) {
      return;
    }

    await prefs.setInt(keyLives, 5);
    await prefs.setString(keyLastLivesResetDate, today);
  }

  Future<String?> getSelectedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keySelectedLevel);
  }

  Future<void> setSelectedLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySelectedLevel, level);
  }

  Future<void> savePlacementResult({required String level, required int score}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPlacementLevel, level);
    await prefs.setInt(keyPlacementScore, score);
    await prefs.setBool(keyPlacementCompleted, true);
    await prefs.setString(keySelectedLevel, level);
  }

  Future<bool> hasCompletedPlacementQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyPlacementCompleted) ?? false;
  }

  Future<String?> getPlacementLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPlacementLevel);
  }

  Future<int> getPlacementScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyPlacementScore) ?? 0;
  }

  Future<String?> getLastActiveDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastActiveDate);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserProfileJson, jsonEncode(profile.toJson()));
    await prefs.setBool(keyOnboardingCompleted, true);
    await prefs.setString(keySelectedLevel, profile.experienceLevel);
  }

  Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyUserProfileJson);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return UserProfile.fromJson(decoded);
  }

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyOnboardingCompleted) ?? false;
  }

  Future<int> getTodayXP() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetTodayXpIfNeeded(prefs);
    return prefs.getInt(keyTodayXP) ?? 0;
  }

  Future<int> getXPEarnedToday() async {
    return getTodayXP();
  }

  Future<void> addXPToday(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetTodayXpIfNeeded(prefs);
    final today = prefs.getInt(keyTodayXP) ?? 0;
    await prefs.setInt(keyTodayXP, today + amount);
  }

  Future<void> _resetTodayXpIfNeeded(SharedPreferences prefs) async {
    final today = AppDateUtils.todayIsoDate();
    final storedDate = prefs.getString(keyTodayXPDate);
    if (storedDate == today) {
      return;
    }
    await prefs.setInt(keyTodayXP, 0);
    await prefs.setString(keyTodayXPDate, today);
  }

  Future<int?> getLastFunFactIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyLastFunFactIndex);
  }

  Future<void> setLastFunFactIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLastFunFactIndex, index);
  }

  Future<void> unlockAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(keyUnlockedAchievements) ?? <String>[];
    if (!current.contains(achievementId)) {
      current.add(achievementId);
      await prefs.setStringList(keyUnlockedAchievements, current);
    }
  }

  Future<List<String>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(keyUnlockedAchievements) ?? <String>[];
  }

  Future<void> addDailyActivity(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayActivityKey();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + xp);
  }

  Future<Map<String, int>> getYearlyActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final now = AppDateUtils.todayLocalDate();
    final output = <String, int>{};

    for (var i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final key = 'activity_${date.toIso8601String().split('T').first}';
      final value = prefs.getInt(key);
      if (value != null) {
        output[key.replaceFirst('activity_', '')] = value;
      }
    }

    return output;
  }

  Future<void> markChallengeComplete(String date, int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_challengeDayKey(date), true);
    final completed = prefs.getInt(keyChallengesCompleted) ?? 0;
    await prefs.setInt(keyChallengesCompleted, completed + 1);
    await addXP(xp);
  }

  Future<bool> isChallengeCompleteToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_challengeDayKey(AppDateUtils.todayIsoDate())) ?? false;
  }

  Future<int> getChallengesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyChallengesCompleted) ?? 0;
  }

  Future<String> getLastMascotMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastMascotMessage) ?? '';
  }

  Future<void> saveLastMascotMessage(String msg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastMascotMessage, msg);
  }

  Future<DateTime> getOrCreateAppLaunchDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyAppLaunchDate);
    if (raw != null) {
      return DateTime.parse(raw);
    }

    final now = DateTime.now();
    await prefs.setString(keyAppLaunchDate, now.toIso8601String());
    return now;
  }

  Future<void> incrementFixTheBugCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyFixTheBugCompleted) ?? 0;
    await prefs.setInt(keyFixTheBugCompleted, current + 1);
  }

  Future<int> getFixTheBugCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyFixTheBugCompleted) ?? 0;
  }
}
