import 'package:lsp_server/lsp_server.dart';
import '../analyzers/code_complexity_analyzer.dart';
import '../models/complexity_metrics.dart';
import '../utils/position_utils.dart';

/// Service for managing document-related operations
class DocumentService {
  final Map<String, String> _documentContents = {};

  /// Add or update a document's content
  void updateDocument(String uri, String content) {
    _documentContents[uri] = content;
  }

  /// Remove a document's content
  void removeDocument(String uri) {
    _documentContents.remove(uri);
  }

  /// Get a document's content
  String? getDocumentContent(String uri) {
    return _documentContents[uri];
  }

  /// Analyze a document and return complexity metrics
  Map<String, MethodComplexityMetrics> analyzeDocument(String uri) {
    final content = _documentContents[uri];
    if (content == null) {
      return {};
    }

    return CodeComplexityAnalyzer.analyze(content);
  }

  /// Generate CodeLens items for a document
  List<CodeLens> generateCodeLenses(String uri) {
    final text = _documentContents[uri];
    if (text == null) {
      return [];
    }

    final results = CodeComplexityAnalyzer.analyze(text);
    final codeLenses = <CodeLens>[];

    for (final metric in results.values) {
      final startLine = PositionUtils.getLineFromOffset(text, metric.startPosition);

      codeLenses.add(
        CodeLens(
          range: Range(
            start: Position(line: startLine, character: 0),
            end: Position(line: startLine, character: 0),
          ),
          command: Command(
            title: metric.riskAssessment,
            command: "dartmind.showComplexity",
            arguments: [metric.toJson()],
          ),
        ),
      );
    }

    return codeLenses;
  }
}
