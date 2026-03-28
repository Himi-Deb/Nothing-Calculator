<<<<<<< HEAD
# Nothing-Calculator
Nothing design inspired calculator application.
=======
# Nothing Calculator

**Nothing Calculator** (internal design name: **Calci-App**) is a dark-themed calculator built with Flutter. It matches a minimalist Nothing-style UI: pure black background, white numerals, and red accents for operators and the primary **equals** key.

## What it does

- **Basic mode (default)** — Standard four-function layout: **AC**, **%**, **flask** (switches scientific mode), **÷**, number pad **0–9**, decimal, **delete**, column of **× − + =**, and a large result area.
- **Scientific mode** — Tap the **flask** icon to reveal two extra rows (trig, log, power, etc.) and a dot indicator under the flask. Unary functions (sin, cos, tan, ln, log, √, inverse) operate on the current value; **^** is available for powers where the expression parser supports it.
- **Display** — The bottom line shows the **active** value (what you are typing or the last result) in large white type with a red “decimal dot” style where decimals appear. Above it, a **grey expression line** shows the full in-progress formula. Completed calculations move into a **scrollable history**: older lines sit toward the top and use **progressively darker grey** so the stack reads clearly.
- **Feedback** — Buttons use light **haptic** taps. **Nothing Glyph** lighting is abstracted behind a `GlyphFeedback` interface (default **no-op**); you can plug in hardware integration on supported Nothing phones later.
- **Math engine** — Expressions are evaluated with the [`math_expressions`](https://pub.dev/packages/math_expressions) package, not hand-rolled parsing.

## Tech stack

| Layer | Role |
|--------|------|
| **Flutter** | UI: display, keypad, theming |
| **ChangeNotifier** (`CalculatorController`) | State: expression chunks, history, basic vs scientific |
| **math_expressions** | Parse and evaluate arithmetic strings on **=** |
| **nothing_glyph_interface** | Optional; reserved for future Glyph LED hooks on Android |

Glassmorphism was intentionally **not** used—the UI follows the flat, high-contrast reference screens.

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel recommended)
- For **Android**: Android SDK / `local.properties` (see below)
- For **web**: Chrome or any modern browser

## Run the app

```bash
# Install dependencies
flutter pub get

# List devices (Android emulator, Chrome, etc.)
flutter devices

# Mobile
flutter run

# Web (Chrome)
flutter run -d chrome
```

### Android setup

Copy `local.properties.example` to `local.properties` and set:

- `sdk.dir` — path to your Android SDK  
- `flutter.sdk` — path to your Flutter SDK  

## Test

```bash
flutter test
```

## Project layout (high level)

- `lib/main.dart` — App entry and theme  
- `lib/features/calculator/` — Screen, controller, keypad, display widgets  
- `lib/core/theme/` — Colors and layout tokens  
- `lib/glyph/` — Glyph feedback abstraction  
- `assets/fonts/` — Drop custom `.ttf` files here and declare them in `pubspec.yaml` if you add a bespoke typeface  

## License

Add a license file when you publish this repository if you intend to share it publicly.
>>>>>>> 336113a (Initial commit: Nothing Calculator (Calci-App) Flutter app)
