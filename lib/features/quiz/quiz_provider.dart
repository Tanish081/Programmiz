import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/data/models/lesson_model.dart';
import 'package:programming_learn_app/data/models/question_model.dart';
import 'package:programming_learn_app/data/models/user_progress_model.dart';
import 'package:programming_learn_app/features/home/home_provider.dart';
import 'package:programming_learn_app/features/progress/progress_provider.dart';

class QuizState {
  const QuizState({
    this.isLoading = true,
    this.lesson,
    this.currentIndex = 0,
    this.hearts = 5,
    this.earnedXp = 0,
    this.correctCount = 0,
    this.hasAnswered = false,
    this.wasCorrect,
    this.explanation,
    this.completed = false,
    this.failed = false,
    this.reachedDailyGoal = false,
    this.freeRetryUsed = false,
    this.submittedAnswer,
  });

  final bool isLoading;
  final LessonModel? lesson;
  final int currentIndex;
  final int hearts;
  final int earnedXp;
  final int correctCount;
  final bool hasAnswered;
  final bool? wasCorrect;
  final String? explanation;
  final bool completed;
  final bool failed;
  final bool reachedDailyGoal;
  final bool freeRetryUsed;
  final dynamic submittedAnswer;

  QuizState copyWith({
    bool? isLoading,
    LessonModel? lesson,
    int? currentIndex,
    int? hearts,
    int? earnedXp,
    int? correctCount,
    bool? hasAnswered,
    bool? wasCorrect,
    String? explanation,
    bool? completed,
    bool? failed,
    bool? reachedDailyGoal,
    bool? freeRetryUsed,
    dynamic submittedAnswer,
    bool clearAnswer = false,
  }) {
    return QuizState(
      isLoading: isLoading ?? this.isLoading,
      lesson: lesson ?? this.lesson,
      currentIndex: currentIndex ?? this.currentIndex,
      hearts: hearts ?? this.hearts,
      earnedXp: earnedXp ?? this.earnedXp,
      correctCount: correctCount ?? this.correctCount,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      wasCorrect: clearAnswer ? null : (wasCorrect ?? this.wasCorrect),
      explanation: clearAnswer ? null : (explanation ?? this.explanation),
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
      reachedDailyGoal: reachedDailyGoal ?? this.reachedDailyGoal,
      freeRetryUsed: freeRetryUsed ?? this.freeRetryUsed,
      submittedAnswer: clearAnswer ? null : (submittedAnswer ?? this.submittedAnswer),
    );
  }

  QuestionModel? get currentQuestion {
    final list = lesson?.questions;
    if (list == null || list.isEmpty || currentIndex >= list.length) return null;
    return list[currentIndex];
  }

  int get totalQuestions => lesson?.questions.length ?? 0;
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this._ref) : super(const QuizState());

  final Ref _ref;

  Future<void> load(String lessonId) async {
    state = const QuizState(isLoading: true);
    final lesson = await _ref.read(lessonRepositoryProvider).getLessonById(lessonId);
    final lives = await _ref.read(preferencesServiceProvider).getLives();
    state = state.copyWith(isLoading: false, lesson: lesson, hearts: lives);
  }

  Future<void> answer(dynamic answer) async {
    if (state.hasAnswered || state.currentQuestion == null || state.completed) return;

    final q = state.currentQuestion!;
    final isCorrect = _isCorrect(q.correctAnswer, answer);

    if (isCorrect) {
      state = state.copyWith(
        hasAnswered: true,
        wasCorrect: true,
        explanation: q.explanation,
        earnedXp: state.earnedXp + q.xpReward,
        correctCount: state.correctCount + 1,
        submittedAnswer: answer,
      );
      if (q.type == 'fix_the_bug') {
        unawaited(_ref.read(preferencesServiceProvider).incrementFixTheBugCompleted());
      }
      return;
    }

    if (!state.freeRetryUsed) {
      final hint = q.type == 'fix_the_bug' ? (q.bugDescription ?? q.explanation) : q.explanation;
      state = state.copyWith(
        freeRetryUsed: true,
        hasAnswered: false,
        wasCorrect: false,
        explanation: 'Hint: $hint',
        submittedAnswer: answer,
      );
      return;
    }

    final nextHearts = state.hearts > 0 ? state.hearts - 1 : 0;
    state = state.copyWith(
      hasAnswered: true,
      wasCorrect: false,
      explanation: q.explanation,
      hearts: nextHearts,
      failed: nextHearts == 0,
      submittedAnswer: answer,
    );
    unawaited(_ref.read(preferencesServiceProvider).decrementLives());

    if (nextHearts == 0) {
      await _finish(markCompleted: false);
    }
  }

  Future<void> next() async {
    if (state.lesson == null) return;

    if (state.failed) {
      await _finish(markCompleted: false);
      return;
    }

    final lastIndex = state.totalQuestions - 1;
    if (state.currentIndex >= lastIndex) {
      state = state.copyWith(earnedXp: state.earnedXp + state.lesson!.xpReward);
      await _finish(markCompleted: true);
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      hasAnswered: false,
      freeRetryUsed: false,
      clearAnswer: true,
    );
  }

  Future<void> _finish({required bool markCompleted}) async {
    if (state.lesson == null || state.completed) return;
    final score = state.totalQuestions == 0 ? 0 : ((state.correctCount / state.totalQuestions) * 100).round();
    final prefs = _ref.read(preferencesServiceProvider);
    final progressRepo = _ref.read(progressRepositoryProvider);
    final todayBefore = await prefs.getTodayXP();
    final profile = await prefs.loadUserProfile();
    final goal = profile?.dailyGoalXP ?? 20;
    final goalReachedNow = todayBefore < goal && (todayBefore + state.earnedXp) >= goal;

    state = state.copyWith(completed: true, failed: !markCompleted && state.failed, reachedDailyGoal: goalReachedNow);

    await progressRepo.saveProgress(
          UserProgressModel(
            lessonId: state.lesson!.id,
            quizScore: score,
            isCompleted: markCompleted,
            attemptCount: (progressRepo.getProgress(state.lesson!.id)?.attemptCount ?? 0) + 1,
            completedAt: DateTime.now(),
          ),
        );

    await prefs.addXP(state.earnedXp);
    await prefs.updateStreak();

    _ref.invalidate(homeProvider);
    _ref.invalidate(progressProvider);
  }

  bool _isCorrect(dynamic expected, dynamic answer) {
    if (expected is List && answer is List) {
      if (expected.length != answer.length) return false;
      for (var i = 0; i < expected.length; i++) {
        if (expected[i].toString().trim() != answer[i].toString().trim()) return false;
      }
      return true;
    }
    return expected.toString().trim() == answer.toString().trim();
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref);
});
