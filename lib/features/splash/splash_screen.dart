import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_strings.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/ui/components/duo_bottom_banner.dart';

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
            colors: [Color(0xFFE9FFD2), Color(0xFFF7FCEB), Color(0xFFD8F5A8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.flutter_dash_rounded, size: 58, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              if (_fact != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: DuoBottomBanner(
                    title: _fact!.title,
                    subtitle: _fact!.fact,
                    icon: Text(_fact!.accent, style: const TextStyle(fontSize: 28)),
                    backgroundColor: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              Text(
                AppStrings.appName,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.tagline,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.green.shade900.withValues(alpha: 0.72), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}