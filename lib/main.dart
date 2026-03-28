import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/calculator/calculator_screen.dart';
import 'features/calculator/controller/calculator_controller.dart';
import 'glyph/glyph_feedback.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const NothingCalculatorApp());
}

class NothingCalculatorApp extends StatefulWidget {
  const NothingCalculatorApp({super.key});

  @override
  State<NothingCalculatorApp> createState() => _NothingCalculatorAppState();
}

class _NothingCalculatorAppState extends State<NothingCalculatorApp> {
  late final CalculatorController _controller =
      CalculatorController(glyph: GlyphFeedback.noop);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nothing Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        useMaterial3: true,
      ),
      home: CalculatorScreen(controller: _controller),
    );
  }
}
