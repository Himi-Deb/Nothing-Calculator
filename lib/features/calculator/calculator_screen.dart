import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_layout.dart';
import 'controller/calculator_controller.dart';
import 'widgets/calculator_display.dart';
import 'widgets/calculator_keypad.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({
    super.key,
    required this.controller,
  });

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

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

/// Portrait: display stacked above keypad.
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

/// Landscape: display on the left half, keypad on the right half.
class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({required this.controller});
  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left: display panel
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CalculatorDisplay(controller: controller),
              ),
            ],
          ),
        ),
        // Vertical divider
        Container(width: 1, color: AppColors.divider),
        // Right: keypad panel
        Expanded(
          flex: 1,
          child: CalculatorKeypad(controller: controller),
        ),
      ],
    );
  }
}
