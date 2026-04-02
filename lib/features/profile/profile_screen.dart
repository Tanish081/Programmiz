import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/features/profile/profile_provider.dart';
import 'package:programming_learn_app/features/profile/widgets/edit_profile_bottom_sheet.dart';
import 'package:programming_learn_app/ui/components/streak_heatmap_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).load());
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

  String _levelLabel(String level) {
    switch (level) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      default:
        return 'Absolute Beginner';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: () => context.go('/language-hub'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileHeader(state),
                  const SizedBox(height: 12),
                  _statsGrid(state),
                  const SizedBox(height: 14),
                  _activitySection(state),
                  const SizedBox(height: 14),
                  _achievementsSection(state),
                ],
              ),
            ),
    );
  }

  Widget _profileHeader(ProfileState state) {
    final profile = state.profile;
    final name = profile?.name ?? 'Learner';
    final level = _levelLabel(profile?.experienceLevel ?? 'absolute_beginner');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF58CC02), Color(0xFF2E9A00)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white,
            child: Text(_avatarEmoji(profile?.avatarId), style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Text(level, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final result = await showEditProfileBottomSheet(
                context: context,
                initialName: profile?.name ?? 'Learner',
                initialAvatarId: profile?.avatarId ?? 'avatar_6',
                initialDailyGoalXP: profile?.dailyGoalXP ?? 20,
              );
              if (result == null) return;
              await ref.read(profileProvider.notifier).updateProfile(
                    name: result.name,
                    avatarId: result.avatarId,
                    dailyGoalXP: result.dailyGoalXP,
                  );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(ProfileState state) {
    Widget tile(String label, String value, {Color? color}) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color ?? AppColors.textPrimary)),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.45,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        tile('Total XP', '${state.totalXP}', color: AppColors.primaryDark),
        tile('Current Streak', '${state.currentStreak} 🔥', color: Colors.orange.shade700),
        tile('Longest Streak', '${state.longestStreak} days'),
        tile('Daily Challenges', '${state.challengesCompleted}'),
        tile('Fix The Bug Solved', '${state.fixTheBugCompleted}'),
        tile('Avg Quiz Score', '${state.averageScore}%'),
      ],
    );
  }

  Widget _activitySection(ProfileState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity Heatmap', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Your last 12 months of coding activity.', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 8),
          StreakHeatmapWidget(activityByDate: state.yearlyActivity),
        ],
      ),
    );
  }

  Widget _achievementsSection(ProfileState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Achievements', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 8),
          ...state.achievements.map((achievement) {
            final unlocked = achievement.unlocked;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: unlocked ? const Color(0xFFEFFEDE) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: unlocked ? AppColors.primary : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Text(achievement.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(achievement.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(achievement.description, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(unlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded, color: unlocked ? AppColors.primaryDark : Colors.grey),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}