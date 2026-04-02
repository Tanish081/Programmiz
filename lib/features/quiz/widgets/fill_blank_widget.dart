import 'package:flutter/material.dart';

class FillBlankWidget extends StatefulWidget {
  const FillBlankWidget({
    super.key,
    required this.question,
    required this.codeSnippet,
    required this.blanks,
    required this.expectedBlanks,
    required this.hasAnswered,
    required this.onSubmit,
  });

  final String question;
  final String codeSnippet;
  final List<String> blanks;
  final int expectedBlanks;
  final bool hasAnswered;
  final ValueChanged<List<String>> onSubmit;

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> {
  final List<String> _selected = [];

  @override
  Widget build(BuildContext context) {
    final shown = widget.codeSnippet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            shown,
            style: const TextStyle(fontFamily: 'monospace', color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.blanks.map((w) {
            final used = _selected.contains(w);
            return ChoiceChip(
              label: Text(w),
              selected: used,
              onSelected: widget.hasAnswered
                  ? null
                  : (_) {
                      setState(() {
                        if (_selected.length < widget.expectedBlanks && !used) {
                          _selected.add(w);
                        }
                      });
                    },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: widget.hasAnswered ? null : () => widget.onSubmit(List<String>.from(_selected)),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
