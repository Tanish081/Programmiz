import 'package:flutter/material.dart';

class SkillDomain {
  const SkillDomain({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.difficulty,
    required this.coreSkills,
    required this.tools,
    required this.estimatedMonths,
    required this.primaryColor,
    required this.isAvailable,
  });

  final String id;
  final String title;
  final String emoji;
  final String description;
  final String difficulty;
  final List<String> coreSkills;
  final List<String> tools;
  final String estimatedMonths;
  final Color primaryColor;
  final bool isAvailable;
}
