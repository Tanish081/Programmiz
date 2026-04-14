import 'package:programming_learn_app/data/models/roadmap_model.dart';
import 'package:programming_learn_app/data/models/skill_domain_model.dart';

class RoadmapPrompts {
  static String generateRoadmap({
    required String language,
    required String currentLevel,
    required String goal,
    required String learningStyle,
    required int dailyMinutes,
    required List<String> completedTopics,
  }) {
    final knownTopics = completedTopics.isEmpty ? 'none yet' : completedTopics.join(', ');

    return '''
You are an expert programming instructor creating a personalised learning roadmap.

Student profile:
- Language: $language
- Current level: $currentLevel
- Goal: $goal
- Learning style: $learningStyle
- Available daily: $dailyMinutes minutes
- Already knows: $knownTopics

Create a structured learning roadmap with exactly 4 phases.
Each phase has 3-5 topics.
Each topic has 3-5 key learning points.

Respond in this exact JSON format:
{
  "estimatedDays": 45,
  "aiSummary": "Based on your beginner level and goal...",
  "phases": [
    {
      "phaseTitle": "Phase 1: Foundations",
      "description": "...",
      "estimatedDays": 10,
      "emoji": "🌱",
      "topics": [
        {
          "topicId": "topic_001",
          "title": "Variables and Data Types",
          "description": "...",
          "difficulty": "easy",
          "estimatedMinutes": 20,
          "keyPoints": ["...", "...", "..."]
        }
      ]
    }
  ]
}
''';
  }

  static String regenerateWithFeedback({
    required RoadmapModel existing,
    required String userFeedback,
  }) {
    final currentRoadmapJson = existing.toJson();

    return '''
You are an expert programming instructor revising a student's roadmap.

Existing roadmap JSON:
$currentRoadmapJson

Student feedback:
$userFeedback

Revise the roadmap while preserving progress on completed topics and phases.
Keep the roadmap at exactly 4 phases and maintain realistic pacing.
Each phase should include 3-5 topics and each topic should include 3-5 key points.

Return ONLY valid JSON with this shape:
{
  "estimatedDays": 45,
  "aiSummary": "...",
  "phases": [
    {
      "phaseTitle": "Phase 1: ...",
      "description": "...",
      "estimatedDays": 10,
      "emoji": "🌱",
      "topics": [
        {
          "topicId": "topic_001",
          "title": "...",
          "description": "...",
          "difficulty": "easy",
          "estimatedMinutes": 20,
          "keyPoints": ["...", "...", "..."],
          "isCompleted": false,
          "linkedLessonId": null
        }
      ],
      "isCompleted": false
    }
  ]
}
''';
  }

  static String generateDomainRoadmap({
    required SkillDomain domain,
    required String userLevel,
    required int dailyMinutes,
    required List<String> existingSkills,
  }) {
    final knownSkills = existingSkills.isEmpty ? 'none yet' : existingSkills.join(', ');

    return '''
You are a senior tech career coach creating a personalised roadmap.

Career goal: ${domain.title}
User's current level: $userLevel
Daily learning time: $dailyMinutes minutes
Skills already known: $knownSkills

Create a 4-phase career roadmap to become job-ready in ${domain.title}.
Each phase has 4-6 topics with practical projects.

Include:
- Phase names with realistic timeframes
- Specific tools/technologies per phase
- 1 hands-on project per phase
- Key milestone to mark phase complete

Respond in this exact JSON:
{
  "estimatedDays": 120,
  "aiSummary": "...",
  "phases": [
    {
      "phaseTitle": "Phase 1: ...",
      "description": "...",
      "estimatedDays": 25,
      "emoji": "🌱",
      "project": {
        "title": "Build a ...",
        "description": "...",
        "difficulty": "easy"
      },
      "topics": [
        {
          "topicId": "topic_001",
          "title": "...",
          "description": "...",
          "difficulty": "easy",
          "estimatedMinutes": 20,
          "keyPoints": ["...", "...", "..."]
        }
      ]
    }
  ]
}
''';
  }
}
