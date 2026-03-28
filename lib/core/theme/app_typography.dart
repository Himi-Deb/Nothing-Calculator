import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Space Mono–based styles (Calci-App reference).
abstract final class AppTypography {
  /// Target line height for digit keys and matching Material icons.
  static const double keyCapSize = 26;

  static TextStyle spaceMono({
    required Color color,
    double fontSize = keyCapSize,
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.0,
    double? letterSpacing,
  }) =>
      GoogleFonts.spaceMono(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Keys with more than two graphemes (SIN, LOG, INV, …) use a slightly smaller cap to match grid.
  static TextStyle keyLabel(String text, Color color) {
    if (_isBasicOperator(text)) return operatorLabel(color);
    final compact = text.runes.length > 2;
    return spaceMono(
      color: color,
      fontSize: compact ? 18 : keyCapSize,
      fontWeight: FontWeight.w500,
      height: 1.0,
    );
  }

  static TextStyle operatorLabel(Color color) => spaceMono(
        color: color,
        fontSize: keyCapSize * 1.4,
        fontWeight: FontWeight.w500,
        height: 1.0,
      );

  static bool _isBasicOperator(String s) {
    return s == '÷' || s == '×' || s == '−' || s == '+';
  }

  static TextStyle displaySecondary(Color color, {double fontSize = 20}) =>
      spaceMono(color: color, fontSize: fontSize, fontWeight: FontWeight.w400, height: 1.2);

  static TextStyle displayHistoryExpression(Color color, {double fontSize = 17}) =>
      spaceMono(color: color, fontSize: fontSize, fontWeight: FontWeight.w400, height: 1.25);

  static TextStyle displayHistoryResult(Color color, {double fontSize = 22}) =>
      spaceMono(color: color, fontSize: fontSize, fontWeight: FontWeight.w600, height: 1.1);

  static TextStyle primaryResult({double fontSize = 48}) => spaceMono(
        color: AppColors.activeText,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        height: 1.05,
        letterSpacing: -0.5,
      );

  static TextStyle scientificCaption(Color color) =>
      spaceMono(color: color, fontSize: 14, fontWeight: FontWeight.w400, height: 1);

  static TextStyle dotMatrixSymbol(Color color, {double fontSize = 22}) => spaceMono(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1,
        letterSpacing: 4,
      );
}
