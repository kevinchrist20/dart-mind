import '../models/complexity_metrics.dart';

/// Utility class to generate refactoring suggestions based on code metrics
class RefactoringSuggestionGenerator {
  /// Generate and add refactoring suggestions to the metrics object
  static void generateSuggestions(MethodComplexityMetrics metrics) {
    List<String> suggestions = [];

    // Add suggestions based on complexity score
    if (metrics.cognitiveComplexity > 15) {
      suggestions.add("Consider breaking '${metrics.name}' into multiple smaller ${metrics.type}s with single responsibilities.");
      suggestions.add("Refactor complex conditional logic into separate helper ${metrics.type}s with descriptive names.");
    }

    // Add suggestions based on nesting level
    if (metrics.nestingLevel > 3) {
      suggestions.add("Reduce nesting depth (currently at level ${metrics.nestingLevel}) by using early returns or guard clauses.");
      suggestions.add("Extract deeply nested code into well-named helper ${metrics.type}s.");
    }

    // Add suggestions based on number of parameters
    if (metrics.numberOfParameters > 4) {
      suggestions.add("Reduce the number of parameters (currently ${metrics.numberOfParameters}) by grouping related parameters into objects.");
      suggestions.add("Consider using the Builder pattern to make parameter passing more readable.");
    }

    // Add general suggestions based on complexity
    if (metrics.cognitiveComplexity > 8) {
      suggestions.add("Use more descriptive variable names to improve readability.");
      suggestions.add("Add comments to explain complex logic or business rules.");
      suggestions.add("Look for repeated code patterns that could be extracted into reusable functions.");
    }

    // Store the suggestions in the metrics object
    metrics.refactoringSuggestions = suggestions;
  }
}
