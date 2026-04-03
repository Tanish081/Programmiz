class QuestionResultDetail {
  final String questionText;
  final String? codeSnippet;
  final String type;
  final String userAnswer;
  final String correctAnswer;
  final String explanation;
  final bool wasCorrect;
  final int xpAwarded;

  QuestionResultDetail({
    required this.questionText,
    this.codeSnippet,
    required this.type,
    required this.userAnswer,
    required this.correctAnswer,
    required this.explanation,
    required this.wasCorrect,
    required this.xpAwarded,
  });
}

class QuizResultData {
  final String lessonId;
  final String lessonTitle;
  final String topicTag;
  final int totalQuestions;
  final int correctAnswers;
  final int xpEarned;
  final int heartsLost;
  final List<QuestionResultDetail> questionResults;
  final int timeTakenSeconds;

  QuizResultData({
    required this.lessonId,
    required this.lessonTitle,
    required this.topicTag,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.xpEarned,
    required this.heartsLost,
    required this.questionResults,
    this.timeTakenSeconds = 0,
  });

  int get scorePercentage {
    if (totalQuestions == 0) return 0;
    return ((correctAnswers / totalQuestions) * 100).toInt();
  }

  bool get isPassed => scorePercentage >= 70;
  bool get isMedium => scorePercentage >= 40 && scorePercentage < 70;
  bool get isLow => scorePercentage < 40;

  String get timeDisplay {
    final minutes = timeTakenSeconds ~/ 60;
    final seconds = timeTakenSeconds % 60;
    if (minutes == 0) {
      return '${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }
}
