import 'package:programming_learn_app/data/models/lesson_model.dart';
import 'package:programming_learn_app/data/services/asset_loader_service.dart';

class LessonRepository {
  LessonRepository({AssetLoaderService? loader}) : _loader = loader ?? const AssetLoaderService();

  final AssetLoaderService _loader;

  static const String _absoluteBeginnerPath = 'assets/curriculum/python_absolute_beginner.json';
  static const String _beginnerPath = 'assets/curriculum/python_beginner.json';
  static const String _intermediatePath = 'assets/curriculum/python_intermediate.json';

  List<LessonModel>? _cache;

  Future<List<LessonModel>> getAllLessons() async {
    if (_cache != null) {
      return _cache!;
    }

    final absoluteBeginner = await _loader.loadLessonsFromAsset(_absoluteBeginnerPath);
    final beginner = await _loader.loadLessonsFromAsset(_beginnerPath);
    final intermediate = await _loader.loadLessonsFromAsset(_intermediatePath);

    _cache = [...absoluteBeginner, ...beginner, ...intermediate];
    return _cache!;
  }

  Future<List<LessonModel>> getLessonsByLevel(String level) async {
    final all = await getAllLessons();
    return all.where((lesson) => lesson.level == level).toList();
  }

  Future<LessonModel?> getLessonById(String lessonId) async {
    final all = await getAllLessons();
    for (final lesson in all) {
      if (lesson.id == lessonId) {
        return lesson;
      }
    }
    return null;
  }
}
