import 'package:hive/hive.dart';
import 'package:programming_learn_app/data/models/user_progress_model.dart';

class UserProgressModelAdapter extends TypeAdapter<UserProgressModel> {
  @override
  final int typeId = 0;

  @override
  UserProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return UserProgressModel(
      lessonId: fields[0] as String,
      quizScore: fields[1] as int,
      isCompleted: fields[2] as bool,
      attemptCount: fields[3] as int,
      completedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgressModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.quizScore)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.attemptCount)
      ..writeByte(4)
      ..write(obj.completedAt);
  }
}
