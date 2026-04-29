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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final sci = controller.scientificMode;

        return isLandscape
            ? _buildLandscape(sci)
            : _buildPortrait(sci);
      },
    );
  }

  // ─────────────────────────────────────────────
  // PORTRAIT: scientific rows slide in above keypad
  // ─────────────────────────────────────────────
  Widget _buildPortrait(bool sci) {
    return Padding(
      padding: const EdgeInsets.all(AppLayout.keypadEdgeInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutQuart,
            alignment: Alignment.topCenter,
            child: sci
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _scientificRowsPortrait()
                        .map((row) => SizedBox(
                            height: AppLayout.scientificRowHeight, child: row))
                        .toList(),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _basicRows()
                  .map((row) => Expanded(child: row))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LANDSCAPE: scientific panel slides in from the left
  // ─────────────────────────────────────────────
  Widget _buildLandscape(bool sci) {
    return Padding(
      padding: const EdgeInsets.all(AppLayout.keypadEdgeInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scientific panel: AnimatedSize collapses width when hidden
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutQuart,
            alignment: Alignment.centerLeft,
            child: sci
                ? Row(
                    children: [
                      SizedBox(
                        width: AppLayout.landscapeScientificPanelWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _scientificColumnsLandscape()
                              .map((row) => Expanded(child: row))
                              .toList(),
                        ),
                      ),
                      Container(
                        width: 1,
                        color: AppColors.divider,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          // Basic keypad always takes remaining width
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _basicRows()
                  .map((row) => Expanded(child: row))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PORTRAIT scientific rows: 2 rows × 5 buttons
  // ─────────────────────────────────────────────
  List<Widget> _scientificRowsPortrait() {
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
            scale: 1.25,
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.insertScientificOperator('^'),
          ),
        ],
      ).animate().fade(duration: 250.ms, curve: Curves.easeIn),
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
      ).animate().fade(duration: 300.ms, curve: Curves.easeIn),
    ];
  }

  // ─────────────────────────────────────────────
  // LANDSCAPE scientific panel: 5 rows × 2 columns
  // Aligns row-for-row with the 5 basic keypad rows
  // ─────────────────────────────────────────────
  List<Widget> _scientificColumnsLandscape() {
    return [
      // Row 1 (aligns with AC/% row)
      _keypadRow(
        flexes: const [1, 1],
        children: [
          NothingButton(
            label: 'INV',
            caption: '1/x',
            foregroundColor: AppColors.activeText,
            onPressed: controller.applyInverse,
          ),
          NothingButton(
            label: '^',
            caption: 'pow',
            scale: 1.25,
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.insertScientificOperator('^'),
          ),
        ],
      ).animate().fade(duration: 250.ms, curve: Curves.easeIn),
      // Row 2 (aligns with 7/8/9 row)
      _keypadRow(
        flexes: const [1, 1],
        children: [
          NothingButton(
            label: 'SIN',
            caption: 'sin',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('sin'),
          ),
          NothingButton(
            label: 'LN',
            caption: 'ln',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('ln'),
          ),
        ],
      ).animate().fade(duration: 270.ms, curve: Curves.easeIn),
      // Row 3 (aligns with 4/5/6 row)
      _keypadRow(
        flexes: const [1, 1],
        children: [
          NothingButton(
            label: 'COS',
            caption: 'cos',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('cos'),
          ),
          NothingButton(
            label: 'LOG',
            caption: 'log',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('log'),
          ),
        ],
      ).animate().fade(duration: 290.ms, curve: Curves.easeIn),
      // Row 4 (aligns with 1/2/3 row)
      _keypadRow(
        flexes: const [1, 1],
        children: [
          NothingButton(
            label: 'TAN',
            caption: 'tan',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('tan'),
          ),
          NothingButton(
            label: '√',
            caption: 'sqrt',
            foregroundColor: AppColors.activeText,
            onPressed: () => controller.applyUnaryScientific('sqrt'),
          ),
        ],
      ).animate().fade(duration: 310.ms, curve: Curves.easeIn),
      // Row 5 (aligns with 0/./= row)
      _keypadRow(
        flexes: const [1, 1],
        children: [
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
      ).animate().fade(duration: 330.ms, curve: Curves.easeIn),
    ];
  }

  // ─────────────────────────────────────────────
  // Basic keypad rows (shared by both orientations)
  // ─────────────────────────────────────────────
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
