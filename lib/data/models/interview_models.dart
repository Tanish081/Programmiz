import 'package:hive/hive.dart';

@HiveType(typeId: 5)
class InterviewSession {
  const InterviewSession({
    required this.sessionId,
    required this.topic,
    required this.difficulty,
    required this.type,
    required this.questions,
    required this.startedAt,
    required this.completedAt,
    required this.score,
    required this.aiFeedback,
  });

  @HiveField(0)
  final String sessionId;

  @HiveField(1)
  final String topic;

  @HiveField(2)
  final String difficulty;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final List<InterviewQuestion> questions;

  @HiveField(5)
  final DateTime startedAt;

  @HiveField(6)
  final DateTime? completedAt;

  @HiveField(7)
  final int score;

  @HiveField(8)
  final String? aiFeedback;

  InterviewSession copyWith({
    String? sessionId,
    String? topic,
    String? difficulty,
    String? type,
    List<InterviewQuestion>? questions,
    DateTime? startedAt,
    DateTime? completedAt,
    int? score,
    String? aiFeedback,
  }) {
    return InterviewSession(
      sessionId: sessionId ?? this.sessionId,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      questions: questions ?? this.questions,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      score: score ?? this.score,
      aiFeedback: aiFeedback ?? this.aiFeedback,
    );
  }
}

@HiveType(typeId: 6)
class InterviewQuestion {
  const InterviewQuestion({
    required this.questionId,
    required this.questionText,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.sampleAnswer,
    required this.userAnswer,
    required this.aiFeedback,
    required this.scoreAwarded,
    required this.difficulty,
  });

  @HiveField(0)
  final String questionId;

  @HiveField(1)
  final String questionText;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final List<String>? options;

  @HiveField(4)
  final String? correctAnswer;

  @HiveField(5)
  final String? sampleAnswer;

  @HiveField(6)
  final String userAnswer;

  @HiveField(7)
  final String? aiFeedback;

  @HiveField(8)
  final int? scoreAwarded;

  @HiveField(9)
  final String difficulty;

  InterviewQuestion copyWith({
    String? questionId,
    String? questionText,
    String? type,
    List<String>? options,
    String? correctAnswer,
    String? sampleAnswer,
    String? userAnswer,
    String? aiFeedback,
    int? scoreAwarded,
    String? difficulty,
  }) {
    return InterviewQuestion(
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      sampleAnswer: sampleAnswer ?? this.sampleAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      aiFeedback: aiFeedback ?? this.aiFeedback,
      scoreAwarded: scoreAwarded ?? this.scoreAwarded,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
