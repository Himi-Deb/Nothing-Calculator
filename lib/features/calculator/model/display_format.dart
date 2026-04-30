import 'package:intl/intl.dart';

/// Locale-style grouping for the Calci-App display (commas, optional decimals).
abstract final class DisplayFormat {
  static final NumberFormat _groupInt = NumberFormat('#,##0', 'en_US');
  static final NumberFormat _groupFrac = NumberFormat('#,##0.##########', 'en_US');

  /// Formats a raw operand string while typing (`1240`, `3.`, `0.5`, `sin(`).
  static String formatOperand(String raw) {
    if (raw.isEmpty) return '0';
    // If the token is a function or algebraic component, return it as-is
    if (RegExp(r'[a-zA-Z(]').hasMatch(raw)) return raw;

    var s = raw.replaceAll(',', '');
    final neg = s.startsWith('-');
    if (neg) s = s.substring(1);
    if (s.isEmpty) return neg ? '-0' : '0';

    final dot = s.indexOf('.');
    final intPart = dot == -1 ? s : s.substring(0, dot);
    final frac = dot == -1 ? '' : s.substring(dot + 1);

    final intVal = int.tryParse(intPart.isEmpty ? '0' : intPart) ?? 0;
    var out = _groupInt.format(intVal);
    if (dot != -1) {
      out += '.';
      out += frac;
    }
    return neg ? '-$out' : out;
  }

  /// Formats a numeric result (matches reference: integers without `.00`, else decimals).
  static String formatResult(double value) {
    if (value.isNaN || !value.isFinite) return 'Error';
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 1e-12 && value.abs() < 1e15) {
      return _groupInt.format(rounded.toInt());
    }
    return _groupFrac.format(value);
  }

  /// Raw numeric string without grouping (for evaluation buffers).
  static String formatRawNumber(String rawDigits) {
    return rawDigits.replaceAll(',', '');
  }
}
