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
  bool get afterEquals => _afterEquals;

  void toggleScientific() {
    _scientificMode = !_scientificMode;
    notifyListeners();
  }

  /// Grey line: expression / frozen expression / history context.
  String get secondaryLine {
    if (_afterEquals && _frozenExpression != null) {
      return _frozenExpression!;
    }
    // We don't show secondaryLine while inputting anymore (moved to primaryLine).
    return '';
  }

  /// White line: full expression during input, or final result.
  String get primaryLine {
    if (_afterEquals && _frozenResult != null) {
      return _frozenResult!;
    }
    final exp = _prettyInfixExpression();
    return exp.isEmpty ? DisplayFormat.formatOperand(_current) : exp;
  }

  void inputDigit(String d) {
    if (d.length != 1 || !RegExp(r'[0-9]').hasMatch(d)) return;
    _commitFrozenToHistoryIfNeeded();
    if (_afterEquals) {
      _clearFrozen();
      _chunks.clear();
      _afterEquals = false;
    }
    if (_current.length >= 15) return;
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
      _current = '0';
      _chunks.clear();
    }
    
    if (_current != '0') {
      _chunks.add(_sanitizeNumber(_current));
      _chunks.add('*');
      _current = '0';
    } else if (_chunks.isNotEmpty && _chunks.last == ')') {
      _chunks.add('*');
    }
    
    _chunks.add('1/(');
    notifyListeners();
  }

  void inputOperator(String uiOp) {
    _commitFrozenToHistoryIfNeeded();
    if (_afterEquals) {
      _afterEquals = false;
      _clearFrozen();
    }

    final ascii = _toAsciiOperator(uiOp);

    if (_chunks.isNotEmpty && _current == '0') {
      final last = _chunks.last;
      if (_isAsciiOperator(last)) {
        _chunks[_chunks.length - 1] = ascii;
        notifyListeners();
        return;
      }
      if (last == ')') {
        _chunks.add(ascii);
        notifyListeners();
        return;
      }
    }

    final n = _sanitizeNumber(_current);
    _chunks.add(n);
    _chunks.add(ascii);
    _current = '0';
    notifyListeners();
  }

  void inputBracket(String bracket) {
    if (!_scientificMode) return;
    _commitFrozenToHistoryIfNeeded();
    if (_afterEquals) {
      _afterEquals = false;
      _clearFrozen();
      _current = '0';
      _chunks.clear();
    }
    
    // Focus active typing buffer to memory string
    if (_current != '0') {
      _chunks.add(_sanitizeNumber(_current));
      _current = '0';
    }

    _chunks.add(bracket);
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
    
    if (_current != '0') {
      if (_current.length > 1) {
        _current = _current.substring(0, _current.length - 1);
        if (_current == '-') _current = '0';
      } else {
        _current = '0';
      }
    } else if (_chunks.isNotEmpty) {
      final last = _chunks.removeLast();
      if (_isAsciiOperator(last) || last == '(' || last == ')') {
        if (_chunks.isNotEmpty && !_isAsciiOperator(_chunks.last) && _chunks.last != '(' && _chunks.last != ')' && !_chunks.last.contains('(')) {
          _current = _chunks.removeLast();
        }
      } else if (last.contains('(')) {
        // e.g. "sin(", "ln(". Just remove it, _current remains '0'.
      } else {
        // Number chunk
        if (last.length > 1) {
          _current = last.substring(0, last.length - 1);
          if (_current == '-') _current = '0';
        }
      }
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

  void applyUnaryScientific(String id) {
    if (!_scientificMode) return;
    _commitFrozenToHistoryIfNeeded();
    if (_afterEquals) {
      _afterEquals = false;
      _clearFrozen();
      _current = '0';
      _chunks.clear();
    }
    
    if (_current != '0') {
      _chunks.add(_sanitizeNumber(_current));
      _chunks.add('*');
      _current = '0';
    } else if (_chunks.isNotEmpty && _chunks.last == ')') {
      _chunks.add('*');
    }
    
    _chunks.add('$id(');
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
    if (_chunks.isNotEmpty && _chunks.last == ')' && _current == '0') {
      // Avoid appending floating zero after a closed bracket bracket.
    } else {
      b.write(_sanitizeNumber(_current));
    }
    return b.toString();
  }

  String _prettyInfixExpression() {
    if (_chunks.isEmpty) {
      return '';
    }
    final b = StringBuffer();
    for (var c in _chunks) {
      if (_isAsciiOperator(c)) {
        b.write(' ');
        b.write(_uiOperator(c));
        b.write(' ');
      } else if (c == '(' || c == ')' || RegExp(r'[a-zA-Z]').hasMatch(c)) {
        if (c == 'sqrt(') {
          b.write('√(');
        } else {
          b.write(c);
        }
      } else {
        b.write(DisplayFormat.formatOperand(c));
      }
    }
    // Only show current if it was edited or if it's the last part.
    if (_current != '0' || _chunks.isEmpty) {
      b.write(DisplayFormat.formatOperand(_current));
    }
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
