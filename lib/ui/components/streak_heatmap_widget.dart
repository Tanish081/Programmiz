import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:programming_learn_app/data/services/preferences_service.dart';

class StreakHeatmapWidget extends StatefulWidget {
  const StreakHeatmapWidget({super.key});

  @override
  State<StreakHeatmapWidget> createState() => _StreakHeatmapWidgetState();
}

class _StreakHeatmapWidgetState extends State<StreakHeatmapWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getCellColor(int xp) {
    if (xp == 0) return const Color(0xFFEBEBEB);
    if (xp >= 1 && xp <= 10) return const Color(0xFFB8F5A0);
    if (xp >= 11 && xp <= 30) return const Color(0xFF58CC02);
    if (xp >= 31 && xp <= 50) return const Color(0xFF46A302);
    return const Color(0xFF2D7A00);
  }

  List<List<DateTime?>> _generateWeeks() {
    final today = DateTime.now();
    final days = <DateTime>[];
    
    // Generate 365 days backwards from today
    for (int i = 0; i < 365; i++) {
      days.add(today.subtract(Duration(days: i)));
    }
    
    days.sort(); // Sort ascending (oldest to newest)
    
    // Group into weeks (Mon-Sun, with padding)
    final weeks = <List<DateTime?>>[
];
    
    // Find first Monday
    final firstDay = days.first;
    int daysToMonday = (firstDay.weekday - 1) % 7;
    
    int dayIndex = -daysToMonday;
    
    while (dayIndex < days.length) {
      final week = <DateTime?>[];
      for (int i = 0; i < 7; i++) {
        if (dayIndex >= 0 && dayIndex < days.length) {
          week.add(days[dayIndex]);
        } else {
          week.add(null);
        }
        dayIndex++;
      }
      weeks.add(week);
    }
    
    return weeks;
  }

  String _getMonthLabel(List<DateTime?> week) {
    // Show label only if week contains the 1st of a month
    for (final day in week) {
      if (day != null && day.day == 1) {
        return DateFormat('MMM').format(day);
      }
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  void _showCellTooltip(DateTime date, int xp) {
    final dateStr = _formatDate(date);
    final message = xp > 0 ? '$dateStr: $xp XP earned' : '$dateStr: No activity';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: PreferencesService().getYearlyActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 140,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }

        final activityByDate = snapshot.data ?? {};

        if (activityByDate.isEmpty) {
          return Container(
            height: 140,
            alignment: Alignment.center,
            child: Text(
              'No activity yet — start learning! 🌱',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          );
        }

        final weeks = _generateWeeks();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 140),
          child: Column(
            children: [
              // Month labels row (scrollable with grid)
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 16), // Space for day labels column
                    ...weeks.map((week) {
                      final label = _getMonthLabel(week);
                      return SizedBox(
                        width: 13, // Cell (11px) + gap (2px)
                        height: 16,
                        child: Center(
                          child: label.isNotEmpty
                              ? Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Main grid with day labels
              Expanded(
                child: Row(
                  children: [
                    // Fixed day labels column (M, W, F)
                    SizedBox(
                      width: 16,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text('M', style: TextStyle(fontSize: 9, color: Colors.grey)),
                          Text('W', style: TextStyle(fontSize: 9, color: Colors.grey)),
                          Text('F', style: TextStyle(fontSize: 9, color: Colors.grey)),
                          Text('S', style: TextStyle(fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                    ),
                    // Scrollable grid
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            // 7 rows for each day of week
                            for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++)
                              Row(
                                children: [
                                  for (final week in weeks)
                                    GestureDetector(
                                      onTap: week[dayOfWeek] != null
                                          ? () {
                                              final date = week[dayOfWeek]!;
                                              final dateStr =
                                                  date.toIso8601String().split('T')[0];
                                              final xp = activityByDate[dateStr] ?? 0;
                                              _showCellTooltip(date, xp);
                                            }
                                          : null,
                                      child: Container(
                                        width: 11,
                                        height: 11,
                                        margin: const EdgeInsets.only(right: 2, bottom: 2),
                                        decoration: BoxDecoration(
                                          color: week[dayOfWeek] == null
                                              ? Colors.transparent
                                              : _getCellColor(
                                                  activityByDate[
                                                          week[dayOfWeek]!
                                                              .toIso8601String()
                                                              .split('T')[0]] ??
                                                      0,
                                                ),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  SizedBox(width: 2), // Gap between weeks
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Legend row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Less',
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 6),
                  for (final color in const [
                    Color(0xFFEBEBEB),
                    Color(0xFFB8F5A0),
                    Color(0xFF58CC02),
                    Color(0xFF46A302),
                    Color(0xFF2D7A00),
                  ])
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  Text(
                    'More',
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}