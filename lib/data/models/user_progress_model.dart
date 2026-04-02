import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class UserProgressModel {
  @HiveField(0)
  final String lessonId;

  @HiveField(1)
  final int quizScore;

  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final int attemptCount;

  @HiveField(4)
  final DateTime completedAt;

  const UserProgressModel({
    required this.lessonId,
    required this.quizScore,
    required this.isCompleted,
    required this.attemptCount,
    required this.completedAt,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      lessonId: json['lessonId'] as String,
      quizScore: (json['quizScore'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      attemptCount: (json['attemptCount'] as num).toInt(),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'quizScore': quizScore,
      'isCompleted': isCompleted,
      'attemptCount': attemptCount,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
