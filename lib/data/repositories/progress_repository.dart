import 'package:hive/hive.dart';
import 'package:programming_learn_app/core/utils/hive_boxes.dart';
import 'package:programming_learn_app/data/models/user_progress_model.dart';

class ProgressRepository {
  final Box<UserProgressModel> _box = Hive.box<UserProgressModel>(HiveBoxes.userProgress);

  Future<void> saveProgress(UserProgressModel progress) async {
    await _box.put(progress.lessonId, progress);
  }

  UserProgressModel? getProgress(String lessonId) {
    return _box.get(lessonId);
  }

  List<UserProgressModel> getAllProgress() {
    return _box.values.toList();
  }

  bool isLessonCompleted(String lessonId) {
    return getProgress(lessonId)?.isCompleted ?? false;
  }
}
