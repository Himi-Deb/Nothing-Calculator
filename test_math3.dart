import 'package:math_expressions/math_expressions.dart';

void main() {
  final parser = Parser();
  try { print("log10(100) = ${parser.parse("log10(100)").evaluate(EvaluationType.REAL, ContextModel())}"); } catch(e) { print(e); }
  try { print("log(100) = ${parser.parse("log(100)").evaluate(EvaluationType.REAL, ContextModel())}"); } catch(e) { print(e); }
}
