import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_learn_app/core/providers/app_providers.dart';
import 'package:programming_learn_app/data/models/user_profile_model.dart';

class OnboardingState {
  const OnboardingState({
    this.currentStep = 0,
    this.placementLevel,
    this.name = '',
    this.avatarId,
    this.age,
    this.ageRangeLabel,
    this.experienceLevel,
    this.dailyGoalXP,
    this.preferredTime,
    this.isSaving = false,
  });

  final int currentStep;
  final String? placementLevel;
  final String name;
  final String? avatarId;
  final int? age;
  final String? ageRangeLabel;
  final String? experienceLevel;
  final int? dailyGoalXP;
  final String? preferredTime;
  final bool isSaving;

  bool get isNameValid => name.trim().length >= 2;
  bool get hasPlacement => placementLevel != null;
  bool get hasAvatar => avatarId != null;
  bool get hasAgeAndExperience => age != null && experienceLevel != null;
  bool get hasGoal => dailyGoalXP != null;
  bool get hasPreferredTime => preferredTime != null;

  OnboardingState copyWith({
    int? currentStep,
    String? placementLevel,
    String? name,
    String? avatarId,
    int? age,
    String? ageRangeLabel,
    String? experienceLevel,
    int? dailyGoalXP,
    String? preferredTime,
    bool? isSaving,
    bool clearAvatar = false,
    bool clearAge = false,
    bool clearExperience = false,
    bool clearGoal = false,
    bool clearPreferredTime = false,
    bool clearPlacement = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      placementLevel: clearPlacement ? null : (placementLevel ?? this.placementLevel),
      name: name ?? this.name,
      avatarId: clearAvatar ? null : (avatarId ?? this.avatarId),
      age: clearAge ? null : (age ?? this.age),
      ageRangeLabel: clearAge ? null : (ageRangeLabel ?? this.ageRangeLabel),
      experienceLevel: clearExperience ? null : (experienceLevel ?? this.experienceLevel),
      dailyGoalXP: clearGoal ? null : (dailyGoalXP ?? this.dailyGoalXP),
      preferredTime: clearPreferredTime ? null : (preferredTime ?? this.preferredTime),
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._ref) : super(const OnboardingState());

  final Ref _ref;

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void selectPlacementLevel(String placementLevel) {
    state = state.copyWith(placementLevel: placementLevel, experienceLevel: placementLevel);
  }

  void selectAvatar(String avatarId) {
    state = state.copyWith(avatarId: avatarId);
  }

  void selectAgeRange({required int age, required String label}) {
    state = state.copyWith(age: age, ageRangeLabel: label);
  }

  void selectExperience(String experienceLevel) {
    state = state.copyWith(experienceLevel: experienceLevel);
  }

  void selectDailyGoal(int xpGoal) {
    state = state.copyWith(dailyGoalXP: xpGoal);
  }

  void selectPreferredTime(String preferredTime) {
    state = state.copyWith(preferredTime: preferredTime);
  }

  Future<void> completeOnboarding() async {
    if (!state.isNameValid ||
        !state.hasAvatar ||
        !state.hasAgeAndExperience ||
        !state.hasGoal ||
        !state.hasPreferredTime) {
      return;
    }

    final profile = UserProfile(
      name: state.name.trim(),
      avatarId: state.avatarId!,
      age: state.age!,
      experienceLevel: state.experienceLevel ?? state.placementLevel!,
      dailyGoalXP: state.dailyGoalXP!,
      preferredTime: state.preferredTime!,
      isGuest: true,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(isSaving: true);
    await _ref.read(preferencesServiceProvider).saveUserProfile(profile);
    state = state.copyWith(isSaving: false);
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});
