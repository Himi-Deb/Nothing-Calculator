import 'package:flutter/foundation.dart';

/// Abstraction over Nothing Glyph hardware. Use [GlyphFeedback.noop] in tests/emulators.
abstract class GlyphFeedback {
  const GlyphFeedback();

  static const GlyphFeedback noop = _GlyphNoop();

  /// Called after a successful `=` when there was a real binary operation to evaluate.
  Future<void> onEqualsPerformed({String? operation});
}

final class _GlyphNoop extends GlyphFeedback {
  const _GlyphNoop();

  @override
  Future<void> onEqualsPerformed({String? operation}) async {}
}
