import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FixTheBugWidget extends StatefulWidget {
  const FixTheBugWidget({
    super.key,
    required this.question,
    required this.level,
    required this.buggyCode,
    required this.fixedCode,
    required this.bugDescription,
    required this.bugOptions,
    required this.correctAnswer,
    required this.hasAnswered,
    required this.wasCorrect,
    required this.selectedAnswer,
    required this.onSubmit,
  });

  final String question;
  final String level;
  final String buggyCode;
  final String? fixedCode;
  final String? bugDescription;
  final List<String> bugOptions;
  final String correctAnswer;
  final bool hasAnswered;
  final bool? wasCorrect;
  final String? selectedAnswer;
  final ValueChanged<String> onSubmit;

  @override
  State<FixTheBugWidget> createState() => _FixTheBugWidgetState();
}

class _FixTheBugWidgetState extends State<FixTheBugWidget> {
  String? _selected;

  bool get _spotMode => widget.level == 'absolute_beginner';

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedAnswer;
  }

  @override
  void didUpdateWidget(covariant FixTheBugWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAnswer != widget.selectedAnswer) {
      _selected = widget.selectedAnswer;
    }
  }

  String _renderCode() {
    if (widget.hasAnswered && widget.wasCorrect == true && widget.fixedCode != null) {
      return widget.fixedCode!;
    }
    return widget.buggyCode;
  }

  @override
  Widget build(BuildContext context) {
    final code = _renderCode();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF4B4B), width: 2),
          ),
          child: const Row(
            children: [
              Text('🐛', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('Find the bug!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFFF4B4B))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(widget.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            code,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: widget.hasAnswered && widget.wasCorrect == true ? Colors.green.shade200 : Colors.white,
            ),
          ).animate().shimmer(
                duration: _spotMode ? 0.ms : 1200.ms,
                delay: 200.ms,
                color: Colors.red.withValues(alpha: 0.2),
              ),
        ),
        const SizedBox(height: 12),
        if (_spotMode)
          ...widget.bugOptions.map((option) {
            final isSelected = _selected == option;
            final isCorrect = option == widget.correctAnswer;
            Color border = Colors.grey.shade300;

            if (widget.hasAnswered) {
              if (isCorrect) border = Colors.green;
              if (isSelected && !isCorrect) border = Colors.red;
            } else if (isSelected) {
              border = Colors.blue;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: widget.hasAnswered
                    ? null
                    : () {
                        setState(() {
                          _selected = option;
                        });
                        widget.onSubmit(option);
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 2),
                  ),
                  child: Text(option, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            );
          })
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.bugOptions.map((option) {
              final selected = _selected == option;
              return ChoiceChip(
                label: Text(option),
                selected: selected,
                onSelected: widget.hasAnswered
                    ? null
                    : (_) {
                        setState(() {
                          _selected = option;
                        });
                        widget.onSubmit(option);
                      },
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        if (widget.hasAnswered && widget.wasCorrect == true)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: const Text('Bug squashed! 🐛✅', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.green)),
          ),
        if (widget.hasAnswered && widget.wasCorrect == false)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Text(
              'Not quite! Here is a hint: ${widget.bugDescription ?? 'Look carefully at the code flow.'}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.red),
            ),
          ),
      ],
    );
  }
}
