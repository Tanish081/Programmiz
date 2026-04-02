import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';

class LanguageHubCardData {
  const LanguageHubCardData({
    required this.id,
    required this.name,
    required this.icon,
    required this.subtitle,
    required this.available,
  });

  final String id;
  final String name;
  final String icon;
  final String subtitle;
  final bool available;
}

class LanguageHubState {
  const LanguageHubState({
    this.isLoading = true,
    this.userName = 'Learner',
    this.streak = 0,
    this.totalXP = 0,
    this.todayXP = 0,
    this.dailyGoalXP = 20,
    this.placementLevel = 'absolute_beginner',
    this.cards = const [],
  });

  final bool isLoading;
  final String userName;
  final int streak;
  final int totalXP;
  final int todayXP;
  final int dailyGoalXP;
  final String placementLevel;
  final List<LanguageHubCardData> cards;

  LanguageHubState copyWith({
    bool? isLoading,
    String? userName,
    int? streak,
    int? totalXP,
    int? todayXP,
    int? dailyGoalXP,
    String? placementLevel,
    List<LanguageHubCardData>? cards,
  }) {
    return LanguageHubState(
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      streak: streak ?? this.streak,
      totalXP: totalXP ?? this.totalXP,
      todayXP: todayXP ?? this.todayXP,
      dailyGoalXP: dailyGoalXP ?? this.dailyGoalXP,
      placementLevel: placementLevel ?? this.placementLevel,
      cards: cards ?? this.cards,
    );
  }
}

class LanguageHubNotifier extends StateNotifier<LanguageHubState> {
  LanguageHubNotifier(this._ref) : super(const LanguageHubState());

  final Ref _ref;

  static const List<LanguageHubCardData> _defaultCards = [
    LanguageHubCardData(
      id: 'python',
      name: 'Python',
      icon: '🐍',
      subtitle: 'Start here with clear lessons and guided practice.',
      available: true,
    ),
    LanguageHubCardData(
      id: 'javascript',
      name: 'JavaScript',
      icon: '🟨',
      subtitle: 'Coming soon with web and UI fundamentals.',
      available: false,
    ),
    LanguageHubCardData(
      id: 'java',
      name: 'Java',
      icon: '☕',
      subtitle: 'Coming soon with object-oriented basics.',
      available: false,
    ),
    LanguageHubCardData(
      id: 'cpp',
      name: 'C++',
      icon: '⚙️',
      subtitle: 'Coming soon for low-level programming.',
      available: false,
    ),
  ];

  Future<void> load() async {
    state = state.copyWith(isLoading: true, cards: _defaultCards);
    final prefs = _ref.read(preferencesServiceProvider);
    final profile = await prefs.loadUserProfile();

    state = state.copyWith(
      isLoading: false,
      userName: profile?.name ?? 'Learner',
      streak: await prefs.getStreak(),
      totalXP: await prefs.getXP(),
      todayXP: await prefs.getTodayXP(),
      dailyGoalXP: profile?.dailyGoalXP ?? 20,
      placementLevel: await prefs.getPlacementLevel() ?? profile?.experienceLevel ?? 'absolute_beginner',
    );
  }
}

final languageHubProvider = StateNotifierProvider<LanguageHubNotifier, LanguageHubState>((ref) {
  return LanguageHubNotifier(ref);
});