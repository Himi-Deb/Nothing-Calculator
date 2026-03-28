import 'package:flutter/material.dart';

/// Design tokens aligned with Calci-App (Basic / Scientific references).
abstract final class AppColors {
  static const Color background = Color(0xFF000000);

  /// Primary accent for operators and equals key.
  static const Color accentRed = Color(0xFFE3242B);

  static const Color activeText = Color(0xFFFFFFFF);

  /// Newest history line (closest to active row).
  static const Color historyGreyNewest = Color(0xFFB8B8B8);

  /// Oldest visible history line (top of stack).
  static const Color historyGreyOldest = Color(0xFF4A4A4A);

  static const Color divider = Color(0xFF2A2A2A);

  /// Decimal separator dot in the main result (accent).
  static const Color decimalDot = accentRed;
}
