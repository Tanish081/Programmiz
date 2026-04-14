import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';
import 'package:programming_learn_app/ui/components/duo_button.dart';

enum EmptyType { noLessons, noStreak, noCertificates, noInternet, noActivity }

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  factory EmptyState.forType(
    EmptyType type, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    switch (type) {
      case EmptyType.noLessons:
        return EmptyState(
          emoji: '📚',
          title: 'Nothing here yet!',
          subtitle: 'Pick a level and start your first lesson',
          actionLabel: actionLabel,
          onAction: onAction,
        );
      case EmptyType.noStreak:
        return EmptyState(
          emoji: '🔥',
          title: 'No streak yet',
          subtitle: 'Come back tomorrow to start one!',
          actionLabel: actionLabel,
          onAction: onAction,
        );
      case EmptyType.noCertificates:
        return EmptyState(
          emoji: '🏆',
          title: 'Certificates loading...',
          subtitle: 'Finish a full level to earn your first one',
          actionLabel: actionLabel,
          onAction: onAction,
        );
      case EmptyType.noInternet:
        return EmptyState(
          emoji: '📡',
          title: 'You\'re offline',
          subtitle: 'Some features use saved content — others need wifi',
          actionLabel: actionLabel,
          onAction: onAction,
        );
      case EmptyType.noActivity:
        return EmptyState(
          emoji: '🌱',
          title: 'Your journey starts today',
          subtitle: 'Complete your first lesson to see activity here',
          actionLabel: actionLabel,
          onAction: onAction,
        );
    }
  }

  final String emoji;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.kH3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.kBodySm,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              DuoButton(
                label: actionLabel!,
                onPressed: onAction,
                style: DuoButtonStyle.outlined,
                size: DuoButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
