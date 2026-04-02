import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:programming_learn_app/data/models/lesson_model.dart';

class AssetLoaderService {
  const AssetLoaderService();

  Future<List<LessonModel>> loadLessonsFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final level = decoded['level'] as String;
    final lessons = decoded['lessons'] as List<dynamic>;

    return lessons
        .map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          map['level'] ??= level;
          return LessonModel.fromJson(map);
        })
        .toList();
  }
}
