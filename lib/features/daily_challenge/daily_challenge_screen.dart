import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/features/daily_challenge/daily_challenge_provider.dart';
import 'package:programming_learn_app/features/quiz/widgets/fix_the_bug_widget.dart';
import 'package:programming_learn_app/features/quiz/widgets/mcq_widget.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  Timer? _ticker;
  late final ConfettiController _confetti;
  final TextEditingController _fillBlankController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    Future.microtask(() => ref.read(dailyChallengeProvider.notifier).load());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(dailyChallengeProvider.notifier).tickChallengeClock();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _confetti.dispose();
    _fillBlankController.dispose();
    super.dispose();
  }

  String _dateLabel() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[now.month - 1]} ${now.day}';
  }

  String _durationText(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(duration.inHours);
    final m = two(duration.inMinutes.remainder(60));
    final s = two(duration.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  Color _difficultyColor(String diff) {
    switch (diff) {
      case 'hard':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyChallengeProvider);
    final challenge = state.todaysChallenge;

    if (state.isLoading || challenge == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/language-hub'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Daily Challenge'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(_dateLabel(), style: const TextStyle(fontWeight: FontWeight.w700))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: state.isCompleted ? _completedView(state, challenge) : _activeView(state, challenge),
      ),
    );
  }

  Widget _completedView(DailyChallengeState state, DailyChallengeModel challenge) {
    if (state.earnedXP > 0) {
      _confetti.play();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConfettiWidget(confettiController: _confetti, shouldLoop: false),
          const Text('✅', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 10),
          const Text('Challenge complete!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.green)),
          const SizedBox(height: 6),
          Text('+${state.earnedXP == 0 ? challenge.xpReward : state.earnedXP} XP earned', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          const SizedBox(height: 12),
          Text('Next challenge in ${_durationText(state.timeUntilNext)}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          DuoButton(
            label: 'Practice More',
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outline)),
            child: Text('💡 Fun Fact: ${challenge.funFact}', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700)),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95), duration: 300.ms),
    );
  }

  Widget _activeView(DailyChallengeState state, DailyChallengeModel challenge) {
    final question = challenge.questionData;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF58CC02), Color(0xFF46A302)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
                  child: const Text('🎯 Daily Challenge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
                const SizedBox(height: 10),
                Text(challenge.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _difficultyColor(challenge.difficulty).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    challenge.difficulty.toUpperCase().replaceAll('EASY', '🟢 Easy').replaceAll('MEDIUM', '🟡 Medium').replaceAll('HARD', '🔴 Hard'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 8),
                Text('⚡ +${challenge.xpReward} XP · ⚡ +${challenge.bonusXP} bonus for speed!', style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (state.hasStarted) ...[
            LinearProgressIndicator(
              value: (state.elapsedSeconds / 30).clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.red.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            const SizedBox(height: 4),
            Text('Speed timer: ${state.elapsedSeconds}s / 30s', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
          ],
          const SizedBox(height: 12),
          if (!state.hasStarted)
            DuoButton(
              label: 'I\'m Ready!',
              onPressed: () => ref.read(dailyChallengeProvider.notifier).startChallenge(),
            ),
          if (state.hasStarted) ...[
            if (question.type == 'mcq')
              McqWidget(
                question: question.questionText,
                options: question.options ?? const <String>[],
                hasAnswered: state.hasAnswered,
                wasCorrect: state.isCorrect,
                correctAnswer: question.correctAnswer.toString(),
                selectedOption: state.selectedAnswer,
                onSelect: (v) => ref.read(dailyChallengeProvider.notifier).submitAnswer(v),
              ),
            if (question.type == 'fill_blank')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(question.questionText, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      question.codeSnippet ?? '',
                      style: const TextStyle(fontFamily: 'monospace', color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _fillBlankController,
                    enabled: !state.hasAnswered,
                    decoration: const InputDecoration(
                      labelText: 'Your answer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DuoButton(
                    label: 'Submit',
                    onPressed: state.hasAnswered
                        ? null
                        : () => ref.read(dailyChallengeProvider.notifier).submitAnswer(_fillBlankController.text),
                  ),
                ],
              ),
            if (question.type == 'fix_the_bug')
              FixTheBugWidget(
                question: question.questionText,
                level: 'beginner',
                buggyCode: question.buggyCode ?? question.codeSnippet ?? '',
                fixedCode: question.fixedCode,
                bugDescription: question.bugDescription,
                bugOptions: question.bugOptions ?? question.options ?? const <String>[],
                correctAnswer: question.correctAnswer.toString(),
                hasAnswered: state.hasAnswered,
                wasCorrect: state.isCorrect,
                selectedAnswer: state.selectedAnswer,
                onSubmit: (v) => ref.read(dailyChallengeProvider.notifier).submitAnswer(v),
              ),
            if (state.hasAnswered) ...[
              const SizedBox(height: 8),
              Text(state.explanation ?? ''),
            ],
          ],
        ],
      ),
    );
  }
}