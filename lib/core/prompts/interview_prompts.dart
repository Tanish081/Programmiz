class InterviewPrompts {
  static String generateInterviewQuestions({
    required String topic,
    required String difficulty,
    required String type,
    required int count,
    required String userLevel,
  }) {
    return '''
You are a senior technical interviewer at a top tech company.
Generate $count interview questions for:
Topic: $topic
Difficulty: $difficulty
Type: $type
Candidate level: $userLevel

Mix question types: 40% conceptual, 40% MCQ, 20% code review.

For MCQ: provide 4 options and correct answer.
For open_ended: provide a detailed sample answer.
For code_review: show buggy/incomplete code, ask candidate to fix/explain.

Respond ONLY in this JSON format:
{
  "questions": [
    {
      "questionId": "q001",
      "questionText": "...",
      "type": "mcq",
      "difficulty": "medium",
      "options": ["A", "B", "C", "D"],
      "correctAnswer": "B",
      "sampleAnswer": null
    },
    {
      "questionId": "q002",
      "questionText": "Explain how Python handles memory management.",
      "type": "open_ended",
      "difficulty": "medium",
      "options": null,
      "correctAnswer": null,
      "sampleAnswer": "Python uses automatic memory management through..."
    }
  ]
}
''';
  }

  static String evaluateAnswer({
    required String question,
    required String userAnswer,
    required String? sampleAnswer,
  }) {
    return '''
You are evaluating a technical interview answer.

Question:
$question

Candidate answer:
$userAnswer

Reference answer (if provided):
${sampleAnswer ?? 'No reference answer available'}

Score the answer from 0 to 10 and provide specific, actionable feedback.

Respond ONLY as JSON:
{
  "score": 7,
  "feedback": "...",
  "strengths": ["...", "..."],
  "improvements": ["...", "..."]
}
''';
  }
}
