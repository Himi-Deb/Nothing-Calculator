import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Large result / operand with accent decimal dot (Calci-App reference).
class PrimaryResultText extends StatelessWidget {
  const PrimaryResultText({
    super.key,
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ??
        const TextStyle(
          color: AppColors.activeText,
          fontSize: 48,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.05,
        );

    final parts = text.split('.');
    if (parts.length == 1) {
      return Text(text, style: base, textAlign: TextAlign.right);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts[0], style: base),
          const TextSpan(text: ' '),
          TextSpan(
            text: '●',
            style: base.copyWith(
              color: AppColors.decimalDot,
              fontSize: (base.fontSize ?? 48) * 0.38,
            ),
          ),
          TextSpan(
            text: parts.sublist(1).join('.'),
            style: base,
          ),
        ],
      ),
      textAlign: TextAlign.right,
    );
  }
}
