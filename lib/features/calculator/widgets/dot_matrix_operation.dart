import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Compact “dot matrix” style hint for the active binary operation after `=`.
class DotMatrixOperation extends StatelessWidget {
  const DotMatrixOperation({
    super.key,
    this.symbol,
  });

  final String? symbol;

  @override
  Widget build(BuildContext context) {
    if (symbol == null || symbol!.isEmpty) {
      return const SizedBox.shrink();
    }
    return CustomPaint(
      painter: _DotMatrixGridPainter(),
      foregroundPainter: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          symbol!,
          style: const TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 22,
            color: AppColors.accentRed,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _DotMatrixGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.05);
    const step = 6.0;
    for (var y = 0.0; y < size.height; y += step) {
      for (var x = 0.0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.8, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
