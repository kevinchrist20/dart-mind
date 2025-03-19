import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

Map<String, MethodComplexityMetrics> getComplexity(String code) {
  final parseCodeResult = parseString(content: code);

  final functionVisitor = MethodNameVisitor();
  parseCodeResult.unit.visitChildren(functionVisitor);

  return functionVisitor.analyzeCollectedMethods();
}

class MethodComplexityMetrics {
  final String name;
  final String type; // 'method' or 'function'
  int cognitiveComplexity = 0;
  int nestingLevel = 0;
  int numberOfParameters = 0;
  int lineCount = 0;
  int startPosition = 0;
  int endPosition = 0;
  String complexityCategory = '';
  String riskAssessment = '';
  List<String> refactoringSuggestions = [];

  MethodComplexityMetrics(this.name, this.type);
}

class MethodNameVisitor extends RecursiveAstVisitor<void> {
  List<MethodDeclaration> methods = [];
  Map<String, MethodComplexityMetrics> methodMetrics = {};

  // Current scope tracking
  MethodDeclaration? currentMethod;
  FunctionDeclaration? currentFunction;
  int currentNestingLevel = 0;

  MethodNameVisitor();

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final metrics = MethodComplexityMetrics(node.name.toString(), 'method');
    metrics.numberOfParameters = node.parameters?.parameters.length ?? 0;
    metrics.startPosition = node.offset;
    metrics.endPosition = node.end;

    methodMetrics[node.name.toString()] = metrics;
    currentMethod = node;
    currentFunction = null; // Clear any function context
    super.visitMethodDeclaration(node);
    currentMethod = null;
    currentNestingLevel = 0;
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final metrics = MethodComplexityMetrics(node.name.toString(), 'function');

    // Get parameters from the function's expression
    if (node.functionExpression.parameters != null) {
      metrics.numberOfParameters =
          node.functionExpression.parameters!.parameters.length;
    }

    metrics.startPosition = node.offset;
    metrics.endPosition = node.end;
    methodMetrics[node.name.toString()] = metrics;
    currentFunction = node;
    currentMethod = null; // Clear any method context
    super.visitFunctionDeclaration(node);
    currentFunction = null;
    currentNestingLevel = 0;
  }

  // ------------------------
  // Control structures
  // ------------------------

  @override
  void visitIfStatement(IfStatement node) {
    _incrementComplexity(1);

    if (currentNestingLevel > 0) {
      _incrementComplexity(currentNestingLevel); // add nesting cost
    }

    currentNestingLevel++;
    super.visitIfStatement(node);
    currentNestingLevel--;
  }

  @override
  void visitForStatement(ForStatement node) {
    _incrementComplexity(1);
    if (currentNestingLevel > 0) {
      _incrementComplexity(currentNestingLevel);
    }
    currentNestingLevel++;
    super.visitForStatement(node);
    currentNestingLevel--;
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _incrementComplexity(1);
    if (currentNestingLevel > 0) {
      _incrementComplexity(currentNestingLevel);
    }
    currentNestingLevel++;
    super.visitWhileStatement(node);
    currentNestingLevel--;
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _incrementComplexity(1);
    if (currentNestingLevel > 0) {
      _incrementComplexity(currentNestingLevel);
    }
    currentNestingLevel++;
    super.visitSwitchStatement(node);
    currentNestingLevel--;
  }

  @override
  void visitTryStatement(TryStatement node) {
    _incrementComplexity(1);
    if (currentNestingLevel > 0) {
      _incrementComplexity(currentNestingLevel);
    }
    currentNestingLevel++;
    super.visitTryStatement(node);
    currentNestingLevel--;
  }

  // ------------------------
  // Boolean Operators
  // ------------------------
  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node.operator.type.lexeme == '&&' ||
        node.operator.type.lexeme == '||') {
      _incrementComplexity(1);
    }
    super.visitBinaryExpression(node);
  }

  // ------------------------
  // Jump Statements
  // ------------------------
  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (_isInMethodInvocation(node)) {
      super.visitFunctionExpression(node);
      return;
    }

    if (currentMethod != null || currentFunction != null) {
      _incrementComplexity(2); // Higher penalty for nested functions

      currentNestingLevel++;
      super.visitFunctionExpression(node);
      currentNestingLevel--;
    } else {
      super.visitFunctionExpression(node);
    }
  }

  @override
  void visitBreakStatement(BreakStatement node) {
    _incrementComplexity(1);
    super.visitBreakStatement(node);
  }

  @override
  void visitContinueStatement(ContinueStatement node) {
    _incrementComplexity(1);
    super.visitContinueStatement(node);
  }

  @override
  void visitThrowExpression(ThrowExpression node) {
    _incrementComplexity(1);
    super.visitThrowExpression(node);
  }

  void _incrementComplexity(int amount) {
    if (currentMethod != null) {
      var metrics = methodMetrics[currentMethod!.name.toString()]!;
      metrics.cognitiveComplexity += amount;

      if (currentNestingLevel > metrics.nestingLevel) {
        metrics.nestingLevel = currentNestingLevel;
      }
    } else if (currentFunction != null) {
      var metrics = methodMetrics[currentFunction!.name.toString()]!;
      metrics.cognitiveComplexity += amount;

      if (currentNestingLevel > metrics.nestingLevel) {
        metrics.nestingLevel = currentNestingLevel;
      }
    }
  }

  /// Determines if a function expression is used as an argument in a method call
  /// For example, in list.map((e) => e * 2), the lambda is in a method invocation
  bool _isInMethodInvocation(FunctionExpression node) {
    // Check if the parent (or grandparent) is a MethodInvocation
    var parent = node.parent;

    // Handle direct parent as method invocation
    if (parent is ArgumentList && parent.parent is MethodInvocation) {
      return true;
    }

    // Handle parent as expression in argument list
    if (parent is Expression &&
        parent.parent is ArgumentList &&
        parent.parent?.parent is MethodInvocation) {
      return true;
    }

    if (parent is FunctionDeclaration) {
      return true;
    }

    return false;
  }

  // ------------------------
  // Analysis summary
  // ------------------------
  Map<String, MethodComplexityMetrics> analyzeCollectedMethods() {
    for (var entry in methodMetrics.entries) {
      if (entry.value.cognitiveComplexity > 15) {
        entry.value.complexityCategory = "High";
        entry.value.riskAssessment =
            "❌ High Complexity (Score: ${entry.value.cognitiveComplexity}) - Refactor recommended!";
      } else if (entry.value.cognitiveComplexity > 8) {
        entry.value.complexityCategory = "Medium";
        entry.value.riskAssessment =
            "⚠️ Medium Complexity (Score: ${entry.value.cognitiveComplexity}) - Consider simplifying this ${entry.value.type}";
      } else {
        entry.value.complexityCategory = "Low";
        entry.value.riskAssessment =
            "✅ Low Complexity (Score: ${entry.value.cognitiveComplexity}) - Everything looks good!";
      }

      _generateRefactoringSuggestions(entry.value);
    }

    return methodMetrics;
  }

  void _generateRefactoringSuggestions(MethodComplexityMetrics metrics) {
    List<String> suggestions = [];

    // Suggestions based on complexity score
    if (metrics.cognitiveComplexity > 15) {
      suggestions.add("Consider breaking '${metrics.name}' into multiple smaller ${metrics.type}s with single responsibilities.");
      suggestions.add("Refactor complex conditional logic into separate helper ${metrics.type}s with descriptive names.");
    }

    // Suggestions based on nesting level
    if (metrics.nestingLevel > 3) {
      suggestions.add("Reduce nesting depth (currently at level ${metrics.nestingLevel}) by using early returns or guard clauses.");
      suggestions.add("Extract deeply nested code into well-named helper ${metrics.type}s.");
    }

    // Suggestions based on number of parameters
    if (metrics.numberOfParameters > 4) {
      suggestions.add("Reduce the number of parameters (currently ${metrics.numberOfParameters}) by grouping related parameters into objects.");
      suggestions.add("Consider using the Builder pattern to make parameter passing more readable.");
    }

    // General suggestions based on complexity
    if (metrics.cognitiveComplexity > 8) {
      suggestions.add("Use more descriptive variable names to improve readability.");
      suggestions.add("Add comments to explain complex logic or business rules.");
      suggestions.add("Look for repeated code patterns that could be extracted into reusable functions.");
    }

    // Store the suggestions in the metrics object
    metrics.refactoringSuggestions = suggestions;
  }
}
