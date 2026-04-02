import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/data/models/lesson_model.dart';

final lessonProvider = FutureProvider.family<LessonModel?, String>((ref, lessonId) {
  return ref.read(lessonRepositoryProvider).getLessonById(lessonId);
});
