import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Large result / operand with accent decimal dot (Calci-App reference).
class PrimaryResultText extends StatelessWidget {
  const PrimaryResultText({
    super.key,
    required this.text,
    this.fontSize = 48,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.primaryResult(fontSize: fontSize);

    final parts = text.split('.');
    if (parts.length == 1) {
      return Text(text, style: base, textAlign: TextAlign.right);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts[0], style: base),
          TextSpan(
            text: '●',
            style: base.copyWith(
              color: AppColors.decimalDot,
              fontSize: fontSize * 0.23,
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
