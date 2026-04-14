import 'package:hive/hive.dart';
import 'package:programming_learn_app/data/models/certificate_model.dart';

class CertificateModelAdapter extends TypeAdapter<CertificateModel> {
  @override
  final int typeId = 4;

  @override
  CertificateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return CertificateModel(
      certificateId: fields[0] as String,
      type: fields[1] as String,
      title: fields[2] as String,
      recipientName: fields[3] as String,
      issuedAt: fields[4] as DateTime,
      level: fields[5] as String,
      score: fields[6] as int,
      verificationCode: fields[7] as String,
      skills: (fields[8] as List).cast<String>(),
      issuerName: fields[9] as String,
      isPdfSaved: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CertificateModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.certificateId)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.recipientName)
      ..writeByte(4)
      ..write(obj.issuedAt)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.score)
      ..writeByte(7)
      ..write(obj.verificationCode)
      ..writeByte(8)
      ..write(obj.skills)
      ..writeByte(9)
      ..write(obj.issuerName)
      ..writeByte(10)
      ..write(obj.isPdfSaved);
  }
}
