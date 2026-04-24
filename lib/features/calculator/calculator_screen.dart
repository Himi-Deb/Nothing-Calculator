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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            return ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final targetHeight = h *
                    (controller.scientificMode
                        ? AppLayout.scientificDisplayFraction
                        : AppLayout.displayFraction);
                return Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutQuart,
                        height: targetHeight,
                        child: CalculatorDisplay(controller: controller),
                      ),
                      Container(
                        height: 1,
                        color: AppColors.divider,
                      ),
                      Expanded(
                        child: CalculatorKeypad(controller: controller),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
