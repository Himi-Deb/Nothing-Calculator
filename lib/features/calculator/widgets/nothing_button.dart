import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

typedef NothingTap = void Function();

/// Tappable calculator control with light haptic feedback (Nothing-style tactile cue).
class NothingButton extends StatelessWidget {
  const NothingButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.showFlaskDot = false,
  }) : assert(label != null || icon != null, 'Provide label or icon');

  final NothingTap? onPressed;
  final String? label;
  final IconData? icon;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool showFlaskDot;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? AppColors.activeText;
    final child = icon != null
        ? _FlaskOrIcon(
            icon: icon!,
            color: fg,
            showDot: showFlaskDot,
          )
        : Text(
            label!,
            style: TextStyle(
              color: fg,
              fontSize: _fontSizeForLabel(label!),
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          );

    final pad = icon != null
        ? const EdgeInsets.symmetric(vertical: 6, horizontal: 4)
        : const EdgeInsets.symmetric(vertical: 14, horizontal: 4);

    return Material(
      color: backgroundColor ?? Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        splashColor: AppColors.accentRed.withValues(alpha: 0.12),
        highlightColor: Colors.white10,
        child: Center(
          child: Padding(
            padding: pad,
            child: child,
          ),
        ),
      ),
    );
  }

  static double _fontSizeForLabel(String s) {
    if (s.length >= 3) return 18;
    return 26;
  }
}

class _FlaskOrIcon extends StatelessWidget {
  const _FlaskOrIcon({
    required this.icon,
    required this.color,
    required this.showDot,
  });

  final IconData icon;
  final Color color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            offset: showDot ? Offset.zero : const Offset(0, 0.35),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: showDot ? 1 : 0,
              child: Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
