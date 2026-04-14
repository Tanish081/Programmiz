import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/features/onboarding/onboarding_provider.dart';
import 'package:programming_learn_app/ui/components/app_card.dart';
import 'package:programming_learn_app/ui/components/duo_bottom_banner.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';
import 'package:programming_learn_app/ui/components/duo_option_card.dart';
import 'package:programming_learn_app/ui/components/section_header.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  String? _placementLevel;

  static const List<String> _avatars = ['🦊', '🐼', '🦁', '🐸', '🐧', '🤖'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.microtask(_loadPlacement);
  }

  Future<void> _loadPlacement() async {
    final prefs = ref.read(preferencesServiceProvider);
    final level = await prefs.getPlacementLevel();
    if (!mounted) {
      return;
    }

    setState(() {
      _placementLevel = level;
    });

    if (level != null) {
      ref.read(onboardingProvider.notifier).selectPlacementLevel(level);
      ref.read(onboardingProvider.notifier).selectExperience(level);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _levelLabel(String? level) {
    switch (level) {
      case 'intermediate':
        return 'Intermediate';
      case 'beginner':
        return 'Beginner';
      case 'absolute_beginner':
      default:
        return 'Absolute Beginner';
    }
  }

  Future<void> _goToPage(int page) async {
    ref.read(onboardingProvider.notifier).setStep(page);
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final placementLabel = _levelLabel(_placementLevel);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -36,
              right: -24,
              child: _AccentBlob(color: AppColors.yellow.withValues(alpha: 0.18), size: 150),
            ),
            Positioned(
              bottom: 56,
              left: -18,
              child: _AccentBlob(color: AppColors.blue.withValues(alpha: 0.14), size: 120),
            ),
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _welcomePage(placementLabel),
                _identityPage(state),
                _learningSetupPage(state),
                _focusPage(state),
                _finishPage(state, placementLabel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageShell({
    required int step,
    required Widget child,
    required String buttonLabel,
    required VoidCallback? onPressed,
    bool showBack = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: showBack && step > 0 ? () => _goToPage(step - 1) : null,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final active = index == step;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.outline,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: child,
            ),
          ),
          const SizedBox(height: 12),
          DuoButton(label: buttonLabel, onPressed: onPressed),
        ],
      ),
    );
  }

  Widget _welcomePage(String placementLabel) {
    return _pageShell(
      step: 0,
      buttonLabel: 'Continue',
      onPressed: () => _goToPage(1),
      showBack: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.rocket_launch_rounded, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          const Text('Welcome to CodeQuest', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(
            'You just completed a quick placement check. We will build your first path around $placementLabel content.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4),
          ),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.all(18),
            child: DuoBottomBanner(
              title: 'Today is all about momentum',
              subtitle: 'Keep the sessions short, collect XP, and protect your streak. Start small and stay consistent.',
              icon: const Icon(Icons.local_fire_department_rounded, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _identityPage(OnboardingState state) {
    return _pageShell(
      step: 1,
      buttonLabel: state.isNameValid && state.hasAvatar ? 'Continue' : 'Choose a name and avatar',
      onPressed: state.isNameValid && state.hasAvatar ? () => _goToPage(2) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Make it feel like yours',
            subtitle: 'Pick a name and avatar so the app can greet you properly.',
          ),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const ValueKey('onboarding_name_input'),
              onChanged: ref.read(onboardingProvider.notifier).setName,
              decoration: InputDecoration(
                labelText: 'Your name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: AppColors.outline)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: AppColors.outline)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _avatars.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final avatarId = 'avatar_${index + 1}';
              final selected = state.avatarId == avatarId;
              return DuoOptionCard(
                title: _avatars[index],
                subtitle: selected ? 'Selected' : 'Tap to choose',
                selected: selected,
                onTap: () => ref.read(onboardingProvider.notifier).selectAvatar(avatarId),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: selected ? AppColors.primary.withValues(alpha: 0.14) : AppColors.surfaceTint,
                  child: Text(_avatars[index], style: const TextStyle(fontSize: 24)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _learningSetupPage(OnboardingState state) {
    const ages = [
      ('Under 18', 16),
      ('18-24', 21),
      ('25-34', 29),
      ('35+', 40),
    ];

    final recommendedLevel = _placementLevel ?? 'absolute_beginner';

    return _pageShell(
      step: 2,
      buttonLabel: state.hasAgeAndExperience ? 'Continue' : 'Choose your pace',
      onPressed: state.hasAgeAndExperience ? () => _goToPage(3) : null,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Set the right pace',
              subtitle: 'We will tailor the path, but you are always free to move faster or slower.',
            ),
            const SizedBox(height: 18),
            const Text('Age range', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ages.map((entry) {
                final selected = state.ageRangeLabel == entry.$1;
                return ChoiceChip(
                  label: Text(entry.$1),
                  selected: selected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  onSelected: (_) => ref.read(onboardingProvider.notifier).selectAgeRange(age: entry.$2, label: entry.$1),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            const Text('Experience', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            DuoOptionCard(
              title: 'Absolute beginner',
              subtitle: 'Start from variables, print, input, and tiny exercises.',
              selected: state.experienceLevel == 'absolute_beginner' || recommendedLevel == 'absolute_beginner',
              onTap: () => ref.read(onboardingProvider.notifier).selectExperience('absolute_beginner'),
            ),
            const SizedBox(height: 10),
            DuoOptionCard(
              title: 'Beginner',
              subtitle: 'You know some basics and want to build confidence.',
              selected: state.experienceLevel == 'beginner' || recommendedLevel == 'beginner',
              onTap: () => ref.read(onboardingProvider.notifier).selectExperience('beginner'),
            ),
            const SizedBox(height: 10),
            DuoOptionCard(
              title: 'Intermediate',
              subtitle: 'You are ready for loops, functions, files, and structure.',
              selected: state.experienceLevel == 'intermediate' || recommendedLevel == 'intermediate',
              onTap: () => ref.read(onboardingProvider.notifier).selectExperience('intermediate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _focusPage(OnboardingState state) {
    const goals = [
      ('Casual', 10, 'Just browsing'),
      ('Regular', 20, 'Build a habit'),
      ('Serious', 30, 'Keep the streak alive'),
      ('Intense', 50, 'All in'),
    ];

    const times = [
      ('morning', 'Morning', '🌅'),
      ('afternoon', 'Afternoon', '☀️'),
      ('evening', 'Evening', '🌙'),
      ('flexible', 'Flexible', '🔀'),
    ];

    return _pageShell(
      step: 3,
      buttonLabel: state.hasGoal && state.hasPreferredTime ? 'Review setup' : 'Pick your goal',
      onPressed: state.hasGoal && state.hasPreferredTime ? () => _goToPage(4) : null,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Choose a rhythm',
              subtitle: 'A small daily target is enough. We are optimizing for consistency, not pressure.',
            ),
            const SizedBox(height: 18),
            const Text('Daily goal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...goals.map((entry) {
              final selected = state.dailyGoalXP == entry.$2;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DuoOptionCard(
                  title: '${entry.$1} · ${entry.$2} XP',
                  subtitle: entry.$3,
                  selected: selected,
                  onTap: () => ref.read(onboardingProvider.notifier).selectDailyGoal(entry.$2),
                ),
              );
            }),
            const SizedBox(height: 8),
            const Text('Best time to learn', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...times.map((entry) {
              final selected = state.preferredTime == entry.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DuoOptionCard(
                  title: '${entry.$3}  ${entry.$2}',
                  subtitle: 'We will remind you around this time.',
                  selected: selected,
                  onTap: () => ref.read(onboardingProvider.notifier).selectPreferredTime(entry.$1),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _finishPage(OnboardingState state, String placementLabel) {
    final summary =
        'Start: $placementLabel · Goal: ${state.dailyGoalXP ?? 0} XP/day · Time: ${state.preferredTime ?? '-'}';

    return _pageShell(
      step: 4,
      buttonLabel: state.isSaving ? 'Saving...' : 'Start learning',
      onPressed: state.isSaving
          ? null
          : () async {
              await ref.read(onboardingProvider.notifier).completeOnboarding();
              if (mounted) {
                context.go('/home');
              }
            },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 14),
          const Text('You are all set', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            'We are ready to build your first language path.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.all(18),
            child: DuoBottomBanner(
              title: 'Your setup',
              subtitle: summary,
              icon: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
            ),
          ),
          if (state.isSaving) ...[
            const SizedBox(height: 18),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

class _AccentBlob extends StatelessWidget {
  const _AccentBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}