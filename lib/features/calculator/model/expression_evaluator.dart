import 'dart:math' as math;
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
      final ContextModel cm = ContextModel();
      cm.bindVariable(Variable('pi'), Number(math.pi));
      cm.bindVariable(Variable('e'), Number(math.e));
      final dynamic raw = exp.evaluate(EvaluationType.REAL, cm);
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

  static String normalizeForParser(String input) {
    var s = input.replaceAll('×', '*').replaceAll('÷', '/').replaceAll(',', '');
    s = s.replaceAll('−', '-');
    
    // Auto-inject missing multiplication bounds for parsed mathematical brackets (e.g. '2(' => '2*(')
    s = s.replaceAllMapped(RegExp(r'(\d|\))\s*\('), (m) => '${m[1]}*(');
    
    // math_expressions uses natural log by default for log(), we want base 10 for "log"
    s = s.replaceAll('log(', 'log(10,');

    // math_expressions uses radians for trig functions, we want degrees.
    // We wrap the argument in (pi/180)*(. The existing bracket auto-closer handles the rest.
    s = s.replaceAll('sin(', 'sin((pi/180)*(');
    s = s.replaceAll('cos(', 'cos((pi/180)*(');
    s = s.replaceAll('tan(', 'tan((pi/180)*(');
    
    // Auto-close missing right brackets
    int openCount = s.split('(').length - 1;
    int closeCount = s.split(')').length - 1;
    while (openCount > closeCount) {
      s += ')';
      closeCount++;
    }
    
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
  /// Checks the raw eval string (not normalized) to avoid false positives from
  /// degree-conversion operator injection inside trig functions.
  static bool hasBinaryOperation(String uiExpression) {
    final s = uiExpression.replaceAll(' ', '').replaceAll(',', '');
    if (s.isEmpty) return false;
    if (s.contains('+') || s.contains('*') || s.contains('/') || s.contains('^')) {
      return true;
    }
    return RegExp(r'\d-\d').hasMatch(s);
  }
}
