import 'dart:math';
import 'package:riverpod/riverpod.dart';
import 'package:programming_learn_app/data/models/leaderboard_entry_model.dart';
import 'package:programming_learn_app/data/local/ghost_profiles.dart';
import 'package:programming_learn_app/data/services/preferences_service.dart';

class LeaderboardState {
  final List<LeaderboardEntry> rankedList;
  final int userRank;
  final int userWeeklyXP;
  final int selectedTab; // 0 = weekly, 1 = allTime

  LeaderboardState({
    required this.rankedList,
    required this.userRank,
    required this.userWeeklyXP,
    required this.selectedTab,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? rankedList,
    int? userRank,
    int? userWeeklyXP,
    int? selectedTab,
  }) {
    return LeaderboardState(
      rankedList: rankedList ?? this.rankedList,
      userRank: userRank ?? this.userRank,
      userWeeklyXP: userWeeklyXP ?? this.userWeeklyXP,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final PreferencesService _preferencesService;

  LeaderboardNotifier(this._preferencesService)
      : super(
          LeaderboardState(
            rankedList: [],
            userRank: 0,
            userWeeklyXP: 0,
            selectedTab: 0,
          ),
        );

  Future<void> loadWeeklyLeaderboard() async {
    final userWeeklyXP = await _calculateUserWeeklyXP();
    final entries = await _generateLeaderboardEntries(userWeeklyXP, isWeekly: true);

    final userRank = entries.indexWhere((e) => e.isUser) + 1;

    state = state.copyWith(
      rankedList: entries,
      userRank: userRank,
      userWeeklyXP: userWeeklyXP,
      selectedTab: 0,
    );
  }

  Future<void> loadAllTimeLeaderboard() async {
    final totalXP = await _preferencesService.getXP();
    final entries = await _generateLeaderboardEntries(totalXP, isWeekly: false);

    final userRank = entries.indexWhere((e) => e.isUser) + 1;

    state = state.copyWith(
      rankedList: entries,
      userRank: userRank,
      userWeeklyXP: totalXP,
      selectedTab: 1,
    );
  }

  Future<void> switchTab(int index) async {
    if (index == 0) {
      await loadWeeklyLeaderboard();
    } else {
      await loadAllTimeLeaderboard();
    }
  }

  Future<int> _calculateUserWeeklyXP() async {
    final activity = await _preferencesService.getYearlyActivity();
    final now = DateTime.now();
    
    // Calculate Monday of this week
    final daysIntoWeek = now.weekday - 1; // 0 = Monday
    final monday = now.subtract(Duration(days: daysIntoWeek));
    
    int weeklyXP = 0;
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      weeklyXP += activity[dateStr] ?? 0;
    }
    
    return weeklyXP;
  }

  Future<List<LeaderboardEntry>> _generateLeaderboardEntries(
    int userXP, {
    required bool isWeekly,
  }) async {
    final now = DateTime.now();
    final weekNumber = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    
    final entries = <LeaderboardEntry>[];

    // Generate ghost XP
    for (int i = 0; i < ghostProfiles.length; i++) {
      final profile = ghostProfiles[i];
      final seed = weekNumber + i;
      final rng = Random(seed);
      final ghostXP = 50 + rng.nextInt(301); // 50-350 range

      entries.add(
        LeaderboardEntry(
          name: profile['name'] as String,
          avatar: profile['avatar'] as String,
          xp: ghostXP,
          streak: rng.nextInt(30) + 1, // 1-30 day streak
          isUser: false,
          rank: 0,
        ),
      );
    }

    // Add user
    entries.add(
      LeaderboardEntry(
        name: 'You',
        avatar: '👤',
        xp: userXP,
        streak: await _preferencesService.getStreak(),
        isUser: true,
        rank: 0,
      ),
    );

    // Sort by XP descending
    entries.sort((a, b) => b.xp.compareTo(a.xp));

    // Assign ranks
    for (int i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntry(
        name: entries[i].name,
        avatar: entries[i].avatar,
        xp: entries[i].xp,
        streak: entries[i].streak,
        isUser: entries[i].isUser,
        rank: i + 1,
      );
    }

    return entries;
  }
}

final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>(
  (ref) {
    final prefsService = PreferencesService();
    return LeaderboardNotifier(prefsService);
  },
);
