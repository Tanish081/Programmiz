import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/features/daily_challenge/daily_challenge_screen.dart';
import 'package:programming_learn_app/features/language_hub/language_hub_screen.dart';
import 'package:programming_learn_app/features/onboarding/onboarding_screen.dart';
import 'package:programming_learn_app/features/placement_quiz/placement_quiz_screen.dart';
import 'package:programming_learn_app/features/profile/profile_screen.dart';
import 'package:programming_learn_app/features/splash/splash_screen.dart';
import 'package:programming_learn_app/features/lesson/lesson_screen.dart';
import 'package:programming_learn_app/features/lesson/lesson_notes_screen.dart';
import 'package:programming_learn_app/features/progress/progress_screen.dart';
import 'package:programming_learn_app/features/quiz/quiz_screen.dart';
import 'package:programming_learn_app/features/quiz/quiz_results_screen.dart';
import 'package:programming_learn_app/data/models/quiz_result_data.dart';
import 'package:programming_learn_app/data/services/preferences_service.dart';
import 'package:programming_learn_app/ui/components/app_scaffold.dart';

class AppRouter {
  static final PreferencesService _preferencesService = PreferencesService();

  static GoRouter create() {
    return GoRouter(
      initialLocation: '/',
      redirect: _redirect,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/placement-quiz',
          builder: (context, state) => const PlacementQuizScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/quiz/:lessonId',
          builder: (context, state) {
            final lessonId = state.pathParameters['lessonId'];
            if (lessonId == null || lessonId.isEmpty) {
              return const _RouteErrorScreen(message: 'Missing lesson id');
            }
            return QuizScreen(lessonId: lessonId);
          },
        ),
        GoRoute(
          path: '/quiz-results',
          builder: (context, state) {
            final data = state.extra as QuizResultData?;
            if (data == null) {
              return const _RouteErrorScreen(message: 'Missing quiz result data');
            }
            return QuizResultsScreen(data: data);
          },
        ),
        ShellRoute(
          builder: (context, state, child) => AppScaffold(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const LanguageHubScreen(),
            ),
            GoRoute(
              path: '/language-hub',
              builder: (context, state) => const LanguageHubScreen(),
            ),
            GoRoute(
              path: '/language/:languageId',
              builder: (context, state) {
                final languageId = state.pathParameters['languageId'];
                if (languageId == null || languageId.isEmpty) {
                  return const _RouteErrorScreen(message: 'Missing language id');
                }
                return LanguageHubScreen(languageId: languageId);
              },
            ),
            GoRoute(
              path: '/lesson/:lessonId',
              builder: (context, state) {
                final lessonId = state.pathParameters['lessonId'];
                if (lessonId == null || lessonId.isEmpty) {
                  return const _RouteErrorScreen(message: 'Missing lesson id');
                }
                return LessonScreen(lessonId: lessonId);
              },
            ),
            GoRoute(
              path: '/lesson-notes/:lessonId',
              builder: (context, state) {
                final lessonId = state.pathParameters['lessonId'];
                if (lessonId == null || lessonId.isEmpty) {
                  return const _RouteErrorScreen(message: 'Missing lesson id');
                }
                return LessonNotesScreen(lessonId: lessonId);
              },
            ),
            GoRoute(
              path: '/progress',
              builder: (context, state) => const ProgressScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/daily-challenge',
              builder: (context, state) => const DailyChallengeScreen(),
            ),
          ],
        ),
      ],
    );
  }

  static FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
    final location = state.matchedLocation;
    if (location == '/' || location == '/splash') {
      return null;
    }

    final hasCompletedPlacement = await _preferencesService.hasCompletedPlacementQuiz();
    final hasCompletedOnboarding = await _preferencesService.hasCompletedOnboarding();

    if (!hasCompletedPlacement && location != '/placement-quiz') {
      return '/placement-quiz';
    }

    if (hasCompletedPlacement && !hasCompletedOnboarding && location != '/onboarding') {
      return '/onboarding';
    }

    if (hasCompletedPlacement && hasCompletedOnboarding && (location == '/onboarding' || location == '/placement-quiz')) {
      return '/home';
    }

    return null;
  }
}

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation error')),
      body: Center(child: Text(message)),
    );
  }
}
