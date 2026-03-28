import 'package:flutter_test/flutter_test.dart';
import 'package:nothing_calculator/main.dart';

void main() {
  testWidgets('App loads calculator shell', (tester) async {
    await tester.pumpWidget(const NothingCalculatorApp());
    expect(find.text('AC'), findsOneWidget);
  });
}
