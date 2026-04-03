class LessonSlide {
  const LessonSlide({
    required this.type,
    required this.title,
    required this.body,
    this.emoji,
    this.codeSnippet,
    this.codeOutput,
    this.analogyText,
    this.mistakeCode,
    this.correctedCode,
    this.tryItPrompt,
    this.tryItOptions,
    this.tryItAnswer,
  });

  final String type;
  final String title;
  final String body;
  final String? emoji;
  final String? codeSnippet;
  final String? codeOutput;
  final String? analogyText;
  final String? mistakeCode;
  final String? correctedCode;
  final String? tryItPrompt;
  final List<String>? tryItOptions;
  final String? tryItAnswer;

  factory LessonSlide.fromJson(Map<String, dynamic> json) {
    return LessonSlide(
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      emoji: json['emoji'] as String?,
      codeSnippet: json['codeSnippet'] as String?,
      codeOutput: json['codeOutput'] as String?,
      analogyText: json['analogyText'] as String?,
      mistakeCode: json['mistakeCode'] as String?,
      correctedCode: json['correctedCode'] as String?,
      tryItPrompt: json['tryItPrompt'] as String?,
      tryItOptions: (json['tryItOptions'] as List?)?.map((e) => e.toString()).toList(),
      tryItAnswer: json['tryItAnswer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'emoji': emoji,
      'codeSnippet': codeSnippet,
      'codeOutput': codeOutput,
      'analogyText': analogyText,
      'mistakeCode': mistakeCode,
      'correctedCode': correctedCode,
      'tryItPrompt': tryItPrompt,
      'tryItOptions': tryItOptions,
      'tryItAnswer': tryItAnswer,
    };
  }
}
