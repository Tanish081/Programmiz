import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/features/home/home_provider.dart';
import 'package:programming_learn_app/features/home/widgets/heart_indicator.dart';
import 'package:programming_learn_app/features/home/widgets/lesson_card.dart';
import 'package:programming_learn_app/features/home/widgets/streak_badge.dart';
import 'package:programming_learn_app/features/home/widgets/xp_bar.dart';
import 'package:programming_learn_app/features/progress/progress_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;
  bool _showXpOverlay = false;
  int _pendingXp = 0;
  String _pendingLessonTitle = '';
  Timer? _overlayTimer;

  static const List<({String id, String name, String icon, bool enabled})> _tracks = [
    (id: 'python', name: 'Python', icon: '🐍', enabled: true),
    (id: 'javascript', name: 'JavaScript', icon: '🟨', enabled: false),
    (id: 'java', name: 'Java', icon: '☕', enabled: false),
    (id: 'cpp', name: 'C++', icon: '⚙️', enabled: false),
    (id: 'go', name: 'Go', icon: '🐹', enabled: false),
    (id: 'rust', name: 'Rust', icon: '🦀', enabled: false),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeProvider.notifier).load();
      ref.read(audioServiceProvider).startBackground();
      _loadPendingXpOverlay();
    });
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    ref.read(audioServiceProvider).stopBackground();
    super.dispose();
  }

  Future<void> _loadPendingXpOverlay() async {
    final prefs = ref.read(preferencesServiceProvider);
    final pendingXp = await prefs.getPendingXPAnimation();
    final lessonTitle = await prefs.getPendingLessonCompleted();

    if (!mounted || pendingXp <= 0 || lessonTitle == null || lessonTitle.isEmpty) {
      return;
    }

    setState(() {
      _pendingXp = pendingXp;
      _pendingLessonTitle = lessonTitle;
      _showXpOverlay = true;
    });

    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(milliseconds: 1500), () async {
      await prefs.clearPendingXPAnimation();
      await prefs.clearPendingLessonCompleted();
      if (!mounted) {
        return;
      }
      setState(() {
        _showXpOverlay = false;
        _pendingXp = 0;
        _pendingLessonTitle = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CodeQuest'),
        actions: [
          StreakBadge(streak: state.streak),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: HeartIndicator(lives: state.lives),
          ),
        ],
      ),
        body: Stack(
        children: [
          _tabIndex == 1
            ? const ProgressScreen(embedded: true)
            : state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.indigo.shade500, Colors.blue.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Hey, ${state.userName}! 👋',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                            Text(
                              '${state.todayXP} / ${state.dailyGoalXP} XP today',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (state.todayXP >= state.dailyGoalXP)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: const Row(
                            children: [
                              Text('🔥', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Daily goal completed! Come back tomorrow and protect your streak.',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: XpBar(totalXP: state.totalXP),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'What do you want to learn today?',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/language/python'),
                              child: const Text('Choose'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: SizedBox(
                        height: 92,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _tracks.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final track = _tracks[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => context.push('/language/${track.id}'),
                              child: Container(
                                width: 116,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: track.enabled ? Colors.blue.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: track.enabled ? Colors.blue.shade200 : Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(track.icon, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(height: 4),
                                    Text(
                                      track.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: track.enabled ? Colors.blue.shade900 : Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      track.enabled ? 'Active' : 'Preview',
                                      style: TextStyle(fontSize: 9, color: track.enabled ? Colors.blue.shade700 : Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = state.lessons[index];
                          final previousCompleted = index == 0
                              ? true
                              : (state.progress[state.lessons[index - 1].id]?.isCompleted ?? false);
                          final locked = !previousCompleted;
                          final completed = state.progress[lesson.id]?.isCompleted ?? false;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: LessonCard(
                              lesson: lesson,
                              isLocked: locked,
                              isCompleted: completed,
                              onTap: () async {
                                await context.push('/lesson/${lesson.id}');
                                if (mounted) {
                                  await ref.read(homeProvider.notifier).load();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          if (_showXpOverlay)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.04),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 112,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD900),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE6BE00), width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Text(
                              '+$_pendingXp XP',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: const Duration(milliseconds: 300))
                              .moveY(begin: 0, end: -60, duration: const Duration(milliseconds: 1000), curve: Curves.easeOut)
                              .fadeOut(delay: const Duration(milliseconds: 700), duration: const Duration(milliseconds: 300)),
                        ),
                      ),
                      Positioned(
                        top: 160,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.black12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Text(
                              '$_pendingLessonTitle complete! 🎉',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                          )
                              .animate(delay: const Duration(milliseconds: 200))
                              .fadeIn(duration: const Duration(milliseconds: 250))
                              .moveY(begin: 0, end: -42, duration: const Duration(milliseconds: 900), curve: Curves.easeOut)
                              .fadeOut(delay: const Duration(milliseconds: 700), duration: const Duration(milliseconds: 250)),
                        ),
                      ),
                      Positioned(
                        top: 74,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('🎊', style: TextStyle(fontSize: 26)),
                              SizedBox(width: 6),
                              Text('🎉', style: TextStyle(fontSize: 26)),
                              SizedBox(width: 6),
                              Text('⭐', style: TextStyle(fontSize: 26)),
                            ],
                          )
                              .animate()
                              .shake(hz: 3, duration: const Duration(milliseconds: 1200))
                              .fadeIn(duration: const Duration(milliseconds: 250))
                              .fadeOut(delay: const Duration(milliseconds: 850), duration: const Duration(milliseconds: 250)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (value) => setState(() => _tabIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Progress'),
        ],
      ),
    );
  }
}
