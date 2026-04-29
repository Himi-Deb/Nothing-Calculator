import 'package:math_expressions/math_expressions.dart';

void main() {
  final parser = Parser();
  final exp1 = parser.parse("ln(10)");
  final exp2 = parser.parse("log(10, 100)");
  final exp3 = parser.parse("sqrt(9)");
  
  print("ln(10) = ${exp1.evaluate(EvaluationType.REAL, ContextModel())}");
  print("log(10, 100) = ${exp2.evaluate(EvaluationType.REAL, ContextModel())}");
  print("sqrt(9) = ${exp3.evaluate(EvaluationType.REAL, ContextModel())}");
}
