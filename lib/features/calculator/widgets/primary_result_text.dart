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

    final children = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      children.add(TextSpan(text: parts[i], style: base));
      if (i < parts.length - 1) {
        children.add(
          TextSpan(
            text: '●',
            style: base.copyWith(
              color: AppColors.decimalDot,
              fontSize: fontSize * 0.23,
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: children),
      textAlign: TextAlign.right,
    );
  }
}
