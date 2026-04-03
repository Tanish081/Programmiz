import 'package:programming_learn_app/data/models/lesson_slide_model.dart';

class NoteSection {
  final String type; // "concept" | "code" | "warning" | "tip"
  final String title;
  final String body;
  final String? codeSnippet;
  final String? codeOutput;

  NoteSection({
    required this.type,
    required this.title,
    required this.body,
    this.codeSnippet,
    this.codeOutput,
  });
}

class LessonNotesGenerator {
  static List<NoteSection> generateFromSlides(List<LessonSlide> slides) {
    final sections = <NoteSection>[];

    for (final slide in slides) {
      switch (slide.type) {
        case 'concept':
          sections.add(
            NoteSection(
              type: 'concept',
              title: slide.title,
              body: slide.body,
              codeSnippet: slide.codeSnippet,
            ),
          );
          break;

        case 'code_demo':
          sections.add(
            NoteSection(
              type: 'code',
              title: slide.title,
              body: slide.body,
              codeSnippet: slide.codeSnippet,
              codeOutput: slide.codeOutput,
            ),
          );
          break;

        case 'common_mistake':
          sections.add(
            NoteSection(
              type: 'warning',
              title: 'Common Mistake',
              body: slide.body,
              codeSnippet: slide.codeSnippet,
            ),
          );
          break;

        case 'analogy':
          sections.add(
            NoteSection(
              type: 'tip',
              title: 'Remember',
              body: slide.body,
            ),
          );
          break;

        case 'summary':
          // Split summary by newlines and create bullet list
          if (slide.body.isNotEmpty) {
            sections.add(
              NoteSection(
                type: 'summary',
                title: 'Key Takeaways',
                body: slide.body,
              ),
            );
          }
          break;

        case 'intro':
        case 'try_it':
          // Skip intro and try_it slides
          break;

        default:
          break;
      }
    }

    return sections;
  }
}
