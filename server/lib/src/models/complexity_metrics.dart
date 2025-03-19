/// Represents the complexity metrics for a method or function.
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

  /// Creates a JSON representation of the metrics
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'cognitiveComplexity': cognitiveComplexity,
      'nestingLevel': nestingLevel,
      'numberOfParameters': numberOfParameters,
      'lineCount': lineCount,
      'startPosition': startPosition,
      'endPosition': endPosition,
      'complexityCategory': complexityCategory,
      'riskAssessment': riskAssessment,
      'refactoringSuggestions': refactoringSuggestions,
    };
  }
}
