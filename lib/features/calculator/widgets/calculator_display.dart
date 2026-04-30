import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controller/calculator_controller.dart';

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
        final isEditing = !controller.afterEquals;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // History list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  reverse: true,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final e = history[history.length - 1 - index];
                    final tone =
                        _historyTone(history.length - 1 - index, history.length);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _SelectableDisplayText(
                            text: e.expression,
                            style: AppTypography.displayHistoryExpression(tone),
                          ),
                          const SizedBox(height: 4),
                          _SelectableDisplayText(
                            text: e.result,
                            style: AppTypography.displayHistoryResult(tone),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Secondary line (frozen expression after equals)
              if (controller.secondaryLine.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SelectableDisplayText(
                    text: controller.secondaryLine,
                    style: AppTypography.displaySecondary(
                        AppColors.historyGreyNewest),
                    textAlign: TextAlign.right,
                  ),
                ),
              // Primary result line + blinking cursor
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _SelectableDisplayText(
                        text: controller.primaryLine,
                        style: AppTypography.primaryResult(),
                        textAlign: TextAlign.right,
                        isPrimary: true,
                      ),
                    ),
                    if (isEditing) const _BlinkingCursor(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

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

// ─────────────────────────────────────────────
// Blinking red cursor
// ─────────────────────────────────────────────
class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> {
  bool _visible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted) setState(() => _visible = !_visible);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 80),
      child: Container(
        width: 2.5,
        height: 40,
        margin: const EdgeInsets.only(left: 3),
        decoration: BoxDecoration(
          color: AppColors.accentRed,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Selectable text with custom context menu
// (Select All, Copy, Cut, Share)
// ─────────────────────────────────────────────
class _SelectableDisplayText extends StatelessWidget {
  const _SelectableDisplayText({
    required this.text,
    required this.style,
    this.textAlign = TextAlign.right,
    this.isPrimary = false,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: style,
      textAlign: textAlign,
      contextMenuBuilder: (context, editableTextState) {
        return _buildContextMenu(context, editableTextState);
      },
    );
  }

  Widget _buildContextMenu(
      BuildContext context, EditableTextState editableTextState) {
    final selection = editableTextState.textEditingValue.selection;
    final hasSelection = selection.isValid && !selection.isCollapsed;
    final selectedText = hasSelection
        ? text.substring(selection.start, selection.end)
        : text;

    final items = <ContextMenuButtonItem>[
      ContextMenuButtonItem(
        label: 'Select All',
        onPressed: () {
          editableTextState.selectAll(SelectionChangedCause.toolbar);
          ContextMenuController.removeAny();
        },
      ),
      ContextMenuButtonItem(
        label: 'Copy',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: selectedText));
          ContextMenuController.removeAny();
        },
      ),
      ContextMenuButtonItem(
        label: 'Share',
        onPressed: () {
          ContextMenuController.removeAny();
          Share.share(selectedText);
        },
      ),
    ];

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: items,
    );
  }
}
