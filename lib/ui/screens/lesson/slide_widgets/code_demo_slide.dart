import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:programming_learn_app/data/models/lesson_slide_model.dart';

class CodeDemoSlide extends StatefulWidget {
  final LessonSlide slide;
  
  const CodeDemoSlide({
    Key? key,
    required this.slide,
  }) : super(key: key);

  @override
  State<CodeDemoSlide> createState() => _CodeDemoSlideState();
}

class _CodeDemoSlideState extends State<CodeDemoSlide> {
  bool _codeExpanded = false;

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!'), duration: Duration(seconds: 1)),
    );
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
              Text(
                widget.slide.title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 12),
            
            // Body/explanation
            if (widget.slide.body != null)
              Text(
                widget.slide.body!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            const SizedBox(height: 16),
            
            // Code snippet
            if (widget.slide.codeSnippet != null)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF58CC02).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Code',
                            style: TextStyle(
                              color: Color(0xFF58CC02),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _copyToClipboard(widget.slide.codeSnippet!),
                            child: const Icon(
                              Icons.copy,
                              color: Color(0xFF58CC02),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color(0xFF252526),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            widget.slide.codeSnippet!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Courier New',
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // Code output
            if (widget.slide.codeOutput != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Output',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.slide.codeOutput!,
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Courier New',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
