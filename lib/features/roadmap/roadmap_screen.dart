import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/data/models/roadmap_model.dart';
import 'package:programming_learn_app/data/models/user_profile_model.dart';
import 'package:programming_learn_app/features/roadmap/roadmap_provider.dart';
import 'package:programming_learn_app/ui/components/app_card.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';
import 'package:programming_learn_app/ui/components/duo_progress_bar.dart';
import 'package:programming_learn_app/ui/components/section_header.dart';
import 'package:shimmer/shimmer.dart';

class RoadmapScreen extends ConsumerStatefulWidget {
  const RoadmapScreen({super.key, required this.language});

  final String language;

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  int _expandedPhaseIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadRoadmap);
  }

  Future<void> _loadRoadmap() async {
    final prefs = ref.read(preferencesServiceProvider);
    final profile = await prefs.loadUserProfile();

    final fallbackProfile = UserProfile(
      name: 'Learner',
      avatarId: 'avatar_6',
      age: 16,
      experienceLevel: 'beginner',
      dailyGoalXP: 20,
      preferredTime: 'visual',
      isGuest: true,
      createdAt: DateTime.now(),
    );

    if (!mounted) {
      return;
    }

    await ref
        .read(roadmapProvider.notifier)
        .loadOrGenerate(widget.language, profile ?? fallbackProfile);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roadmapProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Roadmap')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isLoading ? null : () => _showRegenerateDialog(context),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Regenerate'),
      ),
      body: state.isLoading
          ? _RoadmapLoading(streamingText: state.streamingText)
          : state.roadmap == null
              ? _RoadmapError(
                  message: state.error ?? 'Unable to load roadmap right now.',
                  onRetry: _loadRoadmap,
                )
              : _RoadmapContent(
                  roadmap: state.roadmap!,
                  expandedPhaseIndex: _expandedPhaseIndex,
                  onExpandPhase: (index) {
                    setState(() {
                      _expandedPhaseIndex = index;
                    });
                  },
                  onMarkTopicDone: (topicId) {
                    ref.read(roadmapProvider.notifier).markTopicComplete(topicId);
                  },
                ),
    );
  }

  Future<void> _showRegenerateDialog(BuildContext context) async {
    final controller = TextEditingController();

    final shouldRegenerate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Regenerate Roadmap?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'e.g. I want more focus on web development',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Regenerate'),
            ),
          ],
        );
      },
    );

    if (shouldRegenerate != true || !mounted) {
      return;
    }

    final prefs = ref.read(preferencesServiceProvider);
    final profile = await prefs.loadUserProfile();

    final fallbackProfile = UserProfile(
      name: 'Learner',
      avatarId: 'avatar_6',
      age: 16,
      experienceLevel: 'beginner',
      dailyGoalXP: 20,
      preferredTime: 'visual',
      isGuest: true,
      createdAt: DateTime.now(),
    );

    if (!mounted) {
      return;
    }

    await ref.read(roadmapProvider.notifier).regenerate(
          widget.language,
          profile ?? fallbackProfile,
          controller.text.trim().isEmpty ? null : controller.text.trim(),
        );
  }
}

class _RoadmapLoading extends StatelessWidget {
  const _RoadmapLoading({required this.streamingText});

  final String streamingText;

  @override
  Widget build(BuildContext context) {
    final stream = Stream<String>.periodic(
      const Duration(milliseconds: 120),
      (_) => streamingText,
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Center(child: Text('🦉', style: TextStyle(fontSize: 44)))
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(begin: 0, end: -8, duration: 700.ms),
        const SizedBox(height: 10),
        StreamBuilder<String>(
          stream: stream,
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? '🦉 Building your personalised roadmap...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RoadmapError extends StatelessWidget {
  const _RoadmapError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            DuoButton(label: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _RoadmapContent extends StatelessWidget {
  const _RoadmapContent({
    required this.roadmap,
    required this.expandedPhaseIndex,
    required this.onExpandPhase,
    required this.onMarkTopicDone,
  });

  final RoadmapModel roadmap;
  final int expandedPhaseIndex;
  final ValueChanged<int> onExpandPhase;
  final ValueChanged<String> onMarkTopicDone;

  @override
  Widget build(BuildContext context) {
    final totalTopics = roadmap.phases.fold<int>(0, (sum, phase) => sum + phase.topics.length);
    final completedTopics = roadmap.phases
        .expand((phase) => phase.topics)
        .where((topic) => topic.isCompleted)
        .length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF58CC02), Color(0xFF46A302)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🗺️ Your Python Roadmap',
                style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                roadmap.aiSummary,
                style: const TextStyle(height: 1.6, fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _pill('⏱ ~${roadmap.estimatedDays} days'),
                  const SizedBox(width: 8),
                  _pill('📚 $totalTopics topics'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Overall progress',
          subtitle: 'Track how much of the roadmap you have already finished.',
          compact: true,
        ),
        const SizedBox(height: 8),
        DuoProgressBar(value: totalTopics == 0 ? 0 : completedTopics / totalTopics, height: 12),
        const SizedBox(height: 6),
        Text(
          '$completedTopics/$totalTopics topics complete',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        ...List.generate(roadmap.phases.length, (index) {
          final phase = roadmap.phases[index];
          final done = phase.topics.where((topic) => topic.isCompleted).length;
          final total = phase.topics.length;
          final expanded = index == expandedPhaseIndex;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              padding: EdgeInsets.zero,
              radius: 16,
              child: ExpansionTile(
              initiallyExpanded: expanded,
              onExpansionChanged: (value) {
                if (value) {
                  onExpandPhase(index);
                }
              },
              leading: CircleAvatar(
                backgroundColor: Colors.green.withValues(alpha: 0.12),
                child: Text(phase.emoji),
              ),
              title: Text(phase.phaseTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DuoProgressBar(value: total == 0 ? 0 : done / total, height: 6),
                    const SizedBox(height: 4),
                    Text('$done/$total topics', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              trailing: phase.isCompleted
                  ? const Text('✅')
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${phase.estimatedDays}d', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    children: [
                      ...phase.topics.map((topic) {
                        final isDone = topic.isCompleted;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            padding: EdgeInsets.zero,
                            radius: 16,
                            borderColor: Colors.grey.shade200,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 4,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: _difficultyColor(topic.difficulty),
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isDone ? AppColors.primary : Colors.white,
                                                border: Border.all(
                                                  color: isDone ? AppColors.primary : Colors.grey.shade400,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  isDone ? '✓' : '•',
                                                  style: TextStyle(
                                                    color: isDone ? Colors.white : Colors.grey.shade500,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(topic.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${topic.estimatedMinutes} min · ${topic.difficulty}',
                                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        ...topic.keyPoints.map(
                                          (point) => Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('• ', style: TextStyle(fontSize: 13)),
                                                Expanded(
                                                  child: Text(
                                                    point,
                                                    style: const TextStyle(fontSize: 13, height: 1.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        if (topic.linkedLessonId != null)
                                          SizedBox(
                                            width: 180,
                                            child: DuoButton(
                                              label: 'Go to Lesson →',
                                              onPressed: () => context.push('/lesson/${topic.linkedLessonId}'),
                                            ),
                                          )
                                        else
                                          SizedBox(
                                            width: 220,
                                            child: DuoButton(
                                              label: isDone ? 'Studied ✓' : 'Mark as Studied ✓',
                                              onPressed: isDone ? null : () => onMarkTopicDone(topic.topicId),
                                              isPrimary: false,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (phase.topics.isNotEmpty && phase.topics.every((topic) => topic.isCompleted))
                        AppCard.success(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            '🎉 Phase complete! Moving to ${_nextPhaseTitle(roadmap, phase.phaseTitle)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          );
        }),
      ],
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'hard':
        return const Color(0xFFFF4B4B);
      case 'medium':
        return const Color(0xFFFF9600);
      default:
        return const Color(0xFF58CC02);
    }
  }

  String _nextPhaseTitle(RoadmapModel roadmap, String currentPhaseTitle) {
    final index = roadmap.phases.indexWhere((phase) => phase.phaseTitle == currentPhaseTitle);
    if (index == -1 || index + 1 >= roadmap.phases.length) {
      return 'your next milestone';
    }
    return roadmap.phases[index + 1].phaseTitle;
  }
}
