import 'package:flutter/material.dart';

class StreakHeatmapWidget extends StatefulWidget {
  const StreakHeatmapWidget({super.key, required this.activityByDate});

  final Map<String, int> activityByDate;

  @override
  State<StreakHeatmapWidget> createState() => _StreakHeatmapWidgetState();
}

class _StreakHeatmapWidgetState extends State<StreakHeatmapWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _cellColor(int xp) {
    if (xp <= 0) return const Color(0xFFEBEBEB);
    if (xp <= 10) return const Color(0xFFB8F5A0);
    if (xp <= 30) return const Color(0xFF58CC02);
    if (xp <= 50) return const Color(0xFF46A302);
    return const Color(0xFF2D7A00);
  }

  List<DateTime> _daysForYear() {
    final today = DateTime.now();
    return List<DateTime>.generate(364, (index) => today.subtract(Duration(days: 363 - index)));
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysForYear();
    final weeks = <List<DateTime>>[];
    for (var i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, (i + 7).clamp(0, days.length)));
    }

    final monthLabels = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayLabels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 18),
              ...List<Widget>.generate(weeks.length, (index) {
                final first = weeks[index].first;
                final text = first.day <= 7 ? monthLabels[first.month - 1] : '';
                return SizedBox(
                  width: 12,
                  child: Text(text, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: dayLabels
                    .map((label) => SizedBox(
                          width: 14,
                          height: 12,
                          child: Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                        ))
                    .toList(),
              ),
              const SizedBox(width: 4),
              ...weeks.map((week) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Column(
                    children: List<Widget>.generate(7, (dayIndex) {
                      if (dayIndex >= week.length) {
                        return const SizedBox(height: 12, width: 10);
                      }
                      final date = week[dayIndex];
                      final key = date.toIso8601String().split('T').first;
                      final xp = widget.activityByDate[key] ?? 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _cellColor(xp),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Less', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(width: 6),
            for (final color in const [
              Color(0xFFEBEBEB),
              Color(0xFFB8F5A0),
              Color(0xFF58CC02),
              Color(0xFF46A302),
              Color(0xFF2D7A00),
            ])
              Container(
                margin: const EdgeInsets.only(right: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
            Text('More', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ],
    );
  }
}