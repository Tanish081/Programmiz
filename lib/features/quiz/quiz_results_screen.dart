import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/data/models/quiz_result_data.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';
import 'package:programming_learn_app/ui/components/mascot_widget.dart';
import 'package:programming_learn_app/data/services/mascot_service.dart';

class QuizResultsScreen extends StatelessWidget {
  final QuizResultData data;

  const QuizResultsScreen({
    super.key,
    required this.data,
  });

  Color _gradientStart() {
    if (data.scorePercentage >= 70) {
      return const Color(0xFF58CC02);
    } else if (data.scorePercentage >= 40) {
      return const Color(0xFFFF9600);
    }
    return const Color(0xFFFF4B4B);
  }

  Color _gradientEnd() {
    if (data.scorePercentage >= 70) {
      return const Color(0xFF46A302);
    } else if (data.scorePercentage >= 40) {
      return const Color(0xFFE07800);
    }
    return const Color(0xFFCC0000);
  }

  String _getEmoji() {
    if (data.scorePercentage >= 70) return '🎉';
    if (data.scorePercentage >= 40) return '💪';
    return '😅';
  }

  String _getPerformanceMessage() {
    if (data.scorePercentage >= 70) {
      return "Fantastic! You've mastered this lesson.";
    } else if (data.scorePercentage >= 40) {
      return "Good effort! Keep practicing.";
    }
    return "Keep learning! You'll get it.";
  }

  String _getPerformanceSubtitle() {
    if (data.scorePercentage >= 70) {
      return "You're ready for the next lesson!";
    } else if (data.scorePercentage >= 40) {
      return "Review the explanations below and try again.";
    }
    return "Don't worry — read through the lesson again first.";
  }

  String _getQuestionTypeShort(String type) {
    switch (type) {
      case 'mcq':
        return 'MCQ';
      case 'fill_blank':
        return 'Fill';
      case 'fix_bug':
        return 'Debug';
      default:
        return type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Result Card
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_gradientStart(), _gradientEnd()],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getEmoji(),
                        style: const TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${data.correctAnswers}/${data.totalQuestions}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.scorePercentage}% correct',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatPill('⚡ +${data.xpEarned} XP'),
                          const SizedBox(width: 8),
                          _StatPill('❤️ -${data.heartsLost}'),
                          const SizedBox(width: 8),
                          _StatPill('⏱ ${data.timeDisplay}'),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: _CurveClipper(),
                      child: Container(
                        height: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Performance Message Card
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
              ),
              child: Row(
                children: [
                  MascotWidget(
                    size: 56,
                    message: MascotMessage(
                      emoji: _getEmoji(),
                      message: _getPerformanceMessage(),
                      state: MascotState.encouraging,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getPerformanceMessage(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPerformanceSubtitle(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // XP Breakdown Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'XP EARNED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(data.questionResults.length, (index) {
                    final q = data.questionResults[index];
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${q.wasCorrect ? "✅" : "❌"} ${_getQuestionTypeShort(q.type)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '+${q.xpAwarded} XP',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF58CC02),
                              ),
                            ),
                          ],
                        ),
                        if (index < data.questionResults.length - 1)
                          Divider(
                            height: 12,
                            thickness: 0.5,
                            color: Colors.grey[200],
                          ),
                      ],
                    );
                  }),
                  Divider(
                    height: 16,
                    thickness: 1,
                    color: Colors.grey[300],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FFF0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '+${data.xpEarned} XP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF58CC02),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Question Review Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'QUESTION REVIEW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: List.generate(data.questionResults.length, (index) {
                  final q = data.questionResults[index];
                  final questionNum = index + 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(
                          color: q.wasCorrect
                              ? const Color(0xFF58CC02)
                              : const Color(0xFFFF4B4B),
                          width: 4,
                        ),
                        top: const BorderSide(
                            color: const Color(0xFFE5E5E5), width: 1),
                        right: const BorderSide(
                            color: const Color(0xFFE5E5E5), width: 1),
                        bottom: const BorderSide(
                            color: const Color(0xFFE5E5E5), width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: q.wasCorrect
                                        ? const Color(0xFFD7FFB8)
                                        : const Color(0xFFFFEBEB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Q$questionNum',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: q.wasCorrect
                                          ? const Color(0xFF58CC02)
                                          : const Color(0xFFFF4B4B),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getQuestionTypeShort(q.type),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              q.wasCorrect ? '✅' : '❌',
                              style: const TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q.questionText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        if (q.codeSnippet != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              q.codeSnippet!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (!q.wasCorrect) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Your answer: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4B4B),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    q.userAnswer,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7FFB8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Correct answer: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF58CC02),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    q.correctAnswer,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7FFB8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Your answer: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF58CC02),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    q.correctAnswer,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💡 ', style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(
                                  q.explanation,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: const Color(0xFFE5E5E5), width: 1),
                ),
              ),
              child: Column(
                children: [
                  DuoButton(
                    label: data.isPassed ? 'Continue →' : 'Try Again',
                    onPressed: () {
                      if (data.isPassed) {
                        context.go('/home');
                      } else {
                        context.go('/quiz/${data.lessonId}');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.go('/lesson/${data.lessonId}');
                    },
                    child: const Text(
                      'Review Lesson',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;

  const _StatPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, 30, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
