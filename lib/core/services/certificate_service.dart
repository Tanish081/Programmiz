import 'dart:math';

import 'package:hive/hive.dart';
import 'package:programming_learn_app/core/utils/hive_boxes.dart';
import 'package:programming_learn_app/data/models/certificate_model.dart';
import 'package:programming_learn_app/data/models/interview_models.dart';
import 'package:programming_learn_app/data/models/roadmap_model.dart';
import 'package:programming_learn_app/data/models/user_profile_model.dart';
import 'package:programming_learn_app/data/repositories/progress_repository.dart';
import 'package:programming_learn_app/data/services/preferences_service.dart';

class CertificateService {
  CertificateService({
    ProgressRepository? progressRepository,
    PreferencesService? preferencesService,
  })  : _progressRepository = progressRepository ?? ProgressRepository(),
        _preferencesService = preferencesService ?? PreferencesService();

  final ProgressRepository _progressRepository;
  final PreferencesService _preferencesService;

  Future<List<CertificateModel>> checkAndIssueCertificates(UserProfile profile) async {
    final certBox = Hive.box<CertificateModel>(HiveBoxes.certificate);
    final progress = _progressRepository.getAllProgress();
    final existingTitles = certBox.values.map((cert) => cert.title).toSet();

    final completedLessons = progress.where((entry) => entry.isCompleted).toList();
    final avgScore = completedLessons.isEmpty
        ? 0
        : (completedLessons.map((entry) => entry.quizScore).reduce((a, b) => a + b) /
                completedLessons.length)
            .round();

    final challengesDone = await _preferencesService.getChallengesCompleted();

    final roadmapBox = Hive.box<RoadmapModel>(HiveBoxes.roadmap);
    final interviewBox = Hive.box<InterviewSession>(HiveBoxes.interview);

    final newCerts = <CertificateModel>[];

    void issueIfMissing({
      required String title,
      required String type,
      required String level,
      required int score,
      required List<String> skills,
      required bool condition,
    }) {
      if (!condition || existingTitles.contains(title)) {
        return;
      }

      final cert = CertificateModel(
        certificateId: 'cert_${DateTime.now().millisecondsSinceEpoch}_${newCerts.length}',
        type: type,
        title: title,
        recipientName: profile.name,
        issuedAt: DateTime.now(),
        level: level,
        score: score,
        verificationCode: _verificationCode(),
        skills: skills,
        issuerName: 'CodeQuest Academy',
        isPdfSaved: false,
      );

      newCerts.add(cert);
      existingTitles.add(title);
    }

    issueIfMissing(
      title: 'Python Fundamentals — Beginner',
      type: 'course',
      level: 'Beginner',
      score: avgScore,
      skills: const ['Python Basics', 'Variables', 'Conditions', 'Loops', 'Functions'],
      condition: completedLessons.length >= 5 && avgScore >= 70,
    );

    issueIfMissing(
      title: 'Python Developer — Intermediate',
      type: 'course',
      level: 'Intermediate',
      score: avgScore,
      skills: const ['OOP', 'File I/O', 'Modules', 'Error Handling', 'Data Structures'],
      condition: completedLessons.length >= 10 && avgScore >= 70,
    );

    issueIfMissing(
      title: 'Python Expert',
      type: 'course',
      level: 'Advanced',
      score: avgScore,
      skills: const ['Advanced Python', 'Optimization', 'Problem Solving'],
      condition: completedLessons.length >= 15 && challengesDone >= 5 && avgScore >= 80,
    );

    final fullStackRoadmap = roadmapBox.get('fullstack_roadmap');
    issueIfMissing(
      title: 'Full Stack Explorer',
      type: 'domain',
      level: 'Intermediate',
      score: 100,
      skills: const ['Frontend', 'Backend', 'Databases', 'Deployment'],
      condition: fullStackRoadmap != null &&
          fullStackRoadmap.phases.isNotEmpty &&
          fullStackRoadmap.phases.every((phase) => phase.isCompleted),
    );

    final dataAnalystRoadmap = roadmapBox.get('data_analyst_roadmap');
    issueIfMissing(
      title: 'Data Analyst Foundations',
      type: 'domain',
      level: 'Beginner',
      score: 100,
      skills: const ['SQL', 'Pandas', 'Visualization', 'Analytics'],
      condition: dataAnalystRoadmap != null &&
          dataAnalystRoadmap.phases.isNotEmpty &&
          dataAnalystRoadmap.phases.every((phase) => phase.isCompleted),
    );

    final completedSessions = interviewBox.values.where((session) => session.completedAt != null).toList();
    final interviewAvg = completedSessions.isEmpty
        ? 0
        : (completedSessions.map((session) => session.score).reduce((a, b) => a + b) /
                completedSessions.length)
            .round();

    issueIfMissing(
      title: 'Interview Ready — Python',
      type: 'interview',
      level: 'Intermediate',
      score: interviewAvg,
      skills: const ['Problem Solving', 'Communication', 'Technical Depth'],
      condition: completedSessions.length >= 3 && interviewAvg >= 70,
    );

    for (final cert in newCerts) {
      await certBox.put(cert.certificateId, cert);
    }

    return newCerts;
  }

  String _verificationCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
