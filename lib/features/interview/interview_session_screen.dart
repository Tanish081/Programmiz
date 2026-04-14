import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive/hive.dart';
import 'package:programming_learn_app/core/prompts/interview_prompts.dart';
import 'package:programming_learn_app/core/services/groq_service.dart';
import 'package:programming_learn_app/core/utils/hive_boxes.dart';
import 'package:programming_learn_app/data/models/interview_models.dart';
import 'package:programming_learn_app/data/services/preferences_service.dart';
import 'package:shimmer/shimmer.dart';

class InterviewSessionScreen extends StatefulWidget {
  const InterviewSessionScreen({
    super.key,
    required this.topic,
    required this.difficulty,
    required this.type,
    required this.count,
  });

  final String topic;
  final String difficulty;
  final String type;
  final int count;

  @override
  State<InterviewSessionScreen> createState() => _InterviewSessionScreenState();
}

class _InterviewSessionScreenState extends State<InterviewSessionScreen> {
  final GroqService _groqService = GroqService();
  final PreferencesService _preferences = PreferencesService();
  final TextEditingController _answerController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  int _index = 0;
  DateTime _startedAt = DateTime.now();
  List<InterviewQuestion> _questions = const [];
  final List<InterviewQuestion> _answered = <InterviewQuestion>[];
  String? _hint;
  String? _feedback;
  int? _feedbackScore;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prompt = InterviewPrompts.generateInterviewQuestions(
        topic: widget.topic,
        difficulty: widget.difficulty,
        type: widget.type,
        count: widget.count,
        userLevel: 'beginner',
      );

      final json = await _groqService.completeJson(
        prompt: prompt,
        model: 'llama-3.3-70b-versatile',
        maxTokens: 2300,
      );

      final questionsJson = (json['questions'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList();

      final parsed = <InterviewQuestion>[];
      for (var i = 0; i < questionsJson.length; i++) {
        final item = questionsJson[i];
        parsed.add(
          InterviewQuestion(
            questionId: item['questionId'] as String? ?? 'q${i + 1}',
            questionText: item['questionText'] as String? ?? 'Question ${i + 1}',
            type: item['type'] as String? ?? 'open_ended',
            difficulty: item['difficulty'] as String? ?? widget.difficulty,
            options: (item['options'] as List<dynamic>?)?.map((entry) => entry.toString()).toList(),
            correctAnswer: item['correctAnswer'] as String?,
            sampleAnswer: item['sampleAnswer'] as String?,
            userAnswer: '',
            aiFeedback: null,
            scoreAwarded: null,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _questions = parsed;
        _isLoading = false;
        _startedAt = DateTime.now();
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _questions = _fallbackQuestions();
        _isLoading = false;
        _startedAt = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E2E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Preparing your interview...', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'Generating ${widget.count} questions with Llama AI 🤖',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Shimmer.fromColors(
                  baseColor: Colors.white12,
                  highlightColor: Colors.white24,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_index >= _questions.length) {
      return _buildCompleteScreen();
    }

    final current = _questions[_index];
    final elapsed = DateTime.now().difference(_startedAt).inSeconds;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF1E1E2E),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Text('Question ${_index + 1}/${_questions.length}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  const Spacer(),
                  Text('⏱ ${elapsed}s', style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: List.generate(
                  _questions.length,
                  (dotIndex) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotIndex <= _index ? const Color(0xFF58CC02) : Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(_typeLabel(current.type), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 14),
                    Text(current.questionText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.5)),
                    const SizedBox(height: 14),
                    if (current.type == 'mcq' && current.options != null) ...[
                      ...current.options!.map((option) => RadioListTile<String>(
                            value: option,
                            groupValue: _answerController.text,
                            onChanged: (value) {
                              setState(() {
                                _answerController.text = value ?? '';
                              });
                            },
                            title: Text(option),
                          )),
                    ] else ...[
                      TextField(
                        controller: _answerController,
                        minLines: 6,
                        maxLines: 8,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          hintText: 'Type your answer here... (aim for 2-3 sentences)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final hint = await _groqService.complete(
                              prompt: 'Give a concise hint for this interview question: ${current.questionText}',
                              model: 'llama-3.1-8b-instant',
                              maxTokens: 140,
                              temperature: 0.6,
                            );
                            if (!mounted) return;
                            setState(() {
                              _hint = hint;
                            });
                          },
                          child: const Text('💡 Hint'),
                        ),
                      ),
                      if (_hint != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_hint!),
                        ),
                    ],
                    if (_feedback != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MarkdownBody(
                          data: _feedbackScore == null
                              ? _feedback!
                              : '### Score: ${_feedbackScore!}/10\n\n$_feedback',
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  _recordAnswer(current, '');
                                  _goNext();
                                },
                          child: const Text('Skip'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : () => _submit(current),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF58CC02),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Submit Answer →', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(InterviewQuestion current) async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _feedback = null;
      _feedbackScore = null;
    });

    if (current.type == 'mcq') {
      final correct = current.correctAnswer?.trim().toLowerCase() == answer.trim().toLowerCase();

      _recordAnswer(
        current,
        answer,
        aiFeedback: correct ? 'Correct answer.' : 'Incorrect. Review and retry this topic.',
        scoreAwarded: correct ? 10 : 0,
      );

      setState(() {
        _feedback = correct ? '✅ Correct!' : '❌ Not quite right.';
        _feedbackScore = correct ? 10 : 0;
        _isSubmitting = false;
      });

      await Future<void>.delayed(const Duration(milliseconds: 500));
      _goNext();
      return;
    }

    try {
      final evalPrompt = InterviewPrompts.evaluateAnswer(
        question: current.questionText,
        userAnswer: answer,
        sampleAnswer: current.sampleAnswer,
      );

      final eval = await _groqService.completeJson(
        prompt: evalPrompt,
        model: 'llama-3.3-70b-versatile',
        maxTokens: 500,
      );

      final score = (eval['score'] as num?)?.toInt() ?? 0;
      final feedback = eval['feedback']?.toString() ?? 'No feedback.';

      _recordAnswer(current, answer, aiFeedback: feedback, scoreAwarded: score);

      if (!mounted) {
        return;
      }

      setState(() {
        _feedback = feedback;
        _feedbackScore = score;
        _isSubmitting = false;
      });

      await Future<void>.delayed(const Duration(milliseconds: 700));
      _goNext();
    } catch (_) {
      _recordAnswer(current, answer, aiFeedback: 'Answer submitted.', scoreAwarded: 5);
      setState(() {
        _feedback = 'Answer submitted.';
        _feedbackScore = 5;
        _isSubmitting = false;
      });
      _goNext();
    }
  }

  void _recordAnswer(
    InterviewQuestion current,
    String answer, {
    String? aiFeedback,
    int? scoreAwarded,
  }) {
    final updated = current.copyWith(
      userAnswer: answer,
      aiFeedback: aiFeedback,
      scoreAwarded: scoreAwarded,
    );

    if (_index < _questions.length) {
      _questions[_index] = updated;
    }
    _answered.add(updated);
  }

  void _goNext() {
    setState(() {
      _index += 1;
      _answerController.clear();
      _hint = null;
      _feedback = null;
      _feedbackScore = null;
      _isSubmitting = false;
    });
  }

  Widget _buildCompleteScreen() {
    final total = _answered.length;
    final scored = _answered.where((q) => (q.scoreAwarded ?? 0) > 0).length;
    final totalScore = _answered.fold<int>(0, (sum, q) => sum + (q.scoreAwarded ?? 0));
    final maxScore = total == 0 ? 1 : total * 10;
    final percentage = ((totalScore / maxScore) * 100).round();

    final strengths = _answered.where((q) => (q.scoreAwarded ?? 0) >= 7).map((q) => q.questionText).take(3).toList();
    final improvements = _answered.where((q) => (q.scoreAwarded ?? 0) < 7).map((q) => q.questionText).take(3).toList();

    final session = InterviewSession(
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      topic: widget.topic,
      difficulty: widget.difficulty,
      type: widget.type,
      questions: _answered,
      startedAt: _startedAt,
      completedAt: DateTime.now(),
      score: percentage,
      aiFeedback: 'Keep practicing and focus on weaker areas for consistency.',
    );

    _saveSession(session, scored);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF58CC02), width: 10),
                ),
                alignment: Alignment.center,
                child: Text('$percentage%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text('$scored/$total correct', style: TextStyle(color: Colors.grey.shade700)),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(16)),
              child: const MarkdownBody(data: '### 🤖 AI Feedback\n\nKeep practicing and focus on weaker areas for consistency.'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _feedbackCard('✅ Strengths', strengths, const Color(0xFFD7FFB8)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _feedbackCard('⚠️ To Improve', improvements, const Color(0xFFFFEDCC)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _index = 0;
                  _answered.clear();
                  _isLoading = true;
                });
                _loadQuestions();
              },
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                foregroundColor: Colors.white,
              ),
              child: const Text('New Session →'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSession(InterviewSession session, int correctAnswers) async {
    try {
      final box = Hive.box<InterviewSession>(HiveBoxes.interview);
      await box.put(session.sessionId, session);
    } catch (_) {}

    final xp = (correctAnswers * 5) + 20;
    await _preferences.addXP(xp);
  }

  Widget _feedbackCard(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...items.map((item) => Text('• $item', style: const TextStyle(fontSize: 12))),
          if (items.isEmpty) const Text('• Keep practicing', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'mcq':
        return '💬 Conceptual';
      case 'code_review':
        return '🔍 Code Review';
      default:
        return '💻 Technical';
    }
  }

  List<InterviewQuestion> _fallbackQuestions() {
    return List.generate(
      widget.count,
      (index) => InterviewQuestion(
        questionId: 'fallback_$index',
        questionText: 'Explain one important concept about ${widget.topic}.',
        type: index.isEven ? 'open_ended' : 'mcq',
        options: index.isEven ? null : const ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: index.isEven ? null : 'Option B',
        sampleAnswer: 'A strong answer defines the concept and gives a practical example.',
        userAnswer: '',
        aiFeedback: null,
        scoreAwarded: null,
        difficulty: widget.difficulty,
      ),
    );
  }
}
