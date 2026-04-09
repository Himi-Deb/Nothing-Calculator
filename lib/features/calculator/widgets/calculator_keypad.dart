import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_layout.dart';
import '../../../core/theme/app_typography.dart';
import '../controller/calculator_controller.dart';
import 'nothing_button.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({
    super.key,
    required this.controller,
  });

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final sci = controller.scientificMode;
        final rows = <Widget>[
          if (sci) ..._scientificRows(),
          ..._basicRows(),
        ];
        return Padding(
          padding: const EdgeInsets.all(AppLayout.keypadEdgeInset),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final rowCount = sci ? 7 : 5;
              // Add a tiny bit of extra gap safely, or divide cleanly.
              final rowHeight = h / rowCount;
              
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        height: rowHeight,
                        child: rows[i],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _scientificRows() {
    return [
      _keypadRow(
        flexes: const [1, 1, 1, 1, 1],
        children: [
          NothingButton(
            label: 'INV',
            caption: '1/x',
            foregroundColor: AppColors.activeText,
            onPressed: controller.applyInverse,
          ),
          NothingButton(
            label: 'SIN',
            caption: 'sin',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('sin'),
          ),
          NothingButton(
            label: 'COS',
            caption: 'cos',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('cos'),
          ),
          NothingButton(
            label: 'TAN',
            caption: 'tan',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('tan'),
          ),
          NothingButton(
            label: '^',
            caption: 'pow',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.insertScientificOperator('^'),
          ),
        ],
      ).animate().fade(duration: 250.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
      _keypadRow(
        flexes: const [1, 1, 1, 1, 1],
        children: [
          NothingButton(
            label: 'LN',
            caption: 'ln',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('ln'),
          ),
          NothingButton(
            label: 'LOG',
            caption: 'log',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('log'),
          ),
          NothingButton(
            label: '√',
            caption: 'sqrt',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('sqrt'),
          ),
          NothingButton(
            label: '(',
            caption: 'left',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.inputBracket('('),
          ),
          NothingButton(
            label: ')',
            caption: 'right',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.inputBracket(')'),
          ),
        ],
      ).animate().fade(duration: 300.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
    ];
  }



  List<Widget> _basicRows() {
    return [
      _keypadRow(
        flexes: const [1, 1, 1, 1],
        children: [
          NothingButton(
            label: 'AC',
            foregroundColor: AppColors.accentRed,
            fontSize: AppTypography.keyCapSize - 2,
            onPressed: controller.clearAll,
          ),
          NothingButton(
            label: '%',
            foregroundColor: AppColors.accentRed,
            onPressed: controller.inputPercent,
          ),
          NothingButton(
            icon: Icons.science_outlined,
            foregroundColor: AppColors.accentRed,
            showFlaskDot: controller.scientificMode,
            onPressed: controller.toggleScientific,
          ),
          NothingButton(
            label: '÷',
            foregroundColor: AppColors.accentRed,
            onPressed: () => controller.inputOperator('÷'),
          ),
        ],
      ),
      _digitRow(['7', '8', '9'], '×'),
      _digitRow(['4', '5', '6'], '−'),
      _digitRow(['1', '2', '3'], '+'),
      _keypadRow(
        flexes: const [1, 1, 1, 1],
        children: [
          NothingButton(
            icon: Icons.backspace_outlined,
            foregroundColor: AppColors.activeText,
            onPressed: controller.delete,
          ),
          NothingButton(
            label: '0',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.inputDigit('0'),
          ),
          NothingButton(
            label: '.',
            foregroundColor: AppColors.activeText,
            onPressed: controller.inputDecimal,
          ),
          NothingButton(
            label: '=',
            foregroundColor: AppColors.activeText,
            backgroundColor: AppColors.accentRed,
            fontSize: AppTypography.keyCapSize * 1.4 * 1.25,
            onPressed: controller.equals,
          ),
        ],
      ),
    ];
  }

  Widget _digitRow(List<String> digits, String op) {
    return _keypadRow(
      flexes: const [1, 1, 1, 1],
      children: [
        NothingButton(
          label: digits[0],
          foregroundColor: AppColors.activeText,
          onPressed: () => controller.inputDigit(digits[0]),
        ),
        NothingButton(
          label: digits[1],
          foregroundColor: AppColors.activeText,
          onPressed: () => controller.inputDigit(digits[1]),
        ),
        NothingButton(
          label: digits[2],
          foregroundColor: AppColors.activeText,
          onPressed: () => controller.inputDigit(digits[2]),
        ),
        NothingButton(
          label: op,
          foregroundColor: AppColors.accentRed,
          onPressed: () => controller.inputOperator(op),
        ),
      ],
    );
  }

  Widget _keypadRow({
    required List<int> flexes,
    required List<Widget> children,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++)
          Expanded(
            flex: flexes[i],
            child: children[i],
          ),
      ],
    );
  }
}
