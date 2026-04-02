import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';
import 'package:programming_learn_app/features/lesson/lesson_provider.dart';
import 'package:programming_learn_app/ui/components/duo_bottom_banner.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';

class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonProvider(lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text('Guided lesson')),
      body: lessonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load lesson: $err')),
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Lesson not found'));
          }

          final keyIdeas = _buildKeyIdeas(lesson.description);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lesson.title, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 6),
                            Text('Level: ${lesson.level} • ${lesson.topicTag}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            Text(
                              'Read this lesson in short chunks. The goal is to understand one idea at a time, not memorize everything at once.',
                              style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      DuoBottomBanner(
                        title: 'What you will learn',
                        subtitle: keyIdeas.join(' · '),
                        icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(height: 14),
                      DuoBottomBanner(
                        title: 'How to use this lesson',
                        subtitle: '1. Skim the explanation. 2. Inspect the example. 3. Try the quiz once. 4. Use hints if you need them.',
                        icon: const Icon(Icons.menu_book_rounded, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.codeBlock,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Example', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            Text(lesson.codeExample, style: AppTextStyles.code),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Beginner friendly tip', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                            const SizedBox(height: 8),
                            Text(
                              'Look for the pattern, then the purpose. If a line feels confusing, ask what changes before and after it runs.',
                              style: TextStyle(color: Colors.grey.shade800, height: 1.45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                DuoButton(
                  label: 'Start practice quiz',
                  onPressed: () => context.push('/quiz/${lesson.id}'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _buildKeyIdeas(String description) {
    final lower = description.toLowerCase();
    final ideas = <String>[];

    if (lower.contains('variable')) ideas.add('Variables');
    if (lower.contains('loop')) ideas.add('Loops');
    if (lower.contains('condition')) ideas.add('Conditions');
    if (lower.contains('function')) ideas.add('Functions');
    if (lower.contains('list')) ideas.add('Lists');

    if (ideas.isEmpty) {
      ideas.add('Core idea');
      ideas.add('Simple example');
      ideas.add('Practice');
    }

    return ideas.take(3).toList();
  }
}
