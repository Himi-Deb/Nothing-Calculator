import 'package:math_expressions/math_expressions.dart';

void main() {
  final parser = Parser();
  try {
    final exp = parser.parse("sin(45");
    print("Parsed sin(45: ${exp.evaluate(EvaluationType.REAL, ContextModel())}");
  } catch (e) {
    print("Error parsing sin(45: $e");
  }
  
  try {
    final exp2 = parser.parse("sin(45)");
    print("Parsed sin(45): ${exp2.evaluate(EvaluationType.REAL, ContextModel())}");
  } catch (e) {
    print("Error parsing sin(45): $e");
  }
}
