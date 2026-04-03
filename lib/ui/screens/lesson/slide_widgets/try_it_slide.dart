import 'package:flutter/material.dart';
import 'package:programming_learn_app/data/models/lesson_slide_model.dart';

class TryItSlide extends StatefulWidget {
  final LessonSlide slide;
  
  const TryItSlide({
    Key? key,
    required this.slide,
  }) : super(key: key);

  @override
  State<TryItSlide> createState() => _TryItSlideState();
}

class _TryItSlideState extends State<TryItSlide> {
  int? _selectedOptionIndex;
  bool _submitted = false;

  void _checkAnswer(int index) {
    setState(() {
      _selectedOptionIndex = index;
      _submitted = true;
    });
  }

  bool _isCorrect() {
    if (_selectedOptionIndex == null || widget.slide.tryItAnswer == null) return false;
    return _selectedOptionIndex == int.parse(widget.slide.tryItAnswer!);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (widget.slide.title != null)
              Row(
                children: [
                  const Text(
                    '🎯',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.slide.title!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            
            // Prompt/question
            if (widget.slide.tryItPrompt != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF9800),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  widget.slide.tryItPrompt!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            
            // Options
            if (widget.slide.tryItOptions != null && widget.slide.tryItOptions!.isNotEmpty)
              Column(
                children: List.generate(
                  widget.slide.tryItOptions!.length,
                  (index) {
                    final option = widget.slide.tryItOptions![index];
                    final isSelected = _selectedOptionIndex == index;
                    final isCorrectAnswer = widget.slide.tryItAnswer != null && index == int.parse(widget.slide.tryItAnswer!);
                    final showResult = _submitted && isSelected;
                    
                    Color borderColor = Colors.grey[400]!;
                    Color backgroundColor = Colors.transparent;
                    
                    if (_submitted) {
                      if (isCorrectAnswer) {
                        borderColor = const Color(0xFF4CAF50);
                        backgroundColor = const Color(0xFFE8F5E9);
                      } else if (isSelected && !_isCorrect()) {
                        borderColor = const Color(0xFFD32F2F);
                        backgroundColor = const Color(0xFFFFEBEE);
                      }
                    } else if (isSelected) {
                      borderColor = const Color(0xFF2196F3);
                      backgroundColor = const Color(0xFFE3F2FD);
                    }
                    
                    return GestureDetector(
                      onTap: _submitted ? null : () => _checkAnswer(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: borderColor,
                                  width: 2,
                                ),
                                color: isSelected && !_submitted ? const Color(0xFF2196F3) : Colors.transparent,
                              ),
                              child: Center(
                                child: showResult
                                    ? Text(
                                        _isCorrect() ? '✓' : '✗',
                                        style: TextStyle(
                                          color: _isCorrect() ? const Color(0xFF4CAF50) : const Color(0xFFD32F2F),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      )
                                    : isSelected && !_submitted
                                        ? const Text('•', style: TextStyle(color: Colors.white, fontSize: 20))
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            
            // Feedback message
            if (_submitted)
              Center(
                child: Text(
                  _isCorrect() ? '🎉 Great job!' : '❌ Try again!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isCorrect() ? const Color(0xFF4CAF50) : const Color(0xFFD32F2F),
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
