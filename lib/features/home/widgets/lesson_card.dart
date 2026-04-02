import 'package:flutter/material.dart';
import 'package:programming_learn_app/data/models/lesson_model.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    required this.isLocked,
    required this.isCompleted,
    required this.onTap,
  });

  final LessonModel lesson;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green : isLocked ? Colors.grey : Colors.deepPurple,
          child: Icon(
            isCompleted ? Icons.check : isLocked ? Icons.lock : Icons.code,
            color: Colors.white,
          ),
        ),
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${lesson.topicTag} • ${lesson.xpReward} XP'),
        trailing: isLocked ? const Icon(Icons.lock_outline) : const Icon(Icons.play_arrow),
        onTap: isLocked ? null : onTap,
      ),
    );
  }
}
