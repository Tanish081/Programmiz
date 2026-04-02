import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/data/repositories/lesson_repository.dart';
import 'package:programming_learn_app/data/repositories/progress_repository.dart';
import 'package:programming_learn_app/data/services/audio_service.dart';
import 'package:programming_learn_app/data/services/mascot_service.dart';
import 'package:programming_learn_app/data/services/preferences_service.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository();
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final mascotServiceProvider = Provider<MascotService>((ref) {
  return MascotService();
});
