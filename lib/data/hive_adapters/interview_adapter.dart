import 'package:hive/hive.dart';
import 'package:programming_learn_app/data/models/interview_models.dart';

class InterviewSessionAdapter extends TypeAdapter<InterviewSession> {
  @override
  final int typeId = 5;

  @override
  InterviewSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return InterviewSession(
      sessionId: fields[0] as String,
      topic: fields[1] as String,
      difficulty: fields[2] as String,
      type: fields[3] as String,
      questions: (fields[4] as List).cast<InterviewQuestion>(),
      startedAt: fields[5] as DateTime,
      completedAt: fields[6] as DateTime?,
      score: fields[7] as int,
      aiFeedback: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewSession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.topic)
      ..writeByte(2)
      ..write(obj.difficulty)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.questions)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.score)
      ..writeByte(8)
      ..write(obj.aiFeedback);
  }
}

class InterviewQuestionAdapter extends TypeAdapter<InterviewQuestion> {
  @override
  final int typeId = 6;

  @override
  InterviewQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return InterviewQuestion(
      questionId: fields[0] as String,
      questionText: fields[1] as String,
      type: fields[2] as String,
      options: (fields[3] as List?)?.cast<String>(),
      correctAnswer: fields[4] as String?,
      sampleAnswer: fields[5] as String?,
      userAnswer: fields[6] as String,
      aiFeedback: fields[7] as String?,
      scoreAwarded: fields[8] as int?,
      difficulty: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewQuestion obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.questionText)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.options)
      ..writeByte(4)
      ..write(obj.correctAnswer)
      ..writeByte(5)
      ..write(obj.sampleAnswer)
      ..writeByte(6)
      ..write(obj.userAnswer)
      ..writeByte(7)
      ..write(obj.aiFeedback)
      ..writeByte(8)
      ..write(obj.scoreAwarded)
      ..writeByte(9)
      ..write(obj.difficulty);
  }
}
