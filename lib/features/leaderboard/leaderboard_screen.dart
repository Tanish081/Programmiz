import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:programming_learn_app/features/leaderboard/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardProvider.notifier).loadWeeklyLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(leaderboardProvider);
    final notifier = ref.read(leaderboardProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  _getCurrentWeekLabel(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Tab selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      notifier.switchTab(0);
                    },
                    child: Column(
                      children: [
                        Text(
                          'This Week',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: leaderboardState.selectedTab == 0
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: leaderboardState.selectedTab == 0
                                ? const Color(0xFF58CC02)
                                : Colors.grey,
                          ),
                        ),
                        if (leaderboardState.selectedTab == 0)
                          Container(
                            width: 40,
                            height: 3,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF58CC02),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      notifier.switchTab(1);
                    },
                    child: Column(
                      children: [
                        Text(
                          'All Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: leaderboardState.selectedTab == 1
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: leaderboardState.selectedTab == 1
                                ? const Color(0xFF58CC02)
                                : Colors.grey,
                          ),
                        ),
                        if (leaderboardState.selectedTab == 1)
                          Container(
                            width: 40,
                            height: 3,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF58CC02),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Podium (top 3)
                  if (leaderboardState.rankedList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: _buildPodium(leaderboardState.rankedList),
                    ),
                  if (leaderboardState.rankedList.isNotEmpty)
                    Divider(
                      height: 1,
                      color: Colors.grey[200],
                      indent: 16,
                      endIndent: 16,
                    ),
                  // Ranked list (4+)
                  ...List.generate(
                    leaderboardState.rankedList.length > 3
                        ? leaderboardState.rankedList.length - 3
                        : 0,
                    (index) {
                      final entry = leaderboardState.rankedList[index + 3];
                      return _buildRankRow(entry, leaderboardState);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Motivation banner
                  if (leaderboardState.userRank > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          leaderboardState.userRank <= 5
                              ? '💪 Earn ${_getXPToNextRank(leaderboardState)} more XP to pass ${_getNameAbove(leaderboardState)}!'
                              : '💪 ${_getXPToNextRank(leaderboardState)} XP needed to reach Top 5!',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7FFB8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '🏆 You\'re #1 this week! Keep it up!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF58CC02),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List rankedList) {
    var podiumList = <dynamic>[];
    
    if (rankedList.isNotEmpty) podiumList.add(rankedList[0]); // 1st
    if (rankedList.length > 1) podiumList.add(rankedList[1]); // 2nd
    if (rankedList.length > 2) podiumList.add(rankedList[2]); // 3rd

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place (left)
        Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey[200],
              child: Text(podiumList.length > 1 ? podiumList[1].avatar : '?',
                  style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 8),
            Text(
              podiumList.length > 1
                  ? (podiumList[1].name.length > 8
                      ? '${podiumList[1].name.substring(0, 8)}...'
                      : podiumList[1].name)
                  : 'N/A',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              podiumList.length > 1 ? '${podiumList[1].xp} XP' : '',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('🥈', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(width: 12),
        // 1st place (center, tall)
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFD900),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey[200],
                child: Text(podiumList.isNotEmpty ? podiumList[0].avatar : '?',
                    style: const TextStyle(fontSize: 56)),
              ),
            ),
            const Text('👑', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              podiumList.isNotEmpty
                  ? (podiumList[0].name.length > 8
                      ? '${podiumList[0].name.substring(0, 8)}...'
                      : podiumList[0].name)
                  : 'N/A',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              podiumList.isNotEmpty ? '${podiumList[0].xp} XP' : '',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('🥇', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(width: 12),
        // 3rd place (right)
        Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[200],
              child: Text(podiumList.length > 2 ? podiumList[2].avatar : '?',
                  style: const TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 8),
            Text(
              podiumList.length > 2
                  ? (podiumList[2].name.length > 8
                      ? '${podiumList[2].name.substring(0, 8)}...'
                      : podiumList[2].name)
                  : 'N/A',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              podiumList.length > 2 ? '${podiumList[2].xp} XP' : '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('🥉', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildRankRow(entry, leaderboardState) {
    final isUser = entry.isUser;
    final backgroundColor =
        isUser ? const Color(0xFFD7FFB8) : Colors.transparent;
    final borderColor = isUser ? const Color(0xFF58CC02) : Colors.transparent;

    return Container(
      margin:
          isUser ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: isUser ? 2 : 0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '${entry.rank}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isUser ? const Color(0xFF58CC02) : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            child: Text(entry.avatar, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (isUser)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF58CC02),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.xp} XP this week',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '🔥 ${entry.streak}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF9600),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentWeekLabel() {
    final now = DateTime.now();
    final mondayDaysBack = now.weekday - 1;
    final monday = now.subtract(Duration(days: mondayDaysBack));
    final sunday = monday.add(const Duration(days: 6));

    final monthDayFormat = DateFormat('MMM d');
    return '${monthDayFormat.format(monday)}–${monthDayFormat.format(sunday)}';
  }

  int _getXPToNextRank(leaderboardState) {
    if (leaderboardState.userRank <= 0 ||
        leaderboardState.userRank >= leaderboardState.rankedList.length) {
      return 0;
    }

    final userEntry = leaderboardState.rankedList
        .firstWhere((e) => e.isUser, orElse: () => null);
    final nextRankEntry = leaderboardState.rankedList[leaderboardState.userRank];

    if (userEntry == null || nextRankEntry == null) return 0;

    final diff = nextRankEntry.xp - userEntry.xp + 1;
    return diff > 0 ? diff : 0;
  }

  String _getNameAbove(leaderboardState) {
    if (leaderboardState.userRank <= 1 ||
        leaderboardState.userRank - 2 < 0 ||
        leaderboardState.userRank - 2 >= leaderboardState.rankedList.length) {
      return 'the next player';
    }

    return leaderboardState.rankedList[leaderboardState.userRank - 2].name;
  }
}
