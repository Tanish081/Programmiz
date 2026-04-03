class LessonProgressDetail {
  const LessonProgressDetail({
    required this.lessonId,
    required this.title,
    required this.topicTag,
    required this.level,
    required this.isCompleted,
    required this.quizScore,
    required this.attemptCount,
    this.completedAt,
  });

  final String lessonId;
  final String title;
  final String topicTag;
  final String level;
  final bool isCompleted;
  final int quizScore;
  final int attemptCount;
  final DateTime? completedAt;
}
