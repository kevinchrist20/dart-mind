import 'package:analyzer/dart/analysis/utilities.dart';
import '../models/complexity_metrics.dart';
import '../visitors/method_visitor.dart';

/// Analyzes the complexity of Dart code
class CodeComplexityAnalyzer {
  /// Analyzes a string of Dart code and returns complexity metrics
  static Map<String, MethodComplexityMetrics> analyze(String code) {
    final parseResult = parseString(content: code);
    final visitor = MethodVisitor();
    
    // Visit all nodes in the AST
    parseResult.unit.visitChildren(visitor);
    
    // Process results and generate refactoring suggestions
    return visitor.analyzeCollectedMethods();
  }
}
