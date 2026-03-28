import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../glyph/glyph_feedback.dart';
import '../model/display_format.dart';
import '../model/expression_evaluator.dart';
import '../model/history_entry.dart';

/// MVC controller: keypad events, history, and evaluation orchestration.
class CalculatorController extends ChangeNotifier {
  CalculatorController({GlyphFeedback? glyph})
      : _glyph = glyph ?? GlyphFeedback.noop;

  final GlyphFeedback _glyph;

  final List<HistoryEntry> _history = <HistoryEntry>[];
  final List<String> _chunks = <String>[];

  /// Raw numeric / textual buffer for the active operand (no grouping commas).
  String _current = '0';

  bool _afterEquals = false;
  String? _frozenExpression;
  String? _frozenResult;

  String? _dotMatrixOp;
  bool _scientificMode = false;

  List<HistoryEntry> get history => List<HistoryEntry>.unmodifiable(_history);
  bool get scientificMode => _scientificMode;
  String? get dotMatrixOperationSymbol => _dotMatrixOp;

  void toggleScientific() {
    _scientificMode = !_scientificMode;
    notifyListeners();
  }

  /// Grey line: expression / frozen expression / history context.
  String get secondaryLine {
    if (_afterEquals && _frozenExpression != null) {
      return _frozenExpression!;
    }
    return _prettyInfixExpression();
  }

  /// White line: operand or final result.
  String get primaryLine {
    if (_afterEquals && _frozenResult != null) {
      return _frozenResult!;
    }
    return DisplayFormat.formatOperand(_current);
  }

  void inputDigit(String d) {
    if (d.length != 1 || !RegExp(r'[0-9]').hasMatch(d)) return;
    _commitFrozenToHistoryIfNeeded();
    if (_afterEquals) {
      _clearFrozen();
      _chunks.clear();
      _afterEquals = false;
    }
    if (_current == '0' && d != '0') {
      _current = d;
    } else if (_current == '-0') {
      _current = '-$d';
    } else {
      _current += d;
    }
    _dotMatrixOp = null;
    notifyListeners();
  }

  void inputDecimal() {
    _commitFrozenToHistoryIfNeeded();
    if (_afterEquals) {
      _clearFrozen();
      _chunks.clear();
      _afterEquals = false;
      _current = '0';
    }
    if (_current.contains('.')) return;
    _current = _current.isEmpty ? '0.' : '$_current.';
    notifyListeners();
  }

  void applyInverse() {
    if (!_scientificMode) return;
    _commitFrozenToHistoryIfNeeded();
    if (_afterEquals) {
      _afterEquals = false;
      _clearFrozen();
    }
    final v = double.tryParse(_sanitizeNumber(_current)) ?? 0;
    if (v == 0) return;
    final r = 1 / v;
    if (!r.isFinite) return;
    _current = _stripTrailingZeros(r.toString());
    _chunks.clear();
    notifyListeners();
  }

  void inputOperator(String uiOp) {
    _commitFrozenToHistoryIfNeeded();
    if (_afterEquals) {
      _afterEquals = false;
      _clearFrozen();
    }

    final ascii = _toAsciiOperator(uiOp);
    final n = _sanitizeNumber(_current);

    // If we just finished an operator and haven't started a new operand yet ('0'),
    // we allow replacing the operator.
    if (_chunks.isNotEmpty && _isAsciiOperator(_chunks.last) && _current == '0') {
      _chunks[_chunks.length - 1] = ascii;
    } else {
      // Otherwise, commit the current operand and then the operator.
      _chunks.add(n);
      _chunks.add(ascii);
      _current = '0';
    }
    notifyListeners();
  }

  Future<void> equals() async {
    final full = _evalString();
    if (full.isEmpty) return;

    final result = ExpressionEvaluator.evaluate(full);
    if (result == null) {
      _frozenExpression = _prettyInfixExpression();
      _frozenResult = 'Error';
      _afterEquals = true;
      _dotMatrixOp = null;
      _chunks.clear();
      _current = '0';
      notifyListeners();
      return;
    }

    final exprPretty = _prettyInfixExpression();
    final resStr = DisplayFormat.formatResult(result);

    _frozenExpression = exprPretty.isEmpty ? DisplayFormat.formatOperand(_sanitizeNumber(_current)) : exprPretty;
    _frozenResult = resStr;
    _afterEquals = true;
    _chunks.clear();
    _current = _unformat(resStr);
    _dotMatrixOp = ExpressionEvaluator.lastBinaryOperatorSymbol(
      exprPretty.replaceAll(' ', ''),
    );

    final meaningful = ExpressionEvaluator.hasBinaryOperation(full);
    if (meaningful) {
      await _glyph.onEqualsPerformed(operation: _dotMatrixOp);
    } else {
      _dotMatrixOp = null;
    }

    notifyListeners();
  }

  void clearAll() {
    _history.clear();
    _chunks.clear();
    _current = '0';
    _afterEquals = false;
    _clearFrozen();
    _dotMatrixOp = null;
    notifyListeners();
  }

  void delete() {
    if (_afterEquals) {
      _afterEquals = false;
      _clearFrozen();
      _current = '0';
      _chunks.clear();
      notifyListeners();
      return;
    }
    if (_current.length > 1) {
      _current = _current.substring(0, _current.length - 1);
      if (_current == '-') _current = '0';
    } else {
      _current = '0';
    }
    notifyListeners();
  }

  void inputPercent() {
    _commitFrozenToHistoryIfNeeded();
    if (_afterEquals) {
      _afterEquals = false;
      _clearFrozen();
    }
    final v = double.tryParse(_sanitizeNumber(_current)) ?? 0;
    _current = _stripTrailingZeros((v / 100).toString());
    notifyListeners();
  }

  /// Scientific: unary operations on the current operand (degrees for trig).
  void applyUnaryScientific(String id) {
    if (!_scientificMode) return;
    _commitFrozenToHistoryIfNeeded();
    if (_afterEquals) {
      _afterEquals = false;
      _clearFrozen();
    }
    final v = double.tryParse(_sanitizeNumber(_current)) ?? 0;
    late final double r;
    if (id == 'sin') {
      r = math.sin(v * math.pi / 180);
    } else if (id == 'cos') {
      r = math.cos(v * math.pi / 180);
    } else if (id == 'tan') {
      r = math.tan(v * math.pi / 180);
    } else if (id == 'ln') {
      r = math.log(v);
    } else if (id == 'log') {
      r = math.log(v) / math.ln10;
    } else if (id == 'sqrt') {
      r = math.sqrt(v);
    } else {
      return;
    }
    if (!r.isFinite) {
      _current = '0';
      notifyListeners();
      return;
    }
    _current = _stripTrailingZeros(r.toString());
    _chunks.clear();
    notifyListeners();
  }

  /// Scientific: insert `^` as power — uses current as left, next number as right after equals or op.
  void insertScientificOperator(String ascii) {
    if (!_scientificMode) return;
    inputOperator(_uiFromAscii(ascii));
  }

  void _commitFrozenToHistoryIfNeeded() {
    if (_frozenExpression != null &&
        _frozenResult != null &&
        _frozenResult != 'Error') {
      _history.add(
        HistoryEntry(
          expression: _frozenExpression!,
          result: _frozenResult!,
        ),
      );
    }
    _clearFrozen();
  }

  void _clearFrozen() {
    _frozenExpression = null;
    _frozenResult = null;
  }

  String _evalString() {
    final b = StringBuffer();
    for (final c in _chunks) {
      b.write(c);
    }
    b.write(_sanitizeNumber(_current));
    return b.toString();
  }

  String _prettyInfixExpression() {
    if (_chunks.isEmpty) {
      return '';
    }
    final b = StringBuffer();
    for (var i = 0; i < _chunks.length; i++) {
      if (i.isEven) {
        b.write(DisplayFormat.formatOperand(_chunks[i]));
      } else {
        b.write(' ');
        b.write(_uiOperator(_chunks[i]));
        b.write(' ');
      }
    }
    b.write(DisplayFormat.formatOperand(_current));
    return b.toString().trim();
  }

  static String _sanitizeNumber(String raw) {
    var s = raw.replaceAll(',', '');
    if (s == '.' || s == '-.') {
      s = s.startsWith('-') ? '-0.' : '0.';
    }
    if (s.isEmpty) return '0';
    return s;
  }

  static String _unformat(String formatted) {
    return formatted.replaceAll(',', '');
  }

  static String _stripTrailingZeros(String s) {
    if (s.contains('e') || s.contains('E')) return s;
    if (!s.contains('.')) return s;
    var t = s;
    while (t.endsWith('0')) {
      t = t.substring(0, t.length - 1);
    }
    if (t.endsWith('.')) t = t.substring(0, t.length - 1);
    return t.isEmpty ? '0' : t;
  }

  static bool _isAsciiOperator(String s) {
    return s == '+' || s == '-' || s == '*' || s == '/' || s == '^';
  }

  static String _toAsciiOperator(String ui) {
    return switch (ui) {
      '×' => '*',
      '÷' => '/',
      '−' => '-',
      '^' => '^',
      '+' => '+',
      _ => ui,
    };
  }

  static String _uiOperator(String ascii) {
    return switch (ascii) {
      '*' => '×',
      '/' => '÷',
      '-' => '−',
      '^' => '^',
      _ => ascii,
    };
  }

  static String _uiFromAscii(String ascii) {
    return switch (ascii) {
      '*' => '×',
      '/' => '÷',
      '-' => '−',
      _ => ascii,
    };
  }
}
