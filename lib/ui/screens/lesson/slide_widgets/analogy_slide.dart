import 'package:flutter/material.dart';
import 'package:programming_learn_app/data/models/lesson_slide_model.dart';

class AnalogySlide extends StatelessWidget {
  final LessonSlide slide;
  
  const AnalogySlide({
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
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x1A2196F3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    slide.emoji!,
                    style: const TextStyle(fontSize: 56),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            
            // Title
            if (slide.title != null)
              Text(
                slide.title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            
            // Analogy text in a highlighted box
            if (slide.analogyText != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2196F3),
                    width: 2,
                  ),
                ),
                child: Text(
                  slide.analogyText!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            
            // Body/explanation below analogy
            if (slide.body != null) ...[
              const SizedBox(height: 16),
              Text(
                slide.body!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
