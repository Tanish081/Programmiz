import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_strings.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) {
      return;
    }

    final prefs = ref.read(preferencesServiceProvider);
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