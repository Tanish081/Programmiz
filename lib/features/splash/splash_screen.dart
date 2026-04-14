import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_strings.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/ui/components/app_card.dart';
import 'package:programming_learn_app/ui/components/duo_bottom_banner.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';
import 'package:programming_learn_app/ui/components/section_header.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const List<({String title, String fact, String accent})> _funFacts = [
    (
      title: 'Did you know?',
      fact: 'Programming languages often share the same core ideas even when their syntax looks very different.',
      accent: '🐍',
    ),
    (
      title: 'Fun fact',
      fact: 'The word "debug" became popular after a real moth was found in a computer log.',
      accent: '🪲',
    ),
    (
      title: 'Quick fact',
      fact: 'A good learning loop is: read, try, fail a little, then try again.',
      accent: '🔁',
    ),
    (
      title: 'Tiny fact',
      fact: 'Short practice sessions usually help memory more than one long session.',
      accent: '⏱️',
    ),
    (
      title: 'Interesting fact',
      fact: 'The first compiled programming languages made it much easier to build large software systems.',
      accent: '🧠',
    ),
  ];

  ({String title, String fact, String accent})? _fact;

  @override
  void initState() {
    super.initState();
    _loadFactAndBootstrap();
  }

  Future<void> _loadFactAndBootstrap() async {
    final prefs = ref.read(preferencesServiceProvider);
    final lastIndex = await prefs.getLastFunFactIndex();
    final nextIndex = _pickFactIndex(lastIndex);

    if (!mounted) {
      return;
    }

    setState(() {
      _fact = _funFacts[nextIndex];
    });

    await prefs.setLastFunFactIndex(nextIndex);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) {
      return;
    }

    final hasPlacement = await prefs.hasCompletedPlacementQuiz();
    final hasOnboarding = await prefs.hasCompletedOnboarding();

    if (!mounted) {
      return;
    }

    if (!hasPlacement) {
      context.go('/placement-quiz');
      return;
    }

    if (!hasOnboarding) {
      context.go('/onboarding');
      return;
    }

    context.go('/home');
  }

  int _pickFactIndex(int? lastIndex) {
    final candidateIndices = List<int>.generate(_funFacts.length, (index) => index)
      ..shuffle();

    if (lastIndex == null) {
      return candidateIndices.first;
    }

    for (final index in candidateIndices) {
      if (index != lastIndex) {
        return index;
      }
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9FFD2), Color(0xFFF8FEEA), Color(0xFFDDF7AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -36,
                right: -18,
                child: _GlowBlob(color: AppColors.yellow.withValues(alpha: 0.18), size: 160),
              ),
              Positioned(
                bottom: 90,
                left: -24,
                child: _GlowBlob(color: AppColors.blue.withValues(alpha: 0.16), size: 140),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.flutter_dash_rounded, size: 58, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.appName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.tagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.green.shade900.withValues(alpha: 0.72), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 18),
                      if (_fact != null) ...[
                        AppCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.yellow.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(_fact!.accent, style: const TextStyle(fontSize: 24)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SectionHeader(
                                      title: _fact!.title,
                                      subtitle: 'Quick brain snack while we get the path ready.',
                                      compact: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _fact!.fact,
                                style: const TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ready when you are',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We will check your progress, show the right setup flow, and drop you right into the next lesson.',
                              style: TextStyle(fontSize: 14, color: Colors.green.shade900.withValues(alpha: 0.72), height: 1.45),
                            ),
                            const SizedBox(height: 14),
                            DuoButton(
                              label: 'Loading your path...',
                              onPressed: () {},
                              isPrimary: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

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