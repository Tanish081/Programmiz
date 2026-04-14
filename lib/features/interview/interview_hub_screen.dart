import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/utils/hive_boxes.dart';
import 'package:programming_learn_app/data/models/interview_models.dart';
import 'package:programming_learn_app/ui/components/app_card.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';
import 'package:programming_learn_app/ui/components/section_header.dart';

class InterviewHubScreen extends StatefulWidget {
  const InterviewHubScreen({super.key});

  @override
  State<InterviewHubScreen> createState() => _InterviewHubScreenState();
}

class _InterviewHubScreenState extends State<InterviewHubScreen> {
  String? _selectedTopic;
  String _difficulty = 'medium';
  String _type = 'mixed';
  int _count = 10;

  final List<String> _generalTopics = const [
    'Data Structures',
    'Algorithms',
    'System Design',
    'Databases',
  ];

  final List<String> _domainTopics = const [
    'Full Stack',
    'Data Analysis',
    'ML/AI',
    'Android',
    'Security',
  ];

  final List<String> _pythonTopics = const [
    'Python Basics',
    'Functions',
    'OOP',
    'File I/O',
    'Error Handling',
  ];

  List<InterviewSession> _sessions() {
    try {
      final box = Hive.box<InterviewSession>(HiveBoxes.interview);
      final list = box.values.toList();
      list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return list;
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sessions();
    final sessionsCompleted = sessions.where((session) => session.completedAt != null).length;
    final avgScore = sessionsCompleted == 0
        ? 0
        : (sessions
                    .where((session) => session.completedAt != null)
                    .map((session) => session.score)
                    .reduce((a, b) => a + b) /
                sessionsCompleted)
            .round();

    return Scaffold(
      appBar: AppBar(title: const Text('Interview')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E2E), Color(0xFF29293C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎯 Interview Practice', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 8),
                const Text(
                  'Practice real interview questions for your skill level',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _pill('$sessionsCompleted sessions'),
                    const SizedBox(width: 8),
                    _pill('Avg: $avgScore%'),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader(
            title: 'Choose a topic',
            subtitle: 'Pick a lane and we will build the interview around it.',
            compact: true,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._pythonTopics.map((topic) => _topicChip(topic, const Color(0xFF58CC02))),
              ..._domainTopics.map((topic) => _topicChip(topic, const Color(0xFF1CB0F6))),
              ..._generalTopics.map((topic) => _topicChip(topic, Colors.grey.shade600)),
            ],
          ),
          if (_selectedTopic != null) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _selectChip('easy', '🟢 Easy'),
                      _selectChip('medium', '🟡 Medium'),
                      _selectChip('hard', '🔴 Hard'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Interview Type', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _selectChip('conceptual', '🧠 Conceptual', group: 'type'),
                      _selectChip('technical', '💻 Technical', group: 'type'),
                      _selectChip('mixed', '🎯 Mixed', group: 'type'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Questions', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _countChip(5),
                      _countChip(10),
                      _countChip(15),
                      _countChip(20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: DuoButton(
                      label: 'Start Interview Session →',
                      onPressed: () {
                        context.push('/interview-session', extra: {
                          'topic': _selectedTopic,
                          'difficulty': _difficulty,
                          'type': _type,
                          'count': _count,
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Past sessions',
            subtitle: 'Check your recent interview runs and scores.',
            compact: true,
          ),
          const SizedBox(height: 10),
          ...sessions.take(5).map((session) {
            final color = session.score >= 70
                ? const Color(0xFF58CC02)
                : session.score >= 40
                    ? const Color(0xFFFF9600)
                    : const Color(0xFFFF4B4B);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.all(0),
                child: ListTile(
                  title: Text(session.topic),
                  subtitle: Text(DateFormat('dd MMM, yyyy').format(session.startedAt)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('${session.score}%', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Review →'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Widget _topicChip(String topic, Color color) {
    final selected = _selectedTopic == topic;
    return ChoiceChip(
      selected: selected,
      label: Text(selected ? '✓ $topic' : topic),
      onSelected: (_) {
        setState(() {
          _selectedTopic = topic;
        });
      },
      selectedColor: color,
      labelStyle: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.w700),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
    );
  }

  Widget _selectChip(String value, String label, {String group = 'difficulty'}) {
    final selected = group == 'difficulty' ? _difficulty == value : _type == value;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) {
        setState(() {
          if (group == 'difficulty') {
            _difficulty = value;
          } else {
            _type = value;
          }
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      side: BorderSide(color: selected ? AppColors.primary : Colors.grey.shade300),
    );
  }

  Widget _countChip(int count) {
    final selected = _count == count;
    return ChoiceChip(
      selected: selected,
      label: Text('$count'),
      onSelected: (_) {
        setState(() {
          _count = count;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      side: BorderSide(color: selected ? AppColors.primary : Colors.grey.shade300),
    );
  }
}
