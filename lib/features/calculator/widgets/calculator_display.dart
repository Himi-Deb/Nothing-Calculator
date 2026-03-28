import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_layout.dart';
import '../controller/calculator_controller.dart';
import 'dot_matrix_operation.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.activeText),
                    iconSize: AppLayout.headerIconSize,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    onPressed: () {},
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final e = history[index];
                    final tone = _historyTone(index, history.length);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            e.expression,
                            style: TextStyle(
                              color: tone,
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              height: 1.25,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e.result,
                            style: TextStyle(
                              color: tone,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
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
                    style: const TextStyle(
                      color: AppColors.historyGreyNewest,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: PrimaryResultText(text: controller.primaryLine),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: DotMatrixOperation(symbol: controller.dotMatrixOperationSymbol),
              ),
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
