import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/features/quiz/quiz_provider.dart';
import 'package:programming_learn_app/features/quiz/widgets/arrange_code_widget.dart';
import 'package:programming_learn_app/features/quiz/widgets/fill_blank_widget.dart';
import 'package:programming_learn_app/features/quiz/widgets/fix_the_bug_widget.dart';
import 'package:programming_learn_app/features/quiz/widgets/mcq_widget.dart';
import 'package:programming_learn_app/ui/components/mascot_widget.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _shownResult = false;
  int _lastFeedbackQuestion = -1;
  bool _showManualHint = false;
  int _lastQuestionIndex = -1;
  final Map<String, List<String>> _arrangedOptionCache = <String, List<String>>{};
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    Future.microtask(() => ref.read(quizProvider.notifier).load(widget.lessonId));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _playAnswerFeedback(bool correct) {
    if (correct) {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
      ref.read(audioServiceProvider).playCorrect();
      return;
    }
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    ref.read(audioServiceProvider).playWrong();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);

    if (_lastQuestionIndex != state.currentIndex) {
      _lastQuestionIndex = state.currentIndex;
      _showManualHint = false;
    }

    if (state.hasAnswered && state.currentIndex != _lastFeedbackQuestion && state.wasCorrect != null) {
      _lastFeedbackQuestion = state.currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playAnswerFeedback(state.wasCorrect!);
      });
    }

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.lesson == null || state.currentQuestion == null) {
      return const Scaffold(body: Center(child: Text('Quiz not available')));
    }

    if (state.completed && !_shownResult) {
      _shownResult = true;
      if (state.reachedDailyGoal) {
        ref.read(audioServiceProvider).playGoalReached();
        _confettiController.play();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet<void>(
          context: context,
          isDismissible: false,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.reachedDailyGoal)
                    ConfettiWidget(
                      confettiController: _confettiController,
                      shouldLoop: false,
                      blastDirectionality: BlastDirectionality.explosive,
                    ),
                  Text(state.failed ? 'Quiz Failed' : 'Quiz Complete', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Score: ${state.correctCount}/${state.totalQuestions}'),
                  Text('XP earned: ${state.earnedXp}'),
                  if (state.reachedDailyGoal) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: const Column(
                        children: [
                          Text('🔥 Daily Goal Complete!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Come back tomorrow to keep your streak alive!', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/home');
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
            );
          },
        );
      });
    }

    final q = state.currentQuestion!;
    final progress = ((state.currentIndex + 1) / state.totalQuestions).clamp(0, 1).toDouble();
    final scorePercent = state.totalQuestions == 0 ? 0 : ((state.correctCount / state.totalQuestions) * 100).round();
    final mascotMessage = ref.read(mascotServiceProvider).getPerformanceMessage(scorePercent);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          IconButton(
            tooltip: 'Go Home',
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                'Beginner mode: your first wrong attempt gives a hint and does not cost a life.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('Question ${state.currentIndex + 1} of ${state.totalQuestions}'),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) {
                final active = i < state.hearts;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(Icons.favorite, color: active ? Colors.red : Colors.grey.shade400),
                );
              }),
            ),
            const SizedBox(height: 16),
            Center(
              child: MascotWidget(message: mascotMessage, size: 48),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: _buildQuestion(q, state),
              ),
            ),
            if (!state.hasAnswered)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showManualHint = !_showManualHint;
                  });
                },
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(_showManualHint ? 'Hide hint' : 'Need a hint?'),
              ),
            if (!state.hasAnswered && _showManualHint)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Text(
                  q.explanation,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            if (!state.hasAnswered && state.wasCorrect == false && (state.explanation?.startsWith('Hint:') ?? false))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Text(
                  state.explanation!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            if (state.hasAnswered) ...[
              const SizedBox(height: 8),
              Text(state.explanation ?? ''),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ref.read(quizProvider.notifier).next(),
                  child: const Text('Next'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(dynamic q, QuizState state) {
    if (q.type == 'mcq') {
      return McqWidget(
        question: q.questionText,
        options: q.options ?? const <String>[],
        hasAnswered: state.hasAnswered,
        wasCorrect: state.wasCorrect,
        correctAnswer: q.correctAnswer.toString(),
        selectedOption: state.submittedAnswer?.toString(),
        onSelect: (value) => ref.read(quizProvider.notifier).answer(value),
      );
    }

    if (q.type == 'fill_blank') {
      final expectedCount = q.correctAnswer is List ? (q.correctAnswer as List).length : 1;
      return FillBlankWidget(
        question: q.questionText,
        codeSnippet: q.codeSnippet ?? '',
        blanks: q.blanks ?? const <String>[],
        expectedBlanks: expectedCount,
        hasAnswered: state.hasAnswered,
        onSubmit: (value) => ref.read(quizProvider.notifier).answer(value),
      );
    }

    if (q.type == 'fix_the_bug') {
      return FixTheBugWidget(
        question: q.questionText,
        level: state.lesson?.level ?? 'absolute_beginner',
        buggyCode: q.buggyCode ?? q.codeSnippet ?? '',
        fixedCode: q.fixedCode,
        bugDescription: q.bugDescription,
        bugOptions: q.bugOptions ?? q.options ?? const <String>[],
        correctAnswer: q.correctAnswer.toString(),
        hasAnswered: state.hasAnswered,
        wasCorrect: state.wasCorrect,
        selectedAnswer: state.submittedAnswer?.toString(),
        onSubmit: (value) => ref.read(quizProvider.notifier).answer(value),
      );
    }

    final lines = (q.correctAnswer as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final shuffled = _arrangedOptionCache.putIfAbsent(
      q.id.toString(),
      () => List<String>.from(lines)..shuffle(),
    );
    return ArrangeCodeWidget(
      question: q.questionText,
      lines: shuffled,
      hasAnswered: state.hasAnswered,
      onSubmit: (value) => ref.read(quizProvider.notifier).answer(value),
    );
  }
}
