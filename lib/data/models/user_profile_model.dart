class UserProfile {
  const UserProfile({
    required this.name,
    required this.avatarId,
    required this.age,
    required this.experienceLevel,
    required this.dailyGoalXP,
    required this.preferredTime,
    required this.isGuest,
    required this.createdAt,
  });

  final String name;
  final String avatarId;
  final int age;
  final String experienceLevel;
  final int dailyGoalXP;
  final String preferredTime;
  final bool isGuest;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarId': avatarId,
      'age': age,
      'experienceLevel': experienceLevel,
      'dailyGoalXP': dailyGoalXP,
      'preferredTime': preferredTime,
      'isGuest': isGuest,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      avatarId: json['avatarId'] as String,
      age: (json['age'] as num).toInt(),
      experienceLevel: json['experienceLevel'] as String,
      dailyGoalXP: (json['dailyGoalXP'] as num).toInt(),
      preferredTime: json['preferredTime'] as String,
      isGuest: json['isGuest'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}