import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class CertificateModel {
  const CertificateModel({
    required this.certificateId,
    required this.type,
    required this.title,
    required this.recipientName,
    required this.issuedAt,
    required this.level,
    required this.score,
    required this.verificationCode,
    required this.skills,
    required this.issuerName,
    required this.isPdfSaved,
  });

  @HiveField(0)
  final String certificateId;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String recipientName;

  @HiveField(4)
  final DateTime issuedAt;

  @HiveField(5)
  final String level;

  @HiveField(6)
  final int score;

  @HiveField(7)
  final String verificationCode;

  @HiveField(8)
  final List<String> skills;

  @HiveField(9)
  final String issuerName;

  @HiveField(10)
  final bool isPdfSaved;

  CertificateModel copyWith({
    String? certificateId,
    String? type,
    String? title,
    String? recipientName,
    DateTime? issuedAt,
    String? level,
    int? score,
    String? verificationCode,
    List<String>? skills,
    String? issuerName,
    bool? isPdfSaved,
  }) {
    return CertificateModel(
      certificateId: certificateId ?? this.certificateId,
      type: type ?? this.type,
      title: title ?? this.title,
      recipientName: recipientName ?? this.recipientName,
      issuedAt: issuedAt ?? this.issuedAt,
      level: level ?? this.level,
      score: score ?? this.score,
      verificationCode: verificationCode ?? this.verificationCode,
      skills: skills ?? this.skills,
      issuerName: issuerName ?? this.issuerName,
      isPdfSaved: isPdfSaved ?? this.isPdfSaved,
    );
  }
}
