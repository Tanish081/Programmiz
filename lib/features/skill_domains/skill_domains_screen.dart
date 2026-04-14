import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_learn_app/data/local/skill_domains.dart';
import 'package:programming_learn_app/data/models/skill_domain_model.dart';

class SkillDomainsScreen extends StatelessWidget {
  const SkillDomainsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Career Roadmaps',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF58CC02), Color(0xFF46A302)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🚀 Where do you want to go?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white)),
                SizedBox(height: 8),
                Text(
                  'Choose a career path and get a personalised AI roadmap',
                  style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final domain in kSkillDomains)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SkillDomainCard(domain: domain),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillDomainCard extends StatelessWidget {
  const _SkillDomainCard({required this.domain});

  final SkillDomain domain;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: domain.primaryColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: domain.primaryColor.withValues(alpha: 0.2),
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 8, color: domain.primaryColor),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: domain.primaryColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Text(domain.emoji, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    domain.title,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _difficultyColor(domain.difficulty),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    domain.difficulty,
                                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              domain.description,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '⏱ ${domain.estimatedMonths}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: domain.coreSkills
                          .map(
                            (skill) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(skill, style: const TextStyle(fontSize: 11)),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('🛠 ${domain.tools.length} tools', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: domain.isAvailable
                            ? () => context.push('/skill-domain-roadmap/${domain.id}')
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: domain.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        child: const Text('View Roadmap →'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner-friendly':
        return const Color(0xFF58CC02);
      case 'advanced':
        return const Color(0xFFFF4B4B);
      default:
        return const Color(0xFFFF9600);
    }
  }
}
