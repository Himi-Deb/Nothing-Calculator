import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

typedef NothingTap = void Function();

/// Tappable calculator control with light haptic feedback (Nothing-style tactile cue).
class NothingButton extends StatelessWidget {
  const NothingButton({
    super.key,
    required this.onPressed,
    this.label,
    this.caption,
    this.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.fontSize,
    this.scale,
    this.showFlaskDot = false,
  }) : assert(label != null || icon != null, 'Provide label or icon');

  final NothingTap? onPressed;
  final String? label;
  final String? caption;
  final IconData? icon;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double? fontSize;
  final double? scale;
  final bool showFlaskDot;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? AppColors.activeText;
    final effectiveFontSize = caption != null ? 18.0 : fontSize;

    final child = icon != null
        ? _FlaskOrIcon(
            icon: icon!,
            color: fg,
            showDot: showFlaskDot,
            iconSize: AppTypography.keyCapSize,
          )
        : Text(
            label!,
            style: AppTypography.keyLabel(label!, fg).copyWith(
              fontSize: effectiveFontSize,
            ),
          );

    Widget content = child;
    if (scale != null) {
      content = Transform.scale(
        scale: scale!,
        child: content,
      );
    }

    if (caption != null) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            caption!,
            style: AppTypography.scientificCaption(const Color(0xFF787776)),
          ),
          const SizedBox(height: 4),
          content,
        ],
      );
    }

    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        splashColor: AppColors.accentRed.withValues(alpha: 0.12),
        highlightColor: Colors.white10,
        child: Center(
          child: content,
        ),
      ),
    );
  }
}

class _FlaskOrIcon extends StatelessWidget {
  const _FlaskOrIcon({
    required this.icon,
    required this.color,
    required this.showDot,
    required this.iconSize,
  });

  final IconData icon;
  final Color color;
  final bool showDot;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: color, size: iconSize),
          Positioned(
            bottom: -9,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              offset: showDot ? Offset.zero : const Offset(0, 0.35),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: showDot ? 1 : 0,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
