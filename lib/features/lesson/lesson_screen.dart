import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';
import 'package:programming_learn_app/features/lesson/lesson_provider.dart';

class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonProvider(lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: lessonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load lesson: $err')),
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Lesson not found'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Text(lesson.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text('Level: ${lesson.level} • ${lesson.topicTag}'),
                      const SizedBox(height: 14),
                      Text(lesson.description),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('How to use this lesson', style: TextStyle(fontWeight: FontWeight.w800)),
                            SizedBox(height: 6),
                            Text('1. Read the code slowly and match it with the explanation.'),
                            Text('2. Focus on one concept only, then try the quiz.'),
                            Text('3. Use hints in quiz if you get stuck. That is normal.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.codeBlock,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(lesson.codeExample, style: AppTextStyles.code),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: const Text(
                          'Beginner tip: If this code looks confusing, read from top to bottom and ask "what is this line doing?" one line at a time.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/quiz/${lesson.id}'),
                    child: const Text('Start Guided Quiz'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
