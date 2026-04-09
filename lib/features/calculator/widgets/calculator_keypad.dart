import 'package:flutter/material.dart';

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
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                Expanded(child: rows[i]),
                if (i != rows.length - 1 && AppLayout.keyGap > 0)
                  SizedBox(height: AppLayout.keyGap),
              ],
            ],
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
          _sciLabel(
            child: NothingButton(
              label: 'INV',
              foregroundColor: AppColors.activeText,
              onPressed: controller.applyInverse,
            ),
            caption: '1/x',
          ),
          _sciLabel(
            child: NothingButton(
              label: 'SIN',
              foregroundColor: AppColors.activeText,
              onPressed: () => controller.applyUnaryScientific('sin'),
            ),
            caption: 'sin',
          ),
          _sciLabel(
            child: NothingButton(
              label: 'COS',
              foregroundColor: AppColors.activeText,
              onPressed: () => controller.applyUnaryScientific('cos'),
            ),
            caption: 'cos',
          ),
          _sciLabel(
            child: NothingButton(
              label: 'TAN',
              foregroundColor: AppColors.activeText,
              onPressed: () => controller.applyUnaryScientific('tan'),
            ),
            caption: 'tan',
          ),
          _sciLabel(
            child: NothingButton(
              label: '^',
              foregroundColor: AppColors.activeText,
              onPressed: () => controller.insertScientificOperator('^'),
            ),
            caption: 'pow',
          ),
        ],
      ),
      _keypadRow(
        flexes: const [1, 1, 1, 1, 1],
        children: [
          _sciLabel(
            child: NothingButton(
              label: 'LN',
              foregroundColor: AppColors.activeText,
              onPressed: () => controller.applyUnaryScientific('ln'),
            ),
            caption: 'ln',
          ),
          _sciLabel(
            child: NothingButton(
              label: 'LOG',
              foregroundColor: AppColors.activeText,
              onPressed: () => controller.applyUnaryScientific('log'),
            ),
            caption: 'log',
          ),
          _sciLabel(
            child: NothingButton(
              label: '√',
              foregroundColor: AppColors.activeText,
              onPressed: () => controller.applyUnaryScientific('sqrt'),
            ),
            caption: 'sqrt',
          ),
          _sciLabel(
            child: NothingButton(
              label: '(',
              foregroundColor: AppColors.activeText,
              onPressed: null,
            ),
            caption: 'left',
          ),
          _sciLabel(
            child: NothingButton(
              label: ')',
              foregroundColor: AppColors.activeText,
              onPressed: null,
            ),
            caption: 'right',
          ),
        ],
      ),
    ];
  }

  Widget _sciLabel({required Widget child, required String caption}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Center(child: child)),
        const SizedBox(height: 2),
        SizedBox(
          height: 18,
          child: Text(
            caption,
            style: AppTypography.scientificCaption(AppColors.historyGreyOldest),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
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
