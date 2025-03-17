import 'dart:convert';
import 'dart:io';
import 'package:dart_mind/code_complexity.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    stderr.writeln('Error: Please provide a file path to analyze.');
    exit(1);
  }

  final filePath = arguments.first;
  
  try {
    final file = File(filePath);
    final code = file.readAsStringSync();
    
    final results = getComplexity(code);
    
    // Convert the results map to a list of objects
    final outputList = results.values.map((metric) => {
      'name': metric.name,
      'type': metric.type,
      'cognitiveComplexity': metric.cognitiveComplexity,
      'nestingLevel': metric.nestingLevel,
      'numberOfParameters': metric.numberOfParameters,
      'lineCount': metric.lineCount,
      'startPosition': metric.startPosition,
      'endPosition': metric.endPosition,
      'message': metric.riskAssessment,
      'category': metric.complexityCategory,
    }).toList();
    
    // Output as JSON
    print(jsonEncode(outputList));
  } catch (e) {
    stderr.writeln('Error analyzing file: $e');
    exit(1);
  }
}
