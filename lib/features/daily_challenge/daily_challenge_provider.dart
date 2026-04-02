import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/data/models/question_model.dart';

class DailyChallengeModel {
  const DailyChallengeModel({
    required this.id,
    required this.day,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.xpReward,
    required this.bonusXP,
    required this.questionData,
    required this.funFact,
  });

  final String id;
  final int day;
  final String title;
  final String description;
  final String type;
  final String difficulty;
  final int xpReward;
  final int bonusXP;
  final QuestionModel questionData;
  final String funFact;

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      id: json['id'] as String,
      day: (json['day'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      difficulty: json['difficulty'] as String,
      xpReward: (json['xpReward'] as num).toInt(),
      bonusXP: (json['bonusXP'] as num).toInt(),
      questionData: QuestionModel.fromJson(Map<String, dynamic>.from(json['questionData'] as Map)),
      funFact: json['funFact'] as String,
    );
  }
}

class DailyChallengeState {
  const DailyChallengeState({
    this.isLoading = true,
    this.todaysChallenge,
    this.isCompleted = false,
    this.timeUntilNext = Duration.zero,
    this.completedChallengeIds = const [],
    this.hasStarted = false,
    this.elapsedSeconds = 0,
    this.hasAnswered = false,
    this.isCorrect,
    this.explanation,
    this.selectedAnswer,
    this.earnedXP = 0,
    this.bonusAwarded = false,
  });

  final bool isLoading;
  final DailyChallengeModel? todaysChallenge;
  final bool isCompleted;
  final Duration timeUntilNext;
  final List<String> completedChallengeIds;
  final bool hasStarted;
  final int elapsedSeconds;
  final bool hasAnswered;
  final bool? isCorrect;
  final String? explanation;
  final String? selectedAnswer;
  final int earnedXP;
  final bool bonusAwarded;

  DailyChallengeState copyWith({
    bool? isLoading,
    DailyChallengeModel? todaysChallenge,
    bool? isCompleted,
    Duration? timeUntilNext,
    List<String>? completedChallengeIds,
    bool? hasStarted,
    int? elapsedSeconds,
    bool? hasAnswered,
    bool? isCorrect,
    String? explanation,
    String? selectedAnswer,
    int? earnedXP,
    bool? bonusAwarded,
    bool clearAnswer = false,
  }) {
    return DailyChallengeState(
      isLoading: isLoading ?? this.isLoading,
      todaysChallenge: todaysChallenge ?? this.todaysChallenge,
      isCompleted: isCompleted ?? this.isCompleted,
      timeUntilNext: timeUntilNext ?? this.timeUntilNext,
      completedChallengeIds: completedChallengeIds ?? this.completedChallengeIds,
      hasStarted: hasStarted ?? this.hasStarted,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      isCorrect: clearAnswer ? null : (isCorrect ?? this.isCorrect),
      explanation: clearAnswer ? null : (explanation ?? this.explanation),
      selectedAnswer: clearAnswer ? null : (selectedAnswer ?? this.selectedAnswer),
      earnedXP: earnedXP ?? this.earnedXP,
      bonusAwarded: bonusAwarded ?? this.bonusAwarded,
    );
  }
}

class DailyChallengeNotifier extends StateNotifier<DailyChallengeState> {
  DailyChallengeNotifier(this._ref) : super(const DailyChallengeState());

  final Ref _ref;

  Duration _untilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  Future<List<DailyChallengeModel>> _loadAllChallenges() async {
    final raw = await rootBundle.loadString('assets/challenges/daily_challenges.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final challenges = decoded['challenges'] as List<dynamic>;
    return challenges
        .map((item) => DailyChallengeModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final prefs = _ref.read(preferencesServiceProvider);
    final launchDate = await prefs.getOrCreateAppLaunchDate();
    final all = await _loadAllChallenges();
    final dayIndex = DateTime.now().difference(DateTime(launchDate.year, launchDate.month, launchDate.day)).inDays % all.length;
    final todayChallenge = all[dayIndex];
    final completed = await prefs.isChallengeCompleteToday();

    state = state.copyWith(
      isLoading: false,
      todaysChallenge: todayChallenge,
      isCompleted: completed,
      timeUntilNext: _untilMidnight(),
      clearAnswer: true,
    );
  }

  void startChallenge() {
    if (state.isCompleted) return;
    state = state.copyWith(hasStarted: true, elapsedSeconds: 0, clearAnswer: true);
  }

  void tickChallengeClock() {
    if (!state.hasStarted || state.hasAnswered) return;
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1, timeUntilNext: _untilMidnight());
  }

  Future<void> submitAnswer(String answer) async {
    final challenge = state.todaysChallenge;
    if (challenge == null || state.isCompleted || state.hasAnswered) return;

    final expected = challenge.questionData.correctAnswer.toString().trim().toLowerCase();
    final provided = answer.trim().toLowerCase();
    final correct = expected == provided;
    state = state.copyWith(
      hasAnswered: true,
      isCorrect: correct,
      selectedAnswer: answer,
      explanation: challenge.questionData.explanation,
    );

    if (!correct) {
      return;
    }

    final prefs = _ref.read(preferencesServiceProvider);
    final bonus = state.elapsedSeconds <= 30;
    final earned = challenge.xpReward + (bonus ? challenge.bonusXP : 0);

    await prefs.markChallengeComplete(
      DateTime.now().toIso8601String().split('T').first,
      challenge.xpReward,
    );

    if (bonus) {
      await prefs.addXP(challenge.bonusXP);
    }

    await prefs.unlockAchievement('challenger');

    state = state.copyWith(
      isCompleted: true,
      earnedXP: earned,
      bonusAwarded: bonus,
      timeUntilNext: _untilMidnight(),
    );
  }
}

final dailyChallengeProvider = StateNotifierProvider<DailyChallengeNotifier, DailyChallengeState>((ref) {
  return DailyChallengeNotifier(ref);
});