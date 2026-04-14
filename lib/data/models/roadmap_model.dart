import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class RoadmapModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String language;

  @HiveField(2)
  final String userLevel;

  @HiveField(3)
  final String userGoal;

  @HiveField(4)
  final String learningStyle;

  @HiveField(5)
  final List<RoadmapPhase> phases;

  @HiveField(6)
  final DateTime generatedAt;

  @HiveField(7)
  final int estimatedDays;

  @HiveField(8)
  final String aiSummary;

  const RoadmapModel({
    required this.id,
    required this.language,
    required this.userLevel,
    required this.userGoal,
    required this.learningStyle,
    required this.phases,
    required this.generatedAt,
    required this.estimatedDays,
    required this.aiSummary,
  });

  RoadmapModel copyWith({
    String? id,
    String? language,
    String? userLevel,
    String? userGoal,
    String? learningStyle,
    List<RoadmapPhase>? phases,
    DateTime? generatedAt,
    int? estimatedDays,
    String? aiSummary,
  }) {
    return RoadmapModel(
      id: id ?? this.id,
      language: language ?? this.language,
      userLevel: userLevel ?? this.userLevel,
      userGoal: userGoal ?? this.userGoal,
      learningStyle: learningStyle ?? this.learningStyle,
      phases: phases ?? this.phases,
      generatedAt: generatedAt ?? this.generatedAt,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      aiSummary: aiSummary ?? this.aiSummary,
    );
  }

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    final phasesJson = (json['phases'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    return RoadmapModel(
      id: json['id'] as String,
      language: json['language'] as String,
      userLevel: json['userLevel'] as String,
      userGoal: json['userGoal'] as String,
      learningStyle: json['learningStyle'] as String,
      phases: phasesJson.map(RoadmapPhase.fromJson).toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      estimatedDays: (json['estimatedDays'] as num).toInt(),
      aiSummary: json['aiSummary'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'userLevel': userLevel,
      'userGoal': userGoal,
      'learningStyle': learningStyle,
      'phases': phases.map((phase) => phase.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
      'estimatedDays': estimatedDays,
      'aiSummary': aiSummary,
    };
  }
}

@HiveType(typeId: 2)
class RoadmapPhase {
  @HiveField(0)
  final String phaseTitle;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final int estimatedDays;

  @HiveField(3)
  final List<RoadmapTopic> topics;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final String emoji;

  const RoadmapPhase({
    required this.phaseTitle,
    required this.description,
    required this.estimatedDays,
    required this.topics,
    required this.isCompleted,
    required this.emoji,
  });

  RoadmapPhase copyWith({
    String? phaseTitle,
    String? description,
    int? estimatedDays,
    List<RoadmapTopic>? topics,
    bool? isCompleted,
    String? emoji,
  }) {
    return RoadmapPhase(
      phaseTitle: phaseTitle ?? this.phaseTitle,
      description: description ?? this.description,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      topics: topics ?? this.topics,
      isCompleted: isCompleted ?? this.isCompleted,
      emoji: emoji ?? this.emoji,
    );
  }

  factory RoadmapPhase.fromJson(Map<String, dynamic> json) {
    final topicsJson = (json['topics'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    return RoadmapPhase(
      phaseTitle: json['phaseTitle'] as String,
      description: json['description'] as String,
      estimatedDays: (json['estimatedDays'] as num).toInt(),
      topics: topicsJson.map(RoadmapTopic.fromJson).toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      emoji: json['emoji'] as String? ?? '📘',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phaseTitle': phaseTitle,
      'description': description,
      'estimatedDays': estimatedDays,
      'topics': topics.map((topic) => topic.toJson()).toList(),
      'isCompleted': isCompleted,
      'emoji': emoji,
    };
  }
}

@HiveType(typeId: 3)
class RoadmapTopic {
  @HiveField(0)
  final String topicId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String difficulty;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final String? linkedLessonId;

  @HiveField(6)
  final List<String> keyPoints;

  @HiveField(7)
  final int estimatedMinutes;

  const RoadmapTopic({
    required this.topicId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.isCompleted,
    required this.linkedLessonId,
    required this.keyPoints,
    required this.estimatedMinutes,
  });

  RoadmapTopic copyWith({
    String? topicId,
    String? title,
    String? description,
    String? difficulty,
    bool? isCompleted,
    String? linkedLessonId,
    List<String>? keyPoints,
    int? estimatedMinutes,
  }) {
    return RoadmapTopic(
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      linkedLessonId: linkedLessonId ?? this.linkedLessonId,
      keyPoints: keyPoints ?? this.keyPoints,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }

  factory RoadmapTopic.fromJson(Map<String, dynamic> json) {
    final keyPointsJson = (json['keyPoints'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => item.toString())
        .toList();

    return RoadmapTopic(
      topicId: json['topicId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: (json['difficulty'] as String? ?? 'easy').toLowerCase(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      linkedLessonId: json['linkedLessonId'] as String?,
      keyPoints: keyPointsJson,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topicId': topicId,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'isCompleted': isCompleted,
      'linkedLessonId': linkedLessonId,
      'keyPoints': keyPoints,
      'estimatedMinutes': estimatedMinutes,
    };
  }
}
