class Lesson {
  final String id;
  final String title;
  final String languageId;
  final int lessonNumber;
  final List<QuestionItem> questions;
  final String description;

  Lesson({
    required this.id,
    required this.title,
    required this.languageId,
    required this.lessonNumber,
    required this.questions,
    required this.description,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      languageId: json['languageId'],
      lessonNumber: json['lessonNumber'],
      questions: (json['questions'] as List)
          .map((q) => QuestionItem.fromJson(q))
          .toList(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'languageId': languageId,
      'lessonNumber': lessonNumber,
      'questions': questions.map((q) => q.toJson()).toList(),
      'description': description,
    };
  }
}

class QuestionItem {
  final String id;
  final String question;
  final String questionType; // 'multiple_choice', 'fill_blank', 'code'
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  QuestionItem({
    required this.id,
    required this.question,
    required this.questionType,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    return QuestionItem(
      id: json['id'],
      question: json['question'],
      questionType: json['questionType'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'questionType': questionType,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}
