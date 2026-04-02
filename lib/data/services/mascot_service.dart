import 'package:programming_learn_app/data/models/user_profile_model.dart';

enum MascotState {
  happy,
  proud,
  excited,
  sad,
  encouraging,
  sleeping,
  celebrating,
}

class MascotMessage {
  const MascotMessage({required this.emoji, required this.message, required this.state});

  final String emoji;
  final String message;
  final MascotState state;
}

class MascotService {
  String getGreeting(UserProfile profile, int streak, int hour) {
    final name = profile.name.trim().isEmpty ? 'Learner' : profile.name.trim();
    if (hour >= 5 && hour <= 11) {
      return 'Good morning, $name! Ready to code?';
    }
    if (hour >= 12 && hour <= 17) {
      return 'Hey $name! Perfect time for a lesson!';
    }
    if (hour >= 18 && hour <= 22) {
      return 'Evening coding session? You are dedicated!';
    }
    if (streak == 0) {
      return 'Late night coding? Let us start a streak!';
    }
    return 'Late night coding? I am impressed, $name!';
  }

  MascotMessage getStreakMessage(int streak, {String? name}) {
    final safeName = (name == null || name.isEmpty) ? 'friend' : name;
    if (streak <= 0) {
      return MascotMessage(
        emoji: '😴',
        message: 'Start your streak today, $safeName! I believe in you!',
        state: MascotState.encouraging,
      );
    }
    if (streak == 1) {
      return const MascotMessage(
        emoji: '🦉',
        message: 'Day 1! Every expert was once a beginner!',
        state: MascotState.happy,
      );
    }
    if (streak <= 3) {
      return const MascotMessage(
        emoji: '🙂',
        message: 'You are building a habit! Keep it up!',
        state: MascotState.happy,
      );
    }
    if (streak <= 6) {
      return MascotMessage(
        emoji: '😊',
        message: 'You are on a roll! $streak days strong!',
        state: MascotState.proud,
      );
    }
    if (streak == 7) {
      return const MascotMessage(
        emoji: '🥳',
        message: 'A whole week! I am so proud of you!',
        state: MascotState.celebrating,
      );
    }
    if (streak <= 13) {
      return MascotMessage(
        emoji: '🔥',
        message: '$streak days! You are on fire!',
        state: MascotState.excited,
      );
    }
    if (streak == 14) {
      return const MascotMessage(
        emoji: '🏆',
        message: '2 weeks straight! You are a coding machine!',
        state: MascotState.celebrating,
      );
    }
    if (streak <= 29) {
      return MascotMessage(
        emoji: '⚡',
        message: '$streak days! Unstoppable!',
        state: MascotState.excited,
      );
    }
    return MascotMessage(
      emoji: '💎',
      message: '$streak DAYS! Legendary status achieved!',
      state: MascotState.celebrating,
    );
  }

  MascotMessage getPerformanceMessage(int scorePercent) {
    if (scorePercent >= 100) {
      return const MascotMessage(emoji: '🦉✨', message: 'PERFECT! You are amazing!', state: MascotState.celebrating);
    }
    if (scorePercent >= 80) {
      return const MascotMessage(emoji: '😄', message: 'So close to perfect! Great job!', state: MascotState.proud);
    }
    if (scorePercent >= 60) {
      return const MascotMessage(emoji: '🙂', message: 'Good effort! Review the ones you missed.', state: MascotState.happy);
    }
    if (scorePercent >= 40) {
      return const MascotMessage(emoji: '😐', message: 'Keep practicing - you have got this!', state: MascotState.encouraging);
    }
    return const MascotMessage(emoji: '🥺', message: 'That was tough! Want to try again?', state: MascotState.sad);
  }

  MascotMessage getTimeOfDayIdle(int hour, {String? name}) {
    final safeName = (name == null || name.isEmpty) ? 'friend' : name;
    if (hour >= 20) {
      return MascotMessage(
        emoji: '😢',
        message: 'I miss you, $safeName! Do not break your streak!',
        state: MascotState.sad,
      );
    }
    return const MascotMessage(
      emoji: '🙂',
      message: 'A tiny coding session today can make tomorrow easier.',
      state: MascotState.encouraging,
    );
  }
}