import 'package:flutter/material.dart';
import 'package:programming_learn_app/data/models/lesson_slide_model.dart';
import 'intro_slide.dart';
import 'concept_slide.dart';
import 'code_demo_slide.dart';
import 'analogy_slide.dart';
import 'common_mistake_slide.dart';
import 'try_it_slide.dart';
import 'summary_slide.dart';

class SlideRenderer extends StatelessWidget {
  final LessonSlide slide;
  
  const SlideRenderer({
    Key? key,
    required this.slide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (slide.type) {
      case 'intro':
        return IntroSlide(slide: slide);
      case 'concept':
        return ConceptSlide(slide: slide);
      case 'code_demo':
        return CodeDemoSlide(slide: slide);
      case 'analogy':
        return AnalogySlide(slide: slide);
      case 'common_mistake':
        return CommonMistakeSlide(slide: slide);
      case 'try_it':
        return TryItSlide(slide: slide);
      case 'summary':
        return SummarySlide(slide: slide);
      default:
        return Center(
          child: Text(
            'Unknown slide type: ${slide.type}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
    }
  }
}
