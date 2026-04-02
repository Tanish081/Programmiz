import 'package:flutter/material.dart';

class McqWidget extends StatelessWidget {
  const McqWidget({
    super.key,
    required this.question,
    required this.options,
    required this.hasAnswered,
    required this.wasCorrect,
    required this.correctAnswer,
    required this.selectedOption,
    required this.onSelect,
  });

  final String question;
  final List<String> options;
  final bool hasAnswered;
  final bool? wasCorrect;
  final String correctAnswer;
  final String? selectedOption;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...options.map((opt) {
          var border = Colors.grey.shade300;
          var background = Colors.white;
          var textColor = Colors.black87;
          var glow = const <BoxShadow>[];

          if (hasAnswered) {
            final isSelected = selectedOption == opt;
            final isCorrect = opt == correctAnswer;

            if (isCorrect) {
              border = Colors.green.shade600;
              textColor = Colors.green.shade900;
              glow = [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ];
            } else if (isSelected && wasCorrect == false) {
              border = Colors.red.shade500;
              textColor = Colors.red.shade900;
              glow = [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ];
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: hasAnswered ? null : () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: background,
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: glow,
                ),
                child: Text(opt, style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
