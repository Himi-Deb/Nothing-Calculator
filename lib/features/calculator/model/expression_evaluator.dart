import 'package:math_expressions/math_expressions.dart';

/// Wraps [math_expressions] with UI-friendly normalization and formatting.
abstract final class ExpressionEvaluator {
  /// Returns `null` if the expression is empty, invalid, or non-finite.
  static double? evaluate(String uiExpression) {
    final normalized = normalizeForParser(uiExpression);
    if (normalized.isEmpty) return null;
    try {
      final parser = Parser();
      final Expression exp = parser.parse(normalized);
      final dynamic raw = exp.evaluate(EvaluationType.REAL, ContextModel());
      final double value = _toDouble(raw);
      if (!value.isFinite) return null;
      return value;
    } catch (_) {
      return null;
    }
  }

  static double _toDouble(dynamic raw) {
    if (raw is double) return raw;
    if (raw is int) return raw.toDouble();
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? double.nan;
  }

  /// Maps UI symbols to parser tokens and strips display-only characters.
  static String normalizeForParser(String input) {
    var s = input.replaceAll('×', '*').replaceAll('÷', '/').replaceAll(',', '');
    s = s.replaceAll('−', '-');
    s = s.trim();
    return s;
  }

  /// Last binary operator in the UI string (for glyph / dot-matrix), scanning
  /// left-to-right and skipping a leading unary minus.
  static String? lastBinaryOperatorSymbol(String uiExpression) {
    final s = uiExpression.replaceAll(' ', '').replaceAll(',', '');
    String? last;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '+' ||
          c == '×' ||
          c == '÷' ||
          c == '*' ||
          c == '/' ||
          c == '^') {
        last = _toUiSymbol(c);
        continue;
      }
      if (c == '−' || c == '-') {
        if (i > 0 && RegExp(r'[0-9.)]').hasMatch(s[i - 1])) {
          last = '−';
        }
      }
    }
    return last;
  }

  static String _toUiSymbol(String ascii) {
    return switch (ascii) {
      '*' => '×',
      '/' => '÷',
      '-' => '−',
      '^' => '^',
      _ => ascii,
    };
  }

  /// `true` when evaluation is more than a single literal number (glyph policy).
  static bool hasBinaryOperation(String uiExpression) {
    final n = normalizeForParser(uiExpression);
    if (n.isEmpty) return false;
    if (n.contains('+') || n.contains('*') || n.contains('/') || n.contains('^')) {
      return true;
    }
    return RegExp(r'\d-\d').hasMatch(n);
  }
}
