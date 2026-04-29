/// Layout constants tuned to the shared Calci-App references (edge-to-edge keypad).
abstract final class AppLayout {
  static const double displayFraction = 0.40;
  static const double scientificDisplayFraction = 0.28;
  /// Flush to screen edges; no outer gutter around the keypad.
  static const double keypadEdgeInset = 0;
  static const double keyGap = 0;
  static const double headerIconSize = 26;
  /// Fixed height per scientific row so AnimatedSize can expand cleanly (portrait).
  static const double scientificRowHeight = 64;
  /// Fixed width of the basic keypad in landscape (never changes regardless of sci mode).
  static const double landscapeKeypadWidth = 360;
  /// Width of the landscape scientific side-panel (2 columns of buttons).
  static const double landscapeScientificPanelWidth = 180;
}
