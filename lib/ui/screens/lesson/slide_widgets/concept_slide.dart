import 'package:flutter/material.dart';
import 'package:programming_learn_app/data/models/lesson_slide_model.dart';

class ConceptSlide extends StatelessWidget {
  final LessonSlide slide;
  
  const ConceptSlide({
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
            // Emoji icon
            if (slide.emoji != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x1A58CC02),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  slide.emoji!,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              slide.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Body/concept explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF58CC02).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                slide.body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
