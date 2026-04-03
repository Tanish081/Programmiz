import 'package:flutter/material.dart';
import 'package:programming_learn_app/data/models/lesson_slide_model.dart';

class IntroSlide extends StatelessWidget {
  final LessonSlide slide;
  
  const IntroSlide({
    Key? key,
    required this.slide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large emoji header
            if (slide.emoji != null)
              Center(
                child: Text(
                  slide.emoji!,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            const SizedBox(height: 24),
            
            // Title
            if (slide.title != null)
              Text(
                slide.title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 16),
            
            // Body text
            if (slide.body != null)
              Text(
                slide.body!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
