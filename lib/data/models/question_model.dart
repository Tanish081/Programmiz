class QuestionModel {
  final String id;
  final String type; // mcq | fill_blank | arrange_code | fix_the_bug
  final String questionText;
  final String? codeSnippet;
  final List<String>? options;
  final List<String>? blanks;
  final String? buggyCode;
  final String? fixedCode;
  final String? bugDescription;
  final List<String>? bugOptions;
  final dynamic correctAnswer; // String or List<String>
  final String explanation;
  final int xpReward;

  const QuestionModel({
    required this.id,
    required this.type,
    required this.questionText,
    required this.codeSnippet,
    required this.options,
    required this.blanks,
    required this.buggyCode,
    required this.fixedCode,
    required this.bugDescription,
    required this.bugOptions,
    required this.correctAnswer,
    required this.explanation,
    this.xpReward = 0,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      questionText: json['questionText'] as String,
      codeSnippet: json['codeSnippet'] as String?,
      options: (json['options'] as List?)?.map((e) => e.toString()).toList(),
      blanks: (json['blanks'] as List?)?.map((e) => e.toString()).toList(),
      buggyCode: json['buggyCode'] as String?,
      fixedCode: json['fixedCode'] as String?,
      bugDescription: json['bugDescription'] as String?,
      bugOptions: (json['bugOptions'] as List?)?.map((e) => e.toString()).toList(),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'] as String,
      xpReward: json['xpReward'] != null ? (json['xpReward'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'questionText': questionText,
      'codeSnippet': codeSnippet,
      'options': options,
      'blanks': blanks,
      'buggyCode': buggyCode,
      'fixedCode': fixedCode,
      'bugDescription': bugDescription,
      'bugOptions': bugOptions,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'xpReward': xpReward,
    };
  }
}
