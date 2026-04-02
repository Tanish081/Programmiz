import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LanguageOverviewScreen extends StatelessWidget {
  const LanguageOverviewScreen({
    super.key,
    required this.languageId,
  });

  final String languageId;

  static const Map<String, ({String name, String icon, String subtitle, bool available})> _catalog = {
    'python': (
      name: 'Python',
      icon: '🐍',
      subtitle: 'Start with syntax, conditions, loops and mini projects.',
      available: true,
    ),
    'javascript': (
      name: 'JavaScript',
      icon: '🟨',
      subtitle: 'Web scripting basics, DOM and async programming.',
      available: false,
    ),
    'java': (
      name: 'Java',
      icon: '☕',
      subtitle: 'OOP fundamentals and backend-oriented patterns.',
      available: false,
    ),
    'cpp': (
      name: 'C++',
      icon: '⚙️',
      subtitle: 'Memory control, performance and systems concepts.',
      available: false,
    ),
    'go': (
      name: 'Go',
      icon: '🐹',
      subtitle: 'Concurrency-first language for modern backend work.',
      available: false,
    ),
    'rust': (
      name: 'Rust',
      icon: '🦀',
      subtitle: 'Safety + speed with ownership and modern tooling.',
      available: false,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final language = _catalog[languageId] ?? _catalog['python']!;

    return Scaffold(
      appBar: AppBar(title: Text('${language.name} Learning Path')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade500, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(language.icon, style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          language.subtitle,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'What to learn today',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _topicTile('Basics and syntax', Icons.auto_awesome, language.available),
                  _topicTile('Conditions and loops', Icons.loop, language.available),
                  _topicTile('Functions and modules', Icons.extension_outlined, language.available),
                  _topicTile('Build a mini project', Icons.build_outlined, language.available),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: language.available ? () => context.go('/home') : null,
                child: Text(language.available ? 'Start ${language.name}' : 'Coming Soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topicTile(String title, IconData icon, bool available) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: available ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: available ? Colors.blue.shade200 : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: available ? Colors.blue.shade700 : Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: available ? Colors.blue.shade900 : Colors.grey.shade700,
              ),
            ),
          ),
          if (!available)
            const Text('Soon', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
