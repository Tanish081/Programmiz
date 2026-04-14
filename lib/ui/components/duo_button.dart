import 'package:flutter/material.dart';
import 'package:programming_learn_app/core/constants/app_colors.dart';
import 'package:programming_learn_app/core/constants/app_text_styles.dart';
import 'package:programming_learn_app/core/services/sound_service.dart';

enum DuoButtonSize { small, medium, large }

enum DuoButtonStyle { filled, outlined, ghost }

class DuoButton extends StatefulWidget {
  const DuoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.size = DuoButtonSize.medium,
    this.style,
    this.color,
    this.darkColor,
    this.loadingLabel = 'Hang on...',
    this.isPrimary = true,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final DuoButtonSize size;
  final DuoButtonStyle? style;
  final Color? color;
  final Color? darkColor;
  final String loadingLabel;
  final bool isPrimary;
  final bool isBusy;

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _pressed = false;

  DuoButtonStyle get _resolvedStyle {
    if (widget.style != null) {
      return widget.style!;
    }
    return widget.isPrimary ? DuoButtonStyle.filled : DuoButtonStyle.outlined;
  }

  double get _height {
    switch (widget.size) {
      case DuoButtonSize.small:
        return 40;
      case DuoButtonSize.large:
        return 56;
      case DuoButtonSize.medium:
        return 48;
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case DuoButtonSize.small:
        return AppTextStyles.kBtnSm;
      case DuoButtonSize.large:
        return AppTextStyles.kBtnLg;
      case DuoButtonSize.medium:
        return AppTextStyles.kBtnMd;
    }
  }

  void _handleTap() {
    if (widget.isBusy || widget.onPressed == null) {
      return;
    }

    SoundService.playTap();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolvedStyle;
    final color = widget.color ?? AppColors.kGreen;
    final darkColor = widget.darkColor ?? AppColors.kGreenDark;
    final disabled = widget.isBusy || widget.onPressed == null;

    final background = style == DuoButtonStyle.filled
        ? color
        : style == DuoButtonStyle.outlined
            ? Colors.transparent
            : Colors.transparent;

    final foreground = style == DuoButtonStyle.filled ? Colors.white : color;

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    Widget child = AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: style == DuoButtonStyle.outlined
            ? Border.all(color: color, width: 2)
            : style == DuoButtonStyle.filled && !_pressed
                ? Border(
                    bottom: BorderSide(
                      color: darkColor,
                      width: 4,
                    ),
                  )
                : const Border(),
        boxShadow: style == DuoButtonStyle.filled
            ? [
                BoxShadow(
                  color: darkColor.withValues(alpha: 0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ]
            : const [],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: widget.size == DuoButtonSize.small ? 12 : 18,
        vertical: widget.size == DuoButtonSize.small ? 9 : widget.size == DuoButtonSize.large ? 16 : 13,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: widget.isBusy
            ? Row(
                key: const ValueKey('busy'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.loadingLabel, style: _textStyle.copyWith(color: foreground)),
                ],
              )
            : Row(
                key: const ValueKey('label'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.leadingIcon != null) ...[
                    widget.leadingIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(widget.label, style: _textStyle.copyWith(color: foreground)),
                ],
              ),
      ),
    );

    if (style == DuoButtonStyle.ghost) {
      child = TextButton(
        onPressed: disabled ? null : _handleTap,
        style: TextButton.styleFrom(
          foregroundColor: color,
          overlayColor: color.withValues(alpha: 0.1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: _textStyle.copyWith(color: color),
        ),
        child: Text(widget.label, style: _textStyle.copyWith(color: color)),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: disabled || style == DuoButtonStyle.ghost ? null : _handleTap,
          onHighlightChanged: (value) {
            if (!mounted || disabled || style == DuoButtonStyle.ghost) {
              return;
            }
            setState(() => _pressed = value);
          },
          child: child,
        ),
      ),
    );
  }
}