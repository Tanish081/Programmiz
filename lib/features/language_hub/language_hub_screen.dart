import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/data/local/skill_domains.dart';
import 'package:programming_learn_app/data/services/mascot_service.dart';
import 'package:programming_learn_app/features/home/home_provider.dart';
import 'package:programming_learn_app/features/home/widgets/lesson_card.dart';
import 'package:programming_learn_app/features/language_hub/language_hub_provider.dart';
import 'package:programming_learn_app/features/roadmap/roadmap_screen.dart';
import 'package:programming_learn_app/ui/components/app_card.dart';
import 'package:programming_learn_app/ui/components/duo_bottom_banner.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';
import 'package:programming_learn_app/ui/components/duo_progress_bar.dart';
import 'package:programming_learn_app/ui/components/language_card.dart';
import 'package:programming_learn_app/ui/components/mascot_widget.dart';
import 'package:programming_learn_app/ui/components/section_header.dart';

class LanguageHubScreen extends ConsumerStatefulWidget {
  const LanguageHubScreen({super.key, this.languageId});

  final String? languageId;

  @override
  ConsumerState<LanguageHubScreen> createState() => _LanguageHubScreenState();
}

class _LanguageHubScreenState extends ConsumerState<LanguageHubScreen> {
  MascotMessage _mascotMessage = const MascotMessage(
    emoji: '🤖',
    message: 'Let\'s ship one tiny win today.',
    state: MascotState.encouraging,
  );

  DateTime? _lastBackPressTime;
  Timer? _backPressTimer;
  bool _canExit = false;

  String _avatarEmoji(String? avatarId) {
    switch (avatarId) {
      case 'avatar_1':
        return '🦊';
      case 'avatar_2':
        return '🐼';
      case 'avatar_3':
        return '🦁';
      case 'avatar_4':
        return '🐸';
      case 'avatar_5':
        return '🐧';
      case 'avatar_6':
        return '🤖';
      default:
        return '👩‍💻';
    }
  }

  Future<void> _loadMascotMessage() async {
    final prefs = ref.read(preferencesServiceProvider);
    final mascot = ref.read(mascotServiceProvider);
    final profile = await prefs.loadUserProfile();
    final streak = await prefs.getStreak();
    final message = mascot.getStreakMessage(streak, name: profile?.name);
    await prefs.saveLastMascotMessage(message.message);
    if (!mounted) return;
    setState(() {
      _mascotMessage = message;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeProvider.notifier).load();
      ref.read(languageHubProvider.notifier).load();
      ref.read(audioServiceProvider).startBackground();
      _loadMascotMessage();
    });
  }

  @override
  void dispose() {
    ref.read(audioServiceProvider).stopBackground();
    _backPressTimer?.cancel();
    super.dispose();
  }

  void _handleBackPress() {
    final now = DateTime.now();
    const Duration exitDuration = Duration(seconds: 2);

    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > exitDuration) {
      // First tap or timeout expired
      _lastBackPressTime = now;
      _canExit = false;
      _backPressTimer?.cancel();
      _backPressTimer = Timer(exitDuration, () {
        _lastBackPressTime = null;
        _canExit = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Second tap within 2 seconds - exit app
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hub = ref.watch(languageHubProvider);
    final home = ref.watch(homeProvider);

    if (hub.isLoading || home.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.languageId != null) {
      return _languageDetail(context, home, widget.languageId!);
    }

    return PopScope(
      canPop: _canExit,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Language hub'),
        actions: [
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Text(_avatarEmoji(home.profile?.avatarId), style: const TextStyle(fontSize: 16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${hub.totalXP} XP', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(name: hub.userName, streak: hub.streak, dailyGoalXP: hub.dailyGoalXP, todayXP: hub.todayXP),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: DuoBottomBanner(
                title: 'Your learning path is ready',
                subtitle: 'Your recommended starting point is ${_levelLabel(hub.placementLevel)}. Pick a track and keep moving at your own pace.',
                icon: const Icon(Icons.school_rounded, color: AppColors.primary),
                actionLabel: 'Open track',
                onAction: () => context.go('/language/python'),
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: DuoBottomBanner(
                title: 'Daily challenge is live',
                subtitle: 'One short challenge, bonus XP in the first 30 seconds.',
                icon: const Icon(Icons.timer_rounded, color: AppColors.primary),
                actionLabel: 'Play now',
                onAction: () => context.go('/daily-challenge'),
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: MascotWidget(
                message: _mascotMessage,
              ),
            ),
            const SizedBox(height: 18),
            const SectionHeader(
              title: 'Choose a language',
              subtitle: 'Start with Python now and keep the other tracks waiting in the wings.',
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hub.cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final card = hub.cards[index];
                return LanguageCard(
                  name: card.name,
                  icon: card.icon,
                  subtitle: card.subtitle,
                  available: card.available,
                  onTap: () {
                    if (card.available) {
                      context.go('/language/${card.id}');
                      return;
                    }
                    _showComingSoonSheet(context, card.name, card.subtitle);
                  },
                );
              },
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const SectionHeader(
                  title: 'Career roadmaps',
                  subtitle: 'Browse skill domains if you want a bigger picture.',
                  compact: true,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/skill-domains'),
                  child: const Text('See All →'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kSkillDomains.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final domain = kSkillDomains[index];
                  return InkWell(
                    onTap: () => context.push('/skill-domain-roadmap/${domain.id}'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: domain.primaryColor.withValues(alpha: 0.35), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 4, width: double.infinity, color: domain.primaryColor),
                          const SizedBox(height: 8),
                          Text(domain.emoji, style: const TextStyle(fontSize: 28)),
                          const Spacer(),
                          Text(domain.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          const Text('View →', style: TextStyle(fontSize: 10, color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Practice Interviews', style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 2),
                        Text('AI-powered Q&A', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 94,
                    child: DuoButton(
                      label: 'Start →',
                      onPressed: () => context.go('/interview'),
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: DuoBottomBanner(
                title: 'Today\'s goal',
                subtitle: hub.todayXP >= hub.dailyGoalXP
                    ? 'You already hit your daily target. Keep the streak alive or explore one more lesson.'
                    : '${hub.dailyGoalXP - hub.todayXP} XP left to hit your goal.',
                icon: const Icon(Icons.bolt_rounded, color: AppColors.primary),
                actionLabel: 'Open progress',
                onAction: () => context.go('/progress'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _languageDetail(BuildContext context, HomeState home, String languageId) {
    final isPython = languageId == 'python';
    if (!isPython) {
      return Scaffold(
        appBar: AppBar(title: Text(languageId.toUpperCase())),
        body: Center(
          child: DuoBottomBanner(
            title: 'Coming soon',
            subtitle: 'This track is not available yet. The current path is ready for practice and future languages will follow.',
            icon: const Icon(Icons.hourglass_top_rounded, color: Colors.orange),
            actionLabel: 'Back to hub',
            onAction: () => context.go('/home'),
          ),
        ),
      );
    }

    final lessons = home.lessons;
    final progress = home.todayXP / (home.dailyGoalXP == 0 ? 1 : home.dailyGoalXP);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Learning path'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Lessons'),
            Tab(text: 'Roadmap'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                      const Row(
                        children: [
                          Text('📚', style: TextStyle(fontSize: 34)),
                          SizedBox(width: 10),
                          Text('Learning path', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Your course is ready to go. Move through short lessons, not long walls of text, and build momentum in small steps.', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                      const SizedBox(height: 14),
                      DuoProgressBar(value: progress.clamp(0, 1)),
                      const SizedBox(height: 8),
                      Text('${home.todayXP} / ${home.dailyGoalXP} XP today', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Lessons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                ...lessons.map((lesson) {
                  final index = lessons.indexOf(lesson);
                  final previousCompleted = index == 0 ? true : (home.progress[lessons[index - 1].id]?.isCompleted ?? false);
                  final locked = !previousCompleted;
                  final completed = home.progress[lesson.id]?.isCompleted ?? false;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LessonCard(
                      lesson: lesson,
                      isLocked: locked,
                      isCompleted: completed,
                      onTap: () => context.push('/lesson/${lesson.id}'),
                    ),
                  );
                }),
              ],
            ),
          ),
          RoadmapScreen(language: languageId),
        ],
      ),
    ));
  }

  void _showComingSoonSheet(BuildContext context, String title, String subtitle) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4)),
              const SizedBox(height: 16),
              DuoButton(label: 'Back to hub', onPressed: () => Navigator.pop(context), isPrimary: true),
            ],
          ),
        );
      },
    );
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
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.name, required this.streak, required this.dailyGoalXP, required this.todayXP});

  final String name;
  final int streak;
  final int dailyGoalXP;
  final int todayXP;

  @override
  Widget build(BuildContext context) {
    final progress = dailyGoalXP == 0 ? 0.0 : todayXP / dailyGoalXP;

    return AppCard(
      padding: const EdgeInsets.all(18),
      gradient: const LinearGradient(
        colors: [Color(0xFF62D90A), Color(0xFF44B700)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hi, $name', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Keep the streak warm and the lessons short.', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.92), height: 1.35)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _StatChip(label: '🔥 $streak day streak')),
              const SizedBox(width: 10),
              Expanded(child: _StatChip(label: '$todayXP / $dailyGoalXP XP')),
            ],
          ),
          const SizedBox(height: 16),
          DuoProgressBar(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            color: Colors.white,
            height: 12,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
    );
  }
}