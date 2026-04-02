import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_strings.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/features/placement_quiz/placement_quiz_provider.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';
import 'package:programming_learn_app/ui/components/duo_option_card.dart';
import 'package:programming_learn_app/ui/components/duo_progress_bar.dart';

class PlacementQuizScreen extends ConsumerStatefulWidget {
  const PlacementQuizScreen({super.key});

  @override
  ConsumerState<PlacementQuizScreen> createState() => _PlacementQuizScreenState();
}

class _PlacementQuizScreenState extends ConsumerState<PlacementQuizScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(audioServiceProvider).playTap());
  }

  String _levelLabel(String level) {
    switch (level) {
      case 'intermediate':
        return 'Intermediate';
      case 'beginner':
        return 'Beginner';
      default:
        return 'Absolute Beginner';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placementQuizProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quick placement quiz'),
        leading: IconButton(
          onPressed: () => context.go('/splash'),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.3, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 10),
              DuoProgressBar(value: state.progress, height: 12),
              const SizedBox(height: 10),
              Text(
                state.completed
                    ? 'You look ready for ${_levelLabel(state.recommendedLevel)}.'
                    : 'Question ${state.currentIndex + 1} of ${state.questions.length}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: state.completed
                      ? _PlacementResultCard(level: _levelLabel(state.recommendedLevel), score: state.totalScore)
                      : _PlacementQuestionCard(state: state),
                ),
              ),
              const SizedBox(height: 12),
              DuoButton(
                label: state.completed ? 'Continue to onboarding' : 'Continue',
                isBusy: state.isSaving,
                onPressed: state.completed
                    ? () async {
                        await ref.read(placementQuizProvider.notifier).saveAndContinue();
                        if (context.mounted) {
                          context.go('/onboarding');
                        }
                      }
                    : (state.canContinue ? ref.read(placementQuizProvider.notifier).continueQuiz : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlacementQuestionCard extends ConsumerWidget {
  const _PlacementQuestionCard({required this.state});

  final PlacementQuizState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = state.currentQuestion;

    return Container(
      key: ValueKey('question_${state.currentIndex}'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find your starting point', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(question.question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.15)),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final option = question.options[index];
                return DuoOptionCard(
                  title: option.label,
                  selected: state.selectedOptionIndex == index,
                  onTap: () {
                    ref.read(placementQuizProvider.notifier).selectOption(index);
                    ref.read(audioServiceProvider).playTap();
                  },
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'This only helps us pick the right starting lessons. You can change your pace later.',
              style: TextStyle(fontWeight: FontWeight.w600, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacementResultCard extends StatelessWidget {
  const _PlacementResultCard({required this.level, required this.score});

  final String level;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('placement_result'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 14),
          Text('Recommended start: $level', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            'Your placement score was $score. We will use that to shape your first lessons.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }
}