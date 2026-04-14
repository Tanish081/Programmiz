import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/features/progress/progress_provider.dart';
import 'package:programming_learn_app/ui/components/app_card.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(progressProvider.notifier).load());
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }

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

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green.shade700;
    if (score >= 50) return Colors.orange.shade700;
    return Colors.red.shade600;
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _cardShell({required Widget child, EdgeInsets padding = const EdgeInsets.all(20), double radius = 20}) {
    return AppCard(
      padding: padding,
      radius: radius,
      child: child,
    );
  }

  Widget _badge(String text, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _animatedProgressBar({required double value, required Color color, double height = 8}) {
    final clamped = value.clamp(0, 1).toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: clamped),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: height,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      },
    );
  }

  Widget _animSection(Widget child, Duration delay) {
    return child.animate(delay: delay).fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressProvider);
    final isGoalReached = state.xpEarnedToday >= state.dailyGoalXP;
    final goalProgress = state.dailyGoalXP == 0 ? 0.0 : (state.xpEarnedToday / state.dailyGoalXP).clamp(0, 1).toDouble();
    final levelProgress = state.nextLevelFloor <= state.currentLevelFloor
        ? 1.0
        : ((state.totalXP - state.currentLevelFloor) / (state.nextLevelFloor - state.currentLevelFloor)).clamp(0, 1).toDouble();
    final xpToNext = state.xpToNextLevel < 0 ? 0 : state.xpToNextLevel;

    final content = state.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _animSection(_profileHeaderCard(state), const Duration(milliseconds: 0)),
                  const SizedBox(height: 24),
                  _animSection(_todayGoalBanner(state, goalProgress, isGoalReached), const Duration(milliseconds: 100)),
                  const SizedBox(height: 24),
                  _animSection(_streakSection(state), const Duration(milliseconds: 200)),
                  const SizedBox(height: 24),
                  _animSection(_statsSection(state), const Duration(milliseconds: 300)),
                  const SizedBox(height: 24),
                  _animSection(_levelSection(state, levelProgress, xpToNext), const Duration(milliseconds: 400)),
                  const SizedBox(height: 24),
                  _animSection(_curriculumSection(state), const Duration(milliseconds: 500)),
                  const SizedBox(height: 24),
                  _animSection(_recentActivitySection(state), const Duration(milliseconds: 600)),
                ],
              ),
            ),
          );

    if (widget.embedded) return content;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Progress', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: content,
    );
  }

  Widget _profileHeaderCard(ProgressState state) {
    final joinedAt = _formatDate(state.joinedAt);
    return _cardShell(
      padding: const EdgeInsets.all(20),
      radius: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, Colors.deepPurpleAccent, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Text(_avatarEmoji(state.avatarId), style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, ${state.name}! 👋',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.experienceLevel} · Joined $joinedAt',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _badge('🔥 ${state.currentStreak} day streak', Colors.orange.shade600),
                    _badge('⚡ ${state.totalXP} XP', AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile editing coming soon!')),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _todayGoalBanner(ProgressState state, double progress, bool reached) {
    final backgroundColor = reached ? const Color(0xFFE8F5E9) : const Color(0xFFEDE7F6);
    final indicatorColor = reached ? Colors.green : AppColors.primary;
    final label = reached ? '✅ Goal reached!' : 'Keep going! ${state.dailyGoalXP - state.xpEarnedToday} XP to go';

    return AppCard(
      padding: const EdgeInsets.all(16),
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('TODAY\'S GOAL'),
                const SizedBox(height: 8),
                Text(
                  '${state.xpEarnedToday} / ${state.dailyGoalXP} XP',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, _) {
                    return CircularProgressIndicator(
                      value: animatedValue,
                      strokeWidth: 6,
                      backgroundColor: indicatorColor.withValues(alpha: 0.14),
                      valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                    );
                  },
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: indicatorColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _streakSection(ProgressState state) {
    final today = DateTime.now();
    final labels = List<DateTime>.generate(7, (index) => today.subtract(Duration(days: 6 - index)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('STREAK'),
        const SizedBox(height: 10),
        _cardShell(
          radius: 20,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔥', style: GoogleFonts.nunito(fontSize: 36)),
                        const SizedBox(height: 4),
                        Text(
                          '${state.currentStreak}',
                          style: GoogleFonts.nunito(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        Text(
                          'day streak',
                          style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Longest: ${state.longestStreak} days',
                        style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last active: ${_formatDate(state.lastActiveDate)}',
                        style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: 14),
              Row(
                children: List.generate(7, (index) {
                  final date = labels[index];
                  final active = index < state.streakDays.length && state.streakDays[index];
                  final isToday = index == 6;
                  final labelColor = isToday ? AppColors.primary : Colors.grey.shade500;
                  final circle = _StreakCircle(
                    active: active,
                    today: isToday,
                  );

                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          _weekdayLabel(date),
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        circle,
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statsSection(ProgressState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('YOUR STATS'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _statsCard(icon: Icons.menu_book_rounded, color: AppColors.primary, value: '${state.lessonsCompleted}', label: 'Lessons\nDone')),
            const SizedBox(width: 12),
            Expanded(child: _statsCard(icon: Icons.quiz_outlined, color: Colors.orange.shade700, value: '${state.totalQuizzesTaken}', label: 'Quizzes\nTaken')),
            const SizedBox(width: 12),
            Expanded(child: _statsCard(icon: Icons.stars_rounded, color: Colors.amber.shade700, value: '${state.averageScore}%', label: 'Avg\nScore')),
          ],
        ),
      ],
    );
  }

  Widget _statsCard({required IconData icon, required Color color, required String value, required String label}) {
    return _cardShell(
      padding: const EdgeInsets.all(16),
      radius: 16,
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutBack),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelSection(ProgressState state, double progress, int xpToNext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('LEVEL PROGRESS'),
        const SizedBox(height: 10),
        _cardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      state.levelName,
                      style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${state.totalXP} XP total',
                    style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Level ${state.currentLevelNumber}', style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade600)),
                  Text('Level ${state.nextLevelNumber}', style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 8),
              _animatedProgressBar(value: progress, color: AppColors.primary, height: 12),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '$xpToNext XP to next level',
                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _curriculumSection(ProgressState state) {
    const levels = [
      ('absolute_beginner', '🟢', 'Absolute Beginner', Colors.green),
      ('beginner', '🟡', 'Beginner', Colors.orange),
      ('intermediate', '🔴', 'Intermediate', Colors.red),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('PYTHON CURRICULUM'),
        const SizedBox(height: 10),
        ...levels.map((entry) {
          final summary = state.perLevelProgress[entry.$1] ?? const LevelProgressSummary(completed: 0, total: 0);
          final progress = summary.total == 0 ? 0.0 : summary.completed / summary.total;
          final remaining = (summary.total - summary.completed).clamp(0, summary.total);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _cardShell(
              radius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${entry.$2} ${entry.$3}',
                          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        '${summary.completed}/${summary.total} lessons',
                        style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _animatedProgressBar(
                    value: progress,
                    color: entry.$4,
                    height: 8,
                  ),
                  const SizedBox(height: 10),
                  if (summary.total > 0 && summary.completed == summary.total)
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
                        const SizedBox(width: 6),
                        Text('Complete!', style: GoogleFonts.nunito(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w700)),
                      ],
                    )
                  else
                    Text(
                      '$remaining lessons remaining',
                      style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _recentActivitySection(ProgressState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('RECENT ACTIVITY'),
        const SizedBox(height: 10),
        _cardShell(
          radius: 20,
          child: state.recentActivity.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No activity yet\nComplete your first lesson!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.recentActivity.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final item = state.recentActivity[index];
                    final scoreColor = _scoreColor(item.score);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFEDE7F6),
                          child: Icon(Icons.code, color: AppColors.primary, size: 18),
                        ),
                        title: Text(
                          item.lessonTitle,
                          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          '${item.topicTag} · ${_formatDate(item.completedAt)}',
                          style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.score}%',
                              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: scoreColor),
                            ),
                            Text(
                              '+${item.xpEarned} XP',
                              style: GoogleFonts.nunito(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StreakCircle extends StatefulWidget {
  const _StreakCircle({required this.active, required this.today});

  final bool active;
  final bool today;

  @override
  State<_StreakCircle> createState() => _StreakCircleState();
}

class _StreakCircleState extends State<_StreakCircle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    if (widget.active) {
      if (widget.today) {
        _controller.repeat(reverse: true);
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void didUpdateWidget(covariant _StreakCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.today && widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
      );
    }

    final child = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: widget.today ? Colors.deepPurpleAccent.withValues(alpha: 0.9) : Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(Icons.check, size: 14, color: Colors.white),
    );

    if (widget.today) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final scale = 1 + (_controller.value * 0.08);
          final borderAlpha = 0.3 + (_controller.value * 0.7);
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: borderAlpha), width: 2),
              ),
              child: child,
            ),
          );
        },
      );
    }

    return child.animate().scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 650.ms, curve: Curves.easeOutBack).then().scale(begin: const Offset(1.08, 1.08), end: const Offset(1, 1), duration: 300.ms);
  }
}
