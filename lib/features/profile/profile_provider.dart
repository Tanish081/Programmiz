import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/data/models/user_profile_model.dart';

class ProfileAchievement {
  const ProfileAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
}

class ProfileState {
  const ProfileState({
    this.isLoading = true,
    this.profile,
    this.totalXP = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lessonsCompleted = 0,
    this.totalQuizzesTaken = 0,
    this.averageScore = 0,
    this.challengesCompleted = 0,
    this.fixTheBugCompleted = 0,
    this.yearlyActivity = const {},
    this.achievements = const [],
  });

  final bool isLoading;
  final UserProfile? profile;
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final int lessonsCompleted;
  final int totalQuizzesTaken;
  final int averageScore;
  final int challengesCompleted;
  final int fixTheBugCompleted;
  final Map<String, int> yearlyActivity;
  final List<ProfileAchievement> achievements;

  ProfileState copyWith({
    bool? isLoading,
    UserProfile? profile,
    int? totalXP,
    int? currentStreak,
    int? longestStreak,
    int? lessonsCompleted,
    int? totalQuizzesTaken,
    int? averageScore,
    int? challengesCompleted,
    int? fixTheBugCompleted,
    Map<String, int>? yearlyActivity,
    List<ProfileAchievement>? achievements,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      totalXP: totalXP ?? this.totalXP,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      averageScore: averageScore ?? this.averageScore,
      challengesCompleted: challengesCompleted ?? this.challengesCompleted,
      fixTheBugCompleted: fixTheBugCompleted ?? this.fixTheBugCompleted,
      yearlyActivity: yearlyActivity ?? this.yearlyActivity,
      achievements: achievements ?? this.achievements,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._ref) : super(const ProfileState());

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final prefs = _ref.read(preferencesServiceProvider);
    final progressRepo = _ref.read(progressRepositoryProvider);

    final profile = await prefs.loadUserProfile();
    final totalXP = await prefs.getXP();
    final currentStreak = await prefs.getStreak();
    final longestStreak = await prefs.getLongestStreak();
    final yearlyActivity = await prefs.getYearlyActivity();
    final challenges = await prefs.getChallengesCompleted();
    final fixCount = await prefs.getFixTheBugCompleted();

    final progress = progressRepo.getAllProgress();
    final completedLessons = progress.where((entry) => entry.isCompleted).length;
    final totalQuizzesTaken = progress.length;
    final averageScore = totalQuizzesTaken == 0
        ? 0
        : (progress.map((entry) => entry.quizScore).reduce((a, b) => a + b) / totalQuizzesTaken).round();

    final unlocked = await prefs.getUnlockedAchievements();

    Future<bool> isUnlocked(String id, bool qualifies) async {
      if (unlocked.contains(id)) {
        return true;
      }
      if (qualifies) {
        await prefs.unlockAchievement(id);
        return true;
      }
      return false;
    }

    final achFirstLesson = await isUnlocked('first_lesson', completedLessons >= 1);
    final achStreak = await isUnlocked('streak_7', currentStreak >= 7);
    final achPerfect = await isUnlocked('perfect_quiz', totalQuizzesTaken > 0 && averageScore == 100);
    final achChallenger = await isUnlocked('challenger', challenges >= 1);
    final achBugHunter = await isUnlocked('bug_hunter', fixCount >= 10);

    final achievements = <ProfileAchievement>[
      ProfileAchievement(
        id: 'first_lesson',
        title: 'First Lesson',
        description: 'Complete your first lesson.',
        icon: '🎓',
        unlocked: achFirstLesson,
      ),
      ProfileAchievement(
        id: 'streak_7',
        title: 'Streak Master',
        description: 'Keep a 7-day streak.',
        icon: '🔥',
        unlocked: achStreak,
      ),
      ProfileAchievement(
        id: 'perfect_quiz',
        title: 'Perfect Quiz',
        description: 'Reach a 100 average quiz score.',
        icon: '💯',
        unlocked: achPerfect,
      ),
      ProfileAchievement(
        id: 'challenger',
        title: 'Daily Challenger',
        description: 'Complete your first daily challenge.',
        icon: '🎯',
        unlocked: achChallenger,
      ),
      ProfileAchievement(
        id: 'bug_hunter',
        title: 'Bug Hunter',
        description: 'Solve 10 fix-the-bug questions.',
        icon: '🐞',
        unlocked: achBugHunter,
      ),
    ];

    state = state.copyWith(
      isLoading: false,
      profile: profile,
      totalXP: totalXP,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lessonsCompleted: completedLessons,
      totalQuizzesTaken: totalQuizzesTaken,
      averageScore: averageScore,
      challengesCompleted: challenges,
      fixTheBugCompleted: fixCount,
      yearlyActivity: yearlyActivity,
      achievements: achievements,
    );
  }

  Future<void> updateProfile({
    required String name,
    required String avatarId,
    required int dailyGoalXP,
  }) async {
    final prefs = _ref.read(preferencesServiceProvider);
    final existing = state.profile ??
        UserProfile(
          name: 'Learner',
          avatarId: 'avatar_6',
          age: 12,
          experienceLevel: 'absolute_beginner',
          dailyGoalXP: 20,
          preferredTime: 'afternoon',
          isGuest: false,
          createdAt: DateTime.now(),
        );

    final updated = UserProfile(
      name: name,
      avatarId: avatarId,
      age: existing.age,
      experienceLevel: existing.experienceLevel,
      dailyGoalXP: dailyGoalXP,
      preferredTime: existing.preferredTime,
      isGuest: existing.isGuest,
      createdAt: existing.createdAt,
    );

    await prefs.saveUserProfile(updated);
    state = state.copyWith(profile: updated);
    await load();
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});