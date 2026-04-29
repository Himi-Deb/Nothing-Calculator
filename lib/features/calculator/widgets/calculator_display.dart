import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controller/calculator_controller.dart';
import 'primary_result_text.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    super.key,
    required this.controller,
  });

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final history = controller.history;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  reverse: true,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    // index 0 is the bottom-most item in the reversed list.
                    // We want the newest history entry (history.last) to be at the bottom.
                    final e = history[history.length - 1 - index];
                    final tone = _historyTone(history.length - 1 - index, history.length);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            e.expression,
                            style: AppTypography.displayHistoryExpression(tone),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e.result,
                            style: AppTypography.displayHistoryResult(tone),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (controller.secondaryLine.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    controller.secondaryLine,
                    style: AppTypography.displaySecondary(AppColors.historyGreyNewest),
                    textAlign: TextAlign.right,
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: PrimaryResultText(text: controller.primaryLine),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  /// Oldest entries (top of list) use darker grey; newest history lines are lighter.
  static Color _historyTone(int indexFromTop, int total) {
    if (total <= 1) {
      return Color.lerp(
        AppColors.historyGreyOldest,
        AppColors.historyGreyNewest,
        0.45,
      )!;
    }
    final t = indexFromTop / (total - 1);
    return Color.lerp(AppColors.historyGreyOldest, AppColors.historyGreyNewest, t)!;
  }
}
