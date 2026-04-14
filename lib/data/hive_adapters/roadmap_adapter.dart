import 'package:hive/hive.dart';
import 'package:programming_learn_app/data/models/roadmap_model.dart';

class RoadmapModelAdapter extends TypeAdapter<RoadmapModel> {
  @override
  final int typeId = 1;

  @override
  RoadmapModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return RoadmapModel(
      id: fields[0] as String,
      language: fields[1] as String,
      userLevel: fields[2] as String,
      userGoal: fields[3] as String,
      learningStyle: fields[4] as String,
      phases: (fields[5] as List).cast<RoadmapPhase>(),
      generatedAt: fields[6] as DateTime,
      estimatedDays: fields[7] as int,
      aiSummary: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RoadmapModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.language)
      ..writeByte(2)
      ..write(obj.userLevel)
      ..writeByte(3)
      ..write(obj.userGoal)
      ..writeByte(4)
      ..write(obj.learningStyle)
      ..writeByte(5)
      ..write(obj.phases)
      ..writeByte(6)
      ..write(obj.generatedAt)
      ..writeByte(7)
      ..write(obj.estimatedDays)
      ..writeByte(8)
      ..write(obj.aiSummary);
  }
}

class RoadmapPhaseAdapter extends TypeAdapter<RoadmapPhase> {
  @override
  final int typeId = 2;

  @override
  RoadmapPhase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return RoadmapPhase(
      phaseTitle: fields[0] as String,
      description: fields[1] as String,
      estimatedDays: fields[2] as int,
      topics: (fields[3] as List).cast<RoadmapTopic>(),
      isCompleted: fields[4] as bool,
      emoji: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RoadmapPhase obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.phaseTitle)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.estimatedDays)
      ..writeByte(3)
      ..write(obj.topics)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.emoji);
  }
}

class RoadmapTopicAdapter extends TypeAdapter<RoadmapTopic> {
  @override
  final int typeId = 3;

  @override
  RoadmapTopic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return RoadmapTopic(
      topicId: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      difficulty: fields[3] as String,
      isCompleted: fields[4] as bool,
      linkedLessonId: fields[5] as String?,
      keyPoints: (fields[6] as List).cast<String>(),
      estimatedMinutes: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RoadmapTopic obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.topicId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.linkedLessonId)
      ..writeByte(6)
      ..write(obj.keyPoints)
      ..writeByte(7)
      ..write(obj.estimatedMinutes);
  }
}
