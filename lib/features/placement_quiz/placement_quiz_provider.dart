import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';

class PlacementQuestion {
  const PlacementQuestion({required this.question, required this.options});

  final String question;
  final List<PlacementOption> options;
}

class PlacementOption {
  const PlacementOption({required this.label, required this.score});

  final String label;
  final int score;
}

class PlacementQuizState {
  const PlacementQuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.totalScore = 0,
    this.selectedOptionIndex,
    this.completed = false,
    this.recommendedLevel = 'absolute_beginner',
    this.isSaving = false,
  });

  final List<PlacementQuestion> questions;
  final int currentIndex;
  final int totalScore;
  final int? selectedOptionIndex;
  final bool completed;
  final String recommendedLevel;
  final bool isSaving;

  PlacementQuestion get currentQuestion => questions[currentIndex];

  bool get canContinue => selectedOptionIndex != null;

  double get progress => questions.isEmpty ? 0 : (currentIndex + (completed ? 1 : 0)) / questions.length;

  PlacementQuizState copyWith({
    List<PlacementQuestion>? questions,
    int? currentIndex,
    int? totalScore,
    int? selectedOptionIndex,
    bool clearSelectedOption = false,
    bool? completed,
    String? recommendedLevel,
    bool? isSaving,
  }) {
    return PlacementQuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      totalScore: totalScore ?? this.totalScore,
      selectedOptionIndex: clearSelectedOption ? null : (selectedOptionIndex ?? this.selectedOptionIndex),
      completed: completed ?? this.completed,
      recommendedLevel: recommendedLevel ?? this.recommendedLevel,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class PlacementQuizNotifier extends StateNotifier<PlacementQuizState> {
  PlacementQuizNotifier(this._ref)
      : super(
          PlacementQuizState(
            questions: const [
              PlacementQuestion(
                question: 'Which best describes your coding journey?',
                options: [
                  PlacementOption(label: 'I am completely new to coding', score: 0),
                  PlacementOption(label: 'I can read simple code examples', score: 1),
                  PlacementOption(label: 'I have built small projects before', score: 2),
                ],
              ),
              PlacementQuestion(
                question: 'How comfortable are you with loops and conditions?',
                options: [
                  PlacementOption(label: 'I have not used them yet', score: 0),
                  PlacementOption(label: 'I know basic if / for statements', score: 1),
                  PlacementOption(label: 'I use them regularly', score: 2),
                ],
              ),
              PlacementQuestion(
                question: 'Can you debug a small Python error on your own?',
                options: [
                  PlacementOption(label: 'Not yet', score: 0),
                  PlacementOption(label: 'Sometimes with hints', score: 1),
                  PlacementOption(label: 'Yes, most of the time', score: 2),
                ],
              ),
            ],
          ),
        );

  final Ref _ref;

  void selectOption(int optionIndex) {
    if (state.completed) {
      return;
    }

    state = state.copyWith(selectedOptionIndex: optionIndex);
  }

  String _levelFromScore(int score) {
    if (score <= 1) {
      return 'absolute_beginner';
    }
    if (score <= 3) {
      return 'beginner';
    }
    return 'intermediate';
  }

  void continueQuiz() {
    if (!state.canContinue || state.isSaving) {
      return;
    }

    final selected = state.currentQuestion.options[state.selectedOptionIndex!];
    final nextScore = state.totalScore + selected.score;
    final isLastQuestion = state.currentIndex >= state.questions.length - 1;

    if (isLastQuestion) {
      state = state.copyWith(
        totalScore: nextScore,
        completed: true,
        recommendedLevel: _levelFromScore(nextScore),
      );
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      totalScore: nextScore,
      selectedOptionIndex: null,
      clearSelectedOption: true,
      recommendedLevel: _levelFromScore(nextScore),
    );
  }

  Future<void> saveAndContinue() async {
    if (!state.completed || state.isSaving) {
      return;
    }

    state = state.copyWith(isSaving: true);
    await _ref.read(preferencesServiceProvider).savePlacementResult(
          level: state.recommendedLevel,
          score: state.totalScore,
        );
    state = state.copyWith(isSaving: false);
  }
}

final placementQuizProvider = StateNotifierProvider<PlacementQuizNotifier, PlacementQuizState>((ref) {
  return PlacementQuizNotifier(ref);
});