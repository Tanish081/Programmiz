import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive/hive.dart';
import 'package:programming_learn_app/core/prompts/roadmap_prompts.dart';
import 'package:programming_learn_app/core/services/groq_service.dart';
import 'package:programming_learn_app/core/utils/hive_boxes.dart';
import 'package:programming_learn_app/data/local/skill_domains.dart';
import 'package:programming_learn_app/data/models/roadmap_model.dart';
import 'package:programming_learn_app/data/models/skill_domain_model.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';
import 'package:programming_learn_app/ui/components/duo_progress_bar.dart';

class SkillDomainRoadmapScreen extends StatefulWidget {
  const SkillDomainRoadmapScreen({super.key, required this.domainId});

  final String domainId;

  @override
  State<SkillDomainRoadmapScreen> createState() => _SkillDomainRoadmapScreenState();
}

class _SkillDomainRoadmapScreenState extends State<SkillDomainRoadmapScreen> {
  final GroqService _groqService = GroqService();

  bool _isLoading = true;
  String _streamingText = '';
  String? _error;
  RoadmapModel? _roadmap;
  Map<String, Map<String, dynamic>> _projectsByPhase = const {};
  final Map<String, String> _projectGuideCache = <String, String>{};

  SkillDomain get _domain =>
      kSkillDomains.firstWhere((domain) => domain.id == widget.domainId, orElse: () => kSkillDomains.first);

  @override
  void initState() {
    super.initState();
    _loadRoadmap();
  }

  Future<void> _loadRoadmap() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _streamingText = '';
    });

    final prompt = RoadmapPrompts.generateDomainRoadmap(
      domain: _domain,
      userLevel: 'beginner',
      dailyMinutes: 30,
      existingSkills: const <String>[],
    );

    final streamController = StreamController<String>();
    final streamSub = _groqService
        .streamComplete(
          prompt: 'In one sentence, tell the user you are preparing a roadmap for ${_domain.title}.',
          model: 'llama-3.1-8b-instant',
          maxTokens: 80,
        )
        .listen(
      (chunk) {
        _streamingText += chunk;
        if (mounted) {
          setState(() {});
        }
      },
      onError: (_) {},
      onDone: () {
        streamController.close();
      },
      cancelOnError: false,
    );

    try {
      final data = await _groqService.completeJson(
        prompt: prompt,
        model: 'llama-3.3-70b-versatile',
      );

      final parsed = _parseDomainRoadmap(data);
      if (!mounted) {
        return;
      }

      setState(() {
        _roadmap = parsed.roadmap;
        _projectsByPhase = parsed.projectsByPhase;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    } finally {
      await streamSub.cancel();
      await streamController.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _DomainRoadmapLoading(domain: _domain, streamingText: _streamingText);
    }

    if (_error != null || _roadmap == null) {
      return Scaffold(
        appBar: AppBar(title: Text(_domain.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error ?? 'Unable to generate roadmap right now.'),
                const SizedBox(height: 16),
                DuoButton(label: 'Try Again', onPressed: _loadRoadmap),
              ],
            ),
          ),
        ),
      );
    }

    final roadmap = _roadmap!;
    final totalTopics = roadmap.phases.fold<int>(0, (sum, phase) => sum + phase.topics.length);
    final completed = roadmap.phases.expand((phase) => phase.topics).where((topic) => topic.isCompleted).length;

    return Scaffold(
      appBar: AppBar(title: Text(_domain.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Hive.box<RoadmapModel>(HiveBoxes.roadmap).put('${_domain.id}_roadmap', roadmap);
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Roadmap saved to your profile! 📌')),
          );
        },
        icon: const Icon(Icons.push_pin_rounded),
        label: const Text('Save Roadmap'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_domain.primaryColor, _domain.primaryColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_domain.emoji} ${_domain.title}', style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(roadmap.aiSummary, style: const TextStyle(color: Colors.white, height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          DuoProgressBar(value: totalTopics == 0 ? 0 : completed / totalTopics, height: 12),
          const SizedBox(height: 6),
          Text('$completed/$totalTopics topics complete', style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 14),
          ...roadmap.phases.map((phase) {
            final project = _projectsByPhase[phase.phaseTitle];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${phase.emoji} ${phase.phaseTitle}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(phase.description),
                    const SizedBox(height: 8),
                    ...phase.topics.map((topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text('• ${topic.title} (${topic.difficulty})'),
                        )),
                    if (project != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🛠 Phase Project', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFF57C00))),
                            const SizedBox(height: 6),
                            Text(project['title']?.toString() ?? 'Project', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(project['description']?.toString() ?? ''),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => _openProjectGuide(phase.phaseTitle, project),
                              child: const Text('Start Project'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _openProjectGuide(String phaseTitle, Map<String, dynamic> project) async {
    var markdown = _projectGuideCache[phaseTitle];

    if (markdown == null) {
      final prompt = '''
Create a concise step-by-step guide in markdown for this project.
Title: ${project['title']}
Description: ${project['description']}
Keep it practical for beginners and include milestones.
''';

      try {
        markdown = await _groqService.complete(
          prompt: prompt,
          model: 'llama-3.1-8b-instant',
          maxTokens: 700,
        );
      } catch (_) {
        markdown = '## Project Guide\n\n1. Define scope\n2. Build MVP\n3. Test and improve\n4. Deploy and document.';
      }

      _projectGuideCache[phaseTitle] = markdown;
    }

    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(project['title']?.toString() ?? 'Project Guide', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Markdown(
                      controller: controller,
                      data: markdown ?? '',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _ParsedDomainRoadmap _parseDomainRoadmap(Map<String, dynamic> json) {
    final phasesJson = (json['phases'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    final phases = <RoadmapPhase>[];
    final projectsByPhase = <String, Map<String, dynamic>>{};

    for (var i = 0; i < phasesJson.length; i++) {
      final phaseJson = phasesJson[i];
      final topicsJson = (phaseJson['topics'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList();

      final phaseTitle = phaseJson['phaseTitle'] as String? ?? 'Phase ${i + 1}';

      final topics = <RoadmapTopic>[];
      for (var j = 0; j < topicsJson.length; j++) {
        final topicJson = topicsJson[j];
        topics.add(
          RoadmapTopic(
            topicId: topicJson['topicId'] as String? ?? 'topic_${i + 1}_${j + 1}',
            title: topicJson['title'] as String? ?? 'Topic ${j + 1}',
            description: topicJson['description'] as String? ?? '',
            difficulty: topicJson['difficulty'] as String? ?? 'easy',
            isCompleted: false,
            linkedLessonId: null,
            keyPoints: (topicJson['keyPoints'] as List<dynamic>? ?? const <dynamic>[])
                .map((entry) => entry.toString())
                .toList(),
            estimatedMinutes: (topicJson['estimatedMinutes'] as num?)?.toInt() ?? 30,
          ),
        );
      }

      phases.add(
        RoadmapPhase(
          phaseTitle: phaseTitle,
          description: phaseJson['description'] as String? ?? '',
          estimatedDays: (phaseJson['estimatedDays'] as num?)?.toInt() ?? 20,
          topics: topics,
          isCompleted: false,
          emoji: phaseJson['emoji'] as String? ?? '🚀',
        ),
      );

      final project = phaseJson['project'];
      if (project is Map<String, dynamic>) {
        projectsByPhase[phaseTitle] = project;
      }
    }

    return _ParsedDomainRoadmap(
      roadmap: RoadmapModel(
        id: '${_domain.id}_roadmap',
        language: _domain.id,
        userLevel: 'beginner',
        userGoal: _domain.title,
        learningStyle: 'project-based',
        phases: phases,
        generatedAt: DateTime.now(),
        estimatedDays: (json['estimatedDays'] as num?)?.toInt() ?? 120,
        aiSummary: json['aiSummary'] as String? ?? 'Your domain roadmap is ready.',
      ),
      projectsByPhase: projectsByPhase,
    );
  }
}

class _DomainRoadmapLoading extends StatelessWidget {
  const _DomainRoadmapLoading({required this.domain, required this.streamingText});

  final SkillDomain domain;
  final String streamingText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              domain.primaryColor.withValues(alpha: 0.15),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(domain.emoji, style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 14),
                Text(
                  '🤖 Generating your ${domain.title} roadmap...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'This takes about 10 seconds',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    streamingText.isEmpty ? 'Preparing AI roadmap...' : streamingText,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParsedDomainRoadmap {
  const _ParsedDomainRoadmap({required this.roadmap, required this.projectsByPhase});

  final RoadmapModel roadmap;
  final Map<String, Map<String, dynamic>> projectsByPhase;
}
