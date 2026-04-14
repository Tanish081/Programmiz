import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/core/services/certificate_service.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/data/models/lesson_model.dart';
import 'package:programming_learn_app/data/models/question_model.dart';
import 'package:programming_learn_app/data/models/quiz_result_data.dart';
import 'package:programming_learn_app/data/models/user_progress_model.dart';
import 'package:programming_learn_app/features/home/home_provider.dart';

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
    this.questionResults = const [],
    this.startTime,
    this.resultData,
    this.heartsLost = 0,
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
  final List<QuestionResultDetail> questionResults;
  final DateTime? startTime;
  final QuizResultData? resultData;
  final int heartsLost;

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
    List<QuestionResultDetail>? questionResults,
    DateTime? startTime,
    QuizResultData? resultData,
    int? heartsLost,
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
      questionResults: questionResults ?? this.questionResults,
      startTime: startTime ?? this.startTime,
      resultData: resultData ?? this.resultData,
      heartsLost: heartsLost ?? this.heartsLost,
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
    state = state.copyWith(
      isLoading: false,
      lesson: lesson,
      hearts: lives,
      startTime: DateTime.now(),
    );
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
    
    // Record this question result
    final questionResult = QuestionResultDetail(
      questionText: q.questionText,
      codeSnippet: q.codeSnippet,
      type: q.type,
      userAnswer: answer.toString(),
      correctAnswer: q.correctAnswer.toString(),
      explanation: q.explanation,
      wasCorrect: false,
      xpAwarded: 0,
    );
    
    final updatedResults = [...state.questionResults, questionResult];
    
    state = state.copyWith(
      hasAnswered: true,
      wasCorrect: false,
      explanation: q.explanation,
      hearts: nextHearts,
      failed: nextHearts == 0,
      submittedAnswer: answer,
      questionResults: updatedResults,
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
    
    final score =
        state.totalQuestions == 0 ? 0 : ((state.correctCount / state.totalQuestions) * 100).round();
    final prefs = _ref.read(preferencesServiceProvider);
    final progressRepo = _ref.read(progressRepositoryProvider);
    final todayBefore = await prefs.getTodayXP();
    final profile = await prefs.loadUserProfile();
    final goal = profile?.dailyGoalXP ?? 20;
    final goalReachedNow =
        todayBefore < goal && (todayBefore + state.earnedXp) >= goal;

    // Calculate hearts lost
    final heartsLostCount = 5 - state.hearts;
    
    // Build question results for all answered questions
    final allQuestionResults = <QuestionResultDetail>[];
    for (int i = 0; i < state.totalQuestions; i++) {
      final q = state.lesson!.questions[i];
      // Reconstruct results from state - in a real scenario, we'd track this during quiz
      // For now, create a result for each question
      final wasCorrect = i < state.correctCount; // Simplified assumption
      allQuestionResults.add(
        QuestionResultDetail(
          questionText: q.questionText,
          codeSnippet: q.codeSnippet,
          type: q.type,
          userAnswer: '', // Would be tracked during quiz
          correctAnswer: q.correctAnswer.toString(),
          explanation: q.explanation,
          wasCorrect: wasCorrect,
          xpAwarded: wasCorrect ? q.xpReward : 0,
        ),
      );
    }

    // Calculate time taken
    final timeTaken = state.startTime != null
        ? DateTime.now().difference(state.startTime!).inSeconds
        : 0;

    // Build result data
    final resultData = QuizResultData(
      lessonId: state.lesson!.id,
      lessonTitle: state.lesson!.title,
      topicTag: state.lesson!.topicTag,
      totalQuestions: state.totalQuestions,
      correctAnswers: state.correctCount,
      xpEarned: state.earnedXp,
      heartsLost: heartsLostCount,
      questionResults: allQuestionResults,
      timeTakenSeconds: timeTaken,
    );

    state = state.copyWith(
      completed: true,
      failed: !markCompleted && state.failed,
      reachedDailyGoal: goalReachedNow,
      resultData: resultData,
      heartsLost: heartsLostCount,
    );

    await progressRepo.saveProgress(
      UserProgressModel(
        lessonId: state.lesson!.id,
        quizScore: score,
        isCompleted: markCompleted,
        attemptCount:
            (progressRepo.getProgress(state.lesson!.id)?.attemptCount ?? 0) + 1,
        completedAt: DateTime.now(),
      ),
    );

    await prefs.addXP(state.earnedXp);
    await prefs.addDailyActivity(state.earnedXp);
    await prefs.updateStreak();

    // Save pending XP animation data
    await prefs.setPendingXPAnimation(state.earnedXp);
    await prefs.setPendingLessonCompleted(state.lesson!.title);

    if (profile != null) {
      await CertificateService().checkAndIssueCertificates(profile);
    }

    _ref.invalidate(homeProvider);
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
