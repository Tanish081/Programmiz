class LeaderboardEntry {
  final String name;
  final String avatar;
  final int xp;
  final int streak;
  final bool isUser;
  final int rank;

  LeaderboardEntry({
    required this.name,
    required this.avatar,
    required this.xp,
    required this.streak,
    required this.isUser,
    required this.rank,
  });
}
