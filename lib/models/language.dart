class Language {
  final String id;
  final String name;
  final String emoji;
  final String? logoUrl;
  final String description;
  final int lessonsCompleted;
  final int totalLessons;
  final int xpEarned;

  Language({
    required this.id,
    required this.name,
    required this.emoji,
    this.logoUrl,
    required this.description,
    this.lessonsCompleted = 0,
    this.totalLessons = 50,
    this.xpEarned = 0,
  });

  double get progress => (lessonsCompleted / totalLessons) * 100;

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      logoUrl: json['logoUrl'],
      description: json['description'],
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      totalLessons: json['totalLessons'] ?? 50,
      xpEarned: json['xpEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'logoUrl': logoUrl,
      'description': description,
      'lessonsCompleted': lessonsCompleted,
      'totalLessons': totalLessons,
      'xpEarned': xpEarned,
    };
  }
}
