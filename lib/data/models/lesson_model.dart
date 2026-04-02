import 'package:programming_learn_app/data/models/question_model.dart';

class LessonModel {
  final String id;
  final String title;
  final String description;
  final String topicTag;
  final String level; // absolute_beginner | beginner | intermediate
  final int xpReward;
  final String codeExample;
  final List<QuestionModel> questions;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.topicTag,
    required this.level,
    required this.xpReward,
    required this.codeExample,
    required this.questions,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      topicTag: json['topicTag'] as String,
      level: json['level'] as String,
      xpReward: (json['xpReward'] as num).toInt(),
      codeExample: json['codeExample'] as String,
      questions: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'topicTag': topicTag,
      'level': level,
      'xpReward': xpReward,
      'codeExample': codeExample,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}
