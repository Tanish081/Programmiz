import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/data/models/lesson_model.dart';
import 'package:programming_learn_app/data/models/user_profile_model.dart';

class LevelProgressSummary {
  const LevelProgressSummary({required this.completed, required this.total});

  final int completed;
  final int total;
}

class RecentActivityEntry {
  const RecentActivityEntry({
    required this.lessonId,
    required this.lessonTitle,
    required this.topicTag,
    required this.score,
    required this.xpEarned,
    required this.isCompleted,
    required this.completedAt,
    required this.attemptCount,
  });

  final String lessonId;
  final String lessonTitle;
  final String topicTag;
  final int score;
  final int xpEarned;
  final bool isCompleted;
  final DateTime completedAt;
  final int attemptCount;
}

class ProgressState {
  const ProgressState({
    this.isLoading = true,
    this.name = 'Learner',
    this.avatarId,
    this.experienceLevel = 'absolute_beginner',
    this.joinedAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.totalXP = 0,
    this.xpEarnedToday = 0,
    this.dailyGoalXP = 20,
    this.levelName = 'Novice',
    this.currentLevelFloor = 0,
    this.nextLevelFloor = 201,
    this.currentLevelNumber = 1,
    this.nextLevelNumber = 2,
    this.xpToNextLevel = 201,
    this.lessonsCompleted = 0,
    this.totalQuizzesTaken = 0,
    this.averageScore = 0,
    this.streakDays = const [],
    this.perLevelProgress = const {},
    this.recentActivity = const [],
    this.profile,
  });

  final bool isLoading;
  final String name;
  final String? avatarId;
  final String experienceLevel;
  final DateTime? joinedAt;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final int totalXP;
  final int xpEarnedToday;
  final int dailyGoalXP;
  final String levelName;
  final int currentLevelFloor;
  final int nextLevelFloor;
  final int currentLevelNumber;
  final int nextLevelNumber;
  final int xpToNextLevel;
  final int lessonsCompleted;
  final int totalQuizzesTaken;
  final int averageScore;
  final List<bool> streakDays;
  final Map<String, LevelProgressSummary> perLevelProgress;
  final List<RecentActivityEntry> recentActivity;
  final UserProfile? profile;

  ProgressState copyWith({
    bool? isLoading,
    String? name,
    String? avatarId,
    String? experienceLevel,
    DateTime? joinedAt,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    int? totalXP,
    int? xpEarnedToday,
    int? dailyGoalXP,
    String? levelName,
    int? currentLevelFloor,
    int? nextLevelFloor,
    int? currentLevelNumber,
    int? nextLevelNumber,
    int? xpToNextLevel,
    int? lessonsCompleted,
    int? totalQuizzesTaken,
    int? averageScore,
    List<bool>? streakDays,
    Map<String, LevelProgressSummary>? perLevelProgress,
    List<RecentActivityEntry>? recentActivity,
    UserProfile? profile,
  }) {
    return ProgressState(
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      avatarId: avatarId ?? this.avatarId,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      joinedAt: joinedAt ?? this.joinedAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalXP: totalXP ?? this.totalXP,
      xpEarnedToday: xpEarnedToday ?? this.xpEarnedToday,
      dailyGoalXP: dailyGoalXP ?? this.dailyGoalXP,
      levelName: levelName ?? this.levelName,
      currentLevelFloor: currentLevelFloor ?? this.currentLevelFloor,
      nextLevelFloor: nextLevelFloor ?? this.nextLevelFloor,
      currentLevelNumber: currentLevelNumber ?? this.currentLevelNumber,
      nextLevelNumber: nextLevelNumber ?? this.nextLevelNumber,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      averageScore: averageScore ?? this.averageScore,
      streakDays: streakDays ?? this.streakDays,
      perLevelProgress: perLevelProgress ?? this.perLevelProgress,
      recentActivity: recentActivity ?? this.recentActivity,
      profile: profile ?? this.profile,
    );
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier(this._ref) : super(const ProgressState());

  final Ref _ref;

  ({String levelName, int currentFloor, int nextFloor, int levelNumber, int nextLevelNumber}) _levelInfo(int xp) {
    if (xp < 201) {
      return (levelName: 'Novice', currentFloor: 0, nextFloor: 201, levelNumber: 1, nextLevelNumber: 2);
    }
    if (xp < 501) {
      return (levelName: 'Coder', currentFloor: 201, nextFloor: 501, levelNumber: 2, nextLevelNumber: 3);
    }
    if (xp < 1000) {
      return (levelName: 'Pythonista', currentFloor: 501, nextFloor: 1000, levelNumber: 3, nextLevelNumber: 4);
    }
    return (levelName: 'Master', currentFloor: 1000, nextFloor: 1500, levelNumber: 4, nextLevelNumber: 5);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);

    final lessonRepo = _ref.read(lessonRepositoryProvider);
    final progressRepo = _ref.read(progressRepositoryProvider);
    final prefs = _ref.read(preferencesServiceProvider);

    await prefs.resetLivesIfNewDay();

    final profile = await prefs.loadUserProfile();
    final totalXP = await prefs.getXP();
    final todayXP = await prefs.getTodayXP();
    final currentStreak = await prefs.getStreak();
    var longestStreak = await prefs.getLongestStreak();
    final lastActiveRaw = await prefs.getLastActiveDate();
    final lastActiveDate = lastActiveRaw == null ? null : DateTime.tryParse(lastActiveRaw);
    final dailyGoalXP = profile?.dailyGoalXP ?? 20;

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
      await prefs.setLongestStreak(longestStreak);
    }

    final allLessons = await lessonRepo.getAllLessons();
    final allProgress = progressRepo.getAllProgress();
      allProgress.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final levelBuckets = <String, List<LessonModel>>{};
    for (final lesson in allLessons) {
      levelBuckets.putIfAbsent(lesson.level, () => <LessonModel>[]).add(lesson);
    }

    final perLevelProgress = <String, LevelProgressSummary>{};
    for (final entry in levelBuckets.entries) {
      final completed = entry.value.where((lesson) => progressRepo.isLessonCompleted(lesson.id)).length;
      perLevelProgress[entry.key] = LevelProgressSummary(completed: completed, total: entry.value.length);
    }

    final completedLessons = allProgress.where((progress) => progress.isCompleted).length;
    final totalQuizzesTaken = allProgress.length;
    final averageScore = totalQuizzesTaken == 0
        ? 0
        : (allProgress.map((progress) => progress.quizScore).reduce((a, b) => a + b) / totalQuizzesTaken).round();

    final lessonById = {for (final lesson in allLessons) lesson.id: lesson};
    final recentActivity = allProgress.take(5).map((progress) {
      final lesson = lessonById[progress.lessonId];
      return RecentActivityEntry(
        lessonId: progress.lessonId,
        lessonTitle: lesson?.title ?? progress.lessonId,
        topicTag: lesson?.topicTag ?? 'Python',
        score: progress.quizScore,
        xpEarned: progress.isCompleted ? (lesson?.xpReward ?? 0) : 0,
        isCompleted: progress.isCompleted,
        completedAt: progress.completedAt,
        attemptCount: progress.attemptCount,
      );
    }).toList();

    final info = _levelInfo(totalXP);
    final xpToNextLevel = info.nextFloor - totalXP;
    final streakDays = List<bool>.generate(
      7,
      (index) => index >= (7 - currentStreak.clamp(0, 7)),
    );

    state = state.copyWith(
      isLoading: false,
      name: profile?.name ?? 'Learner',
      avatarId: profile?.avatarId,
      experienceLevel: profile?.experienceLevel ?? 'absolute_beginner',
      joinedAt: profile?.createdAt,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActiveDate: lastActiveDate,
      totalXP: totalXP,
      xpEarnedToday: todayXP,
      dailyGoalXP: dailyGoalXP,
      levelName: info.levelName,
      currentLevelFloor: info.currentFloor,
      nextLevelFloor: info.nextFloor,
      currentLevelNumber: info.levelNumber,
      nextLevelNumber: info.nextLevelNumber,
      xpToNextLevel: xpToNextLevel,
      lessonsCompleted: completedLessons,
      totalQuizzesTaken: totalQuizzesTaken,
      averageScore: averageScore,
      streakDays: streakDays,
      perLevelProgress: perLevelProgress,
      recentActivity: recentActivity,
      profile: profile,
    );
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  return ProgressNotifier(ref);
});
