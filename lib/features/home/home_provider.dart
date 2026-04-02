import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/data/models/lesson_model.dart';
import 'package:programming_learn_app/data/models/user_profile_model.dart';
import 'package:programming_learn_app/data/models/user_progress_model.dart';

class HomeState {
  const HomeState({
    this.isLoading = true,
    this.lessons = const [],
    this.progress = const {},
    this.selectedLevel = 'absolute_beginner',
    this.totalXP = 0,
    this.streak = 0,
    this.lives = 5,
    this.userName = 'Learner',
    this.dailyGoalXP = 20,
    this.todayXP = 0,
    this.profile,
  });

  final bool isLoading;
  final List<LessonModel> lessons;
  final Map<String, UserProgressModel> progress;
  final String selectedLevel;
  final int totalXP;
  final int streak;
  final int lives;
  final String userName;
  final int dailyGoalXP;
  final int todayXP;
  final UserProfile? profile;

  HomeState copyWith({
    bool? isLoading,
    List<LessonModel>? lessons,
    Map<String, UserProgressModel>? progress,
    String? selectedLevel,
    int? totalXP,
    int? streak,
    int? lives,
    String? userName,
    int? dailyGoalXP,
    int? todayXP,
    UserProfile? profile,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      lessons: lessons ?? this.lessons,
      progress: progress ?? this.progress,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      totalXP: totalXP ?? this.totalXP,
      streak: streak ?? this.streak,
      lives: lives ?? this.lives,
      userName: userName ?? this.userName,
      dailyGoalXP: dailyGoalXP ?? this.dailyGoalXP,
      todayXP: todayXP ?? this.todayXP,
      profile: profile ?? this.profile,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this._ref) : super(const HomeState());

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);

    final prefs = _ref.read(preferencesServiceProvider);
    await prefs.resetLivesIfNewDay();

    final profile = await prefs.loadUserProfile();
    final level = profile?.experienceLevel ?? await prefs.getSelectedLevel() ?? 'absolute_beginner';
    final lessonRepo = _ref.read(lessonRepositoryProvider);
    final progressRepo = _ref.read(progressRepositoryProvider);

    final lessons = await lessonRepo.getLessonsByLevel(level);
    final progressMap = <String, UserProgressModel>{
      for (final lesson in lessons)
        if (progressRepo.getProgress(lesson.id) != null) lesson.id: progressRepo.getProgress(lesson.id)!,
    };

    state = state.copyWith(
      isLoading: false,
      selectedLevel: level,
      lessons: lessons,
      progress: progressMap,
      totalXP: await prefs.getXP(),
      streak: await prefs.getStreak(),
      lives: await prefs.getLives(),
      userName: profile?.name ?? 'Learner',
      dailyGoalXP: profile?.dailyGoalXP ?? 20,
      todayXP: await prefs.getTodayXP(),
      profile: profile,
    );
  }

  bool isLessonUnlocked(int index) {
    if (index == 0) return true;
    final previous = state.lessons[index - 1];
    return _ref.read(progressRepositoryProvider).isLessonCompleted(previous.id);
  }

  bool isLessonCompleted(String lessonId) {
    return _ref.read(progressRepositoryProvider).isLessonCompleted(lessonId);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});
