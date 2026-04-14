import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/data/models/lesson_model.dart';
import 'package:programming_learn_app/features/lesson/lesson_provider.dart';
import 'package:programming_learn_app/ui/components/app_card.dart';
import 'package:programming_learn_app/ui/components/duo_progress_bar.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';
import 'package:programming_learn_app/ui/components/section_header.dart';
import 'package:programming_learn_app/ui/screens/lesson/slide_widgets/slide_renderer.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index, int totalSlides) {
    if (index < 0 || index >= totalSlides) {
      return;
    }
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Widget _buildLegacyLessonFallback(BuildContext context, LessonModel lesson) {
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
                      const SizedBox(height: 8),
                      Text(
                        lesson.description,
                        style: TextStyle(color: Colors.grey.shade800, height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.codeBlock,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    lesson.codeExample,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Courier New',
                      fontSize: 13,
                      height: 1.6,
                    ),
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
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonProvider(widget.lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text('Guided lesson')),
      body: lessonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load lesson: $err')),
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Lesson not found'));
          }

          final slides = lesson.slides ?? const [];
          if (slides.isEmpty) {
            return _buildLegacyLessonFallback(context, lesson);
          }

          if (_currentIndex >= slides.length) {
            _currentIndex = 0;
          }

          final progress = slides.length <= 1
              ? 1.0
              : (_currentIndex + 1) / slides.length;
          final isLastSlide = _currentIndex == slides.length - 1;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: DuoProgressBar(value: progress, height: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SectionHeader(
                        title: lesson.title,
                        subtitle: lesson.description,
                        compact: true,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFFEDE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${slides.length}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    radius: 18,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return SlideRenderer(slide: slides[index]);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DuoButton(
                        label: 'Back',
                        onPressed: _currentIndex == 0 ? null : () => _goToPage(_currentIndex - 1, slides.length),
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DuoButton(
                        label: isLastSlide ? 'Start practice quiz' : 'Next',
                        onPressed: () {
                          if (isLastSlide) {
                            context.push('/quiz/${lesson.id}');
                            return;
                          }
                          _goToPage(_currentIndex + 1, slides.length);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
