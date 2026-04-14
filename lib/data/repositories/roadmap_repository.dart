import 'package:hive/hive.dart';
import 'package:programming_learn_app/core/prompts/roadmap_prompts.dart';
import 'package:programming_learn_app/core/services/groq_service.dart';
import 'package:programming_learn_app/core/utils/hive_boxes.dart';
import 'package:programming_learn_app/data/models/lesson_model.dart';
import 'package:programming_learn_app/data/models/roadmap_model.dart';
import 'package:programming_learn_app/data/models/user_profile_model.dart';
import 'package:programming_learn_app/data/repositories/lesson_repository.dart';
import 'package:programming_learn_app/data/repositories/progress_repository.dart';

class RoadmapRepository {
  RoadmapRepository({
    GroqService? groqService,
    LessonRepository? lessonRepository,
    ProgressRepository? progressRepository,
  })  : _groqService = groqService ?? GroqService(),
        _lessonRepository = lessonRepository ?? LessonRepository(),
        _progressRepository = progressRepository ?? ProgressRepository();

  final GroqService _groqService;
  final LessonRepository _lessonRepository;
  final ProgressRepository _progressRepository;

  Box<RoadmapModel> get _roadmapBox => Hive.box<RoadmapModel>(HiveBoxes.roadmap);

  Future<RoadmapModel?> getCachedRoadmap(String language) async {
    return _roadmapBox.get('${language.toLowerCase()}_roadmap');
  }

  Future<RoadmapModel> generateRoadmap({
    required String language,
    required UserProfile profile,
    bool forceRegenerate = false,
  }) async {
    final roadmapId = '${language.toLowerCase()}_roadmap';
    final existing = _roadmapBox.get(roadmapId);
    if (existing != null && !forceRegenerate) {
      return existing;
    }

    final lessons = await _lessonRepository.getAllLessons();
    final completedTopics = _extractCompletedTopics(lessons);

    final prompt = RoadmapPrompts.generateRoadmap(
      language: language,
      currentLevel: profile.experienceLevel,
      goal: 'job_ready',
      learningStyle: profile.preferredTime,
      dailyMinutes: _estimateDailyMinutes(profile),
      completedTopics: completedTopics,
    );

    final json = await _groqService.completeJson(
      prompt: prompt,
      model: 'llama-3.3-70b-versatile',
    );

    final roadmap = _buildRoadmapFromJson(
      id: roadmapId,
      language: language,
      profile: profile,
      json: json,
      lessons: lessons,
    );

    await _roadmapBox.put(roadmapId, roadmap);
    return roadmap;
  }

  Future<void> markTopicComplete(String roadmapId, String topicId) async {
    final roadmap = _roadmapBox.get(roadmapId);
    if (roadmap == null) {
      return;
    }

    final updatedPhases = roadmap.phases
        .map((phase) {
          final updatedTopics = phase.topics
              .map((topic) => topic.topicId == topicId ? topic.copyWith(isCompleted: true) : topic)
              .toList();

          final phaseDone =
              updatedTopics.isNotEmpty && updatedTopics.every((topic) => topic.isCompleted);

          return phase.copyWith(topics: updatedTopics, isCompleted: phaseDone);
        })
        .toList();

    final updated = roadmap.copyWith(phases: updatedPhases);
    await _roadmapBox.put(roadmapId, updated);
  }

  Future<void> markPhaseComplete(String roadmapId, String phaseTitle) async {
    final roadmap = _roadmapBox.get(roadmapId);
    if (roadmap == null) {
      return;
    }

    final updatedPhases = roadmap.phases
        .map((phase) {
          if (phase.phaseTitle != phaseTitle) {
            return phase;
          }

          final updatedTopics = phase.topics
              .map((topic) => topic.copyWith(isCompleted: true))
              .toList();

          return phase.copyWith(topics: updatedTopics, isCompleted: true);
        })
        .toList();

    final updated = roadmap.copyWith(phases: updatedPhases);
    await _roadmapBox.put(roadmapId, updated);
  }

  RoadmapModel? updateRoadmapProgress(RoadmapModel roadmap) {
    final updatedPhases = roadmap.phases
        .map(
          (phase) => phase.copyWith(
            isCompleted: phase.topics.isNotEmpty && phase.topics.every((topic) => topic.isCompleted),
          ),
        )
        .toList();

    final updated = roadmap.copyWith(phases: updatedPhases);
    _roadmapBox.put(roadmap.id, updated);
    return updated;
  }

  List<String> _extractCompletedTopics(List<LessonModel> lessons) {
    final completedLessonIds = _progressRepository
        .getAllProgress()
        .where((progress) => progress.isCompleted)
        .map((progress) => progress.lessonId)
        .toSet();

    return lessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .map((lesson) => lesson.title)
        .toList();
  }

  int _estimateDailyMinutes(UserProfile profile) {
    final baseline = profile.dailyGoalXP * 2;
    if (baseline < 10) {
      return 10;
    }
    if (baseline > 180) {
      return 180;
    }
    return baseline;
  }

  RoadmapModel _buildRoadmapFromJson({
    required String id,
    required String language,
    required UserProfile profile,
    required Map<String, dynamic> json,
    required List<LessonModel> lessons,
  }) {
    final phasesJson = (json['phases'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    final phases = <RoadmapPhase>[];
    for (int phaseIndex = 0; phaseIndex < phasesJson.length; phaseIndex++) {
      final phaseJson = phasesJson[phaseIndex];
      final topicsJson = (phaseJson['topics'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList();

      final topics = <RoadmapTopic>[];
      for (int topicIndex = 0; topicIndex < topicsJson.length; topicIndex++) {
        final topicJson = topicsJson[topicIndex];
        final linkedLessonId = _matchLessonIdByTitle(
          lessons: lessons,
          topicTitle: topicJson['title'] as String? ?? '',
        );

        final keyPoints = (topicJson['keyPoints'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => item.toString())
            .toList();

        topics.add(
          RoadmapTopic(
            topicId: topicJson['topicId'] as String? ?? 'topic_${phaseIndex + 1}_${topicIndex + 1}',
            title: topicJson['title'] as String? ?? 'Untitled Topic',
            description: topicJson['description'] as String? ?? '',
            difficulty: (topicJson['difficulty'] as String? ?? 'easy').toLowerCase(),
            isCompleted: false,
            linkedLessonId: linkedLessonId,
            keyPoints: keyPoints,
            estimatedMinutes: (topicJson['estimatedMinutes'] as num?)?.toInt() ?? 20,
          ),
        );
      }

      phases.add(
        RoadmapPhase(
          phaseTitle: phaseJson['phaseTitle'] as String? ?? 'Phase ${phaseIndex + 1}',
          description: phaseJson['description'] as String? ?? '',
          estimatedDays: (phaseJson['estimatedDays'] as num?)?.toInt() ?? 7,
          topics: topics,
          isCompleted: false,
          emoji: phaseJson['emoji'] as String? ?? '📘',
        ),
      );
    }

    return RoadmapModel(
      id: id,
      language: language.toLowerCase(),
      userLevel: profile.experienceLevel,
      userGoal: 'job_ready',
      learningStyle: profile.preferredTime,
      phases: phases,
      generatedAt: DateTime.now(),
      estimatedDays: (json['estimatedDays'] as num?)?.toInt() ?? 45,
      aiSummary: json['aiSummary'] as String? ?? 'Your personalised roadmap is ready.',
    );
  }

  String? _matchLessonIdByTitle({
    required List<LessonModel> lessons,
    required String topicTitle,
  }) {
    if (topicTitle.trim().isEmpty) {
      return null;
    }

    final normalizedTopic = _normalize(topicTitle);

    for (final lesson in lessons) {
      if (_normalize(lesson.title) == normalizedTopic) {
        return lesson.id;
      }
    }

    for (final lesson in lessons) {
      if (_normalize(lesson.title).contains(normalizedTopic) ||
          normalizedTopic.contains(_normalize(lesson.title))) {
        return lesson.id;
      }
    }

    return null;
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }
}
