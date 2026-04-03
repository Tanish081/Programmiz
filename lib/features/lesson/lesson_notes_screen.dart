import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/core/utils/lesson_notes_generator.dart';
import 'package:programming_learn_app/data/models/lesson_model.dart';
import 'package:programming_learn_app/data/repositories/lesson_repository.dart';

class LessonNotesScreen extends StatefulWidget {
  final String lessonId;

  const LessonNotesScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonNotesScreen> createState() => _LessonNotesScreenState();
}

class _LessonNotesScreenState extends State<LessonNotesScreen> {
  late Future<LessonModel?> _lessonFuture;

  @override
  void initState() {
    super.initState();
    _lessonFuture = LessonRepository().getLessonById(widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: FutureBuilder<LessonModel?>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Lesson not found'));
          }

          final lesson = snapshot.data!;
          final slides = lesson.slides ?? [];

          if (slides.isEmpty) {
            return const Center(
              child: Text('No slides available for notes'),
            );
          }

          final sections = LessonNotesGenerator.generateFromSlides(slides);

          return Column(
            children: [
              // AppBar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '${lesson.title} — Cheat Sheet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharing coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Icon(Icons.share_outlined, size: 24),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(sections.length, (index) {
                      final section = sections[index];
                      Widget sectionWidget;

                      switch (section.type) {
                        case 'concept':
                          sectionWidget = _ConceptCard(section: section);
                          break;

                        case 'code':
                          sectionWidget = _CodeCard(section: section);
                          break;

                        case 'warning':
                          sectionWidget = _WarningCard(section: section);
                          break;

                        case 'tip':
                          sectionWidget = _TipCard(section: section);
                          break;

                        case 'summary':
                          sectionWidget = _SummaryCard(section: section);
                          break;

                        default:
                          return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: sectionWidget,
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  final NoteSection section;

  const _ConceptCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF1CB0F6),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.body,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          if (section.codeSnippet != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                section.codeSnippet!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontFamily: 'Courier',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  final NoteSection section;

  const _CodeCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF58CC02),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (section.codeSnippet != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                section.codeSnippet!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontFamily: 'Courier',
                ),
              ),
            ),
          if (section.codeOutput != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: const Color(0xFF58CC02), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Output:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF58CC02),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    section.codeOutput!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final NoteSection section;

  const _WarningCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Common Mistake',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (section.codeSnippet != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                section.codeSnippet!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontFamily: 'Courier',
                ),
              ),
            ),
          if (section.body.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              section.body,
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange[900],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final NoteSection section;

  const _TipCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Remember',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            section.body,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[900],
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final NoteSection section;

  const _SummaryCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final bullets = section.body.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Takeaways',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(bullets.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      bullets[index].trim(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
