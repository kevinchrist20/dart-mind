import 'package:analyzer/dart/analysis/utilities.dart';
import 'metrics.dart';
import 'visitor.dart';

/// Analyzes the complexity of functions and methods in Dart code.
class ComplexityAnalyzer {
  /// Analyzes Dart code and returns complexity metrics for each method or function.
  static Map<String, MethodComplexityMetrics> analyze(String code) {
    final parseCodeResult = parseString(content: code);

    final functionVisitor = MethodNameVisitor();
    parseCodeResult.unit.visitChildren(functionVisitor);

    return functionVisitor.analyzeCollectedMethods();
  }
}
