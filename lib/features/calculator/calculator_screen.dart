import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_layout.dart';
import 'controller/calculator_controller.dart';
import 'widgets/calculator_display.dart';
import 'widgets/calculator_keypad.dart';
import 'widgets/nothing_button.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({
    super.key,
    required this.controller,
  });

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isLandscape
            ? _LandscapeLayout(controller: controller)
            : _PortraitLayout(controller: controller),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PORTRAIT: display stacked above keypad
// ─────────────────────────────────────────────
class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({required this.controller});
  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final targetHeight = h *
            (controller.scientificMode
                ? AppLayout.scientificDisplayFraction
                : AppLayout.displayFraction);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutQuart,
              height: targetHeight,
              child: CalculatorDisplay(controller: controller),
            ),
            Container(height: 1, color: AppColors.divider),
            Expanded(
              child: CalculatorKeypad(controller: controller),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// LANDSCAPE: display | [sci panel] | keypad
// Scientific panel expands leftward into display
// space — basic keypad always stays full width.
// ─────────────────────────────────────────────
class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({required this.controller});
  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final sci = controller.scientificMode;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display — fills all remaining space
            Expanded(
              child: CalculatorDisplay(controller: controller),
            ),
            Container(width: 1, color: AppColors.divider),
            // Scientific panel slides in from the right of the display
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutQuart,
              alignment: Alignment.centerLeft,
              child: sci
                  ? _LandscapeScientificPanel(controller: controller)
                  : const SizedBox.shrink(),
            ),
            // Basic keypad — fixed width, never changes
            SizedBox(
              width: AppLayout.landscapeKeypadWidth,
              child: CalculatorKeypad(controller: controller),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// LANDSCAPE SCIENTIFIC PANEL
// 2 columns × 5 rows, aligns with basic keypad rows
// ─────────────────────────────────────────────
class _LandscapeScientificPanel extends StatelessWidget {
  const _LandscapeScientificPanel({required this.controller});
  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppLayout.landscapeScientificPanelWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row([
            _sciBtn('INV', '1/x', controller.applyInverse),
            _sciBtn('^', 'pow', () => controller.insertScientificOperator('^'),
                scale: 1.25),
          ]).animate().fade(duration: 250.ms, curve: Curves.easeIn),
          _row([
            _sciBtn('SIN', 'sin', () => controller.applyUnaryScientific('sin')),
            _sciBtn('LN', 'ln', () => controller.applyUnaryScientific('ln')),
          ]).animate().fade(duration: 270.ms, curve: Curves.easeIn),
          _row([
            _sciBtn('COS', 'cos', () => controller.applyUnaryScientific('cos')),
            _sciBtn('LOG', 'log', () => controller.applyUnaryScientific('log')),
          ]).animate().fade(duration: 290.ms, curve: Curves.easeIn),
          _row([
            _sciBtn('TAN', 'tan', () => controller.applyUnaryScientific('tan')),
            _sciBtn('√', 'sqrt', () => controller.applyUnaryScientific('sqrt')),
          ]).animate().fade(duration: 310.ms, curve: Curves.easeIn),
          _row([
            _sciBtn('(', 'left', () => controller.inputBracket('(')),
            _sciBtn(')', 'right', () => controller.inputBracket(')')),
          ]).animate().fade(duration: 330.ms, curve: Curves.easeIn),
        ].map((w) => Expanded(child: w)).toList(),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children.map((c) => Expanded(child: c)).toList(),
    );
  }

  Widget _sciBtn(String label, String caption, VoidCallback onPressed,
      {double? scale}) {
    return NothingButton(
      label: label,
      caption: caption,
      scale: scale,
      foregroundColor: AppColors.activeText,
      onPressed: onPressed,
    );
  }
}
