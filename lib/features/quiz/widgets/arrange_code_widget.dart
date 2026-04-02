import 'package:flutter/material.dart';

class _ArrangeLine {
  const _ArrangeLine({required this.id, required this.text});

  final String id;
  final String text;
}

class ArrangeCodeWidget extends StatefulWidget {
  const ArrangeCodeWidget({
    super.key,
    required this.question,
    required this.lines,
    required this.hasAnswered,
    required this.onSubmit,
  });

  final String question;
  final List<String> lines;
  final bool hasAnswered;
  final ValueChanged<List<String>> onSubmit;

  @override
  State<ArrangeCodeWidget> createState() => _ArrangeCodeWidgetState();
}

class _ArrangeCodeWidgetState extends State<ArrangeCodeWidget> {
  late List<_ArrangeLine> _items;

  @override
  void initState() {
    super.initState();
    _items = _buildLines(widget.lines);
  }

  @override
  void didUpdateWidget(covariant ArrangeCodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameLines(oldWidget.lines, widget.lines)) {
      setState(() {
        _items = _buildLines(widget.lines);
      });
    }
  }

  List<_ArrangeLine> _buildLines(List<String> lines) {
    return [
      for (var i = 0; i < lines.length; i++) _ArrangeLine(id: 'line_$i', text: lines[i]),
    ];
  }

  bool _sameLines(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ReorderableListView(
            onReorder: widget.hasAnswered
                ? (oldIndex, newIndex) {}
                : (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _items.removeAt(oldIndex);
                      _items.insert(newIndex, item);
                    });
                  },
            children: [
              for (int i = 0; i < _items.length; i++)
                ListTile(
                  key: ValueKey(_items[i].id),
                  title: Text(_items[i].text, style: const TextStyle(fontFamily: 'monospace')),
                  tileColor: Colors.grey.shade100,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: widget.hasAnswered ? null : () => widget.onSubmit(_items.map((e) => e.text).toList()),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
