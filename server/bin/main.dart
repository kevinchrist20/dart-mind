import 'dart:async';
import 'dart:io';
import 'package:lsp_server/lsp_server.dart';
import 'package:dart_mind/dart_mind.dart';

Future<void> main(List<String> arguments) async {
  final server = Connection(stdin, stdout);
  final documentService = DocumentService();

  server.onInitialize((params) async {
    return InitializeResult(
      capabilities: ServerCapabilities(
        textDocumentSync: const Either2.t1(TextDocumentSyncKind.Full),
        codeLensProvider: CodeLensOptions(resolveProvider: false),
        // Uncomment to enable hover support
        // hoverProvider: Either2.t1(true),
      ),
    );
  });

  server.onDidOpenTextDocument((params) async {
    documentService.updateDocument(
      params.textDocument.uri.toString(),
      params.textDocument.text,
    );
  });

  server.onDidChangeTextDocument((params) async {
    final uri = params.textDocument.uri.toString();
    final textChanges = params.contentChanges
        .map((change) =>
            TextDocumentItem.fromJson(change as Map<String, dynamic>))
        .toList();

    if (params.contentChanges.isNotEmpty) {
      documentService.updateDocument(uri, textChanges.first.text);
    }
  });

  server.onDidCloseTextDocument((params) async {
    documentService.removeDocument(params.textDocument.uri.toString());
  });

  server.onCodeLens((CodeLensParams params) async {
    final uri = params.textDocument.uri.toString();
    return documentService.generateCodeLenses(uri);
  });

  // Uncomment to enable hover support
  // server.onHover((params) async {
  //   final uri = params.textDocument.uri.toString();
  //   final text = documentService.getDocumentContent(uri);

  //   if (text == null) return Future.error('No text found for document');

  //   final offset = PositionUtils.getOffsetFromPosition(text, params.position);
  //   final line = PositionUtils.getLineFromOffset(text, offset);

  //   final results = CodeComplexityAnalyzer.analyze(text);
  //   final hoverResults = results.values.where((metric) {
  //     return metric.startPosition <= offset && metric.endPosition >= offset;
  //   });

  //   if (hoverResults.isEmpty) return Future.error('No complexity found');

  //   final metric = hoverResults.first;

  //   return Hover(
  //     contents: Either2.t1(
  //       MarkupContent(kind: MarkupKind.Markdown, value: '''
  //         # ${metric.name}

  //         - **Type:** ${metric.type}
  //         - **Complexity Category:** ${metric.complexityCategory}
  //         - **Cognitive Complexity:** ${metric.cognitiveComplexity}
  //         - **Nesting Level:** ${metric.nestingLevel}
  //         - **Number of Parameters:** ${metric.numberOfParameters}
  //         - **Risk Assessment:** ${metric.riskAssessment}
  //         '''),
  //     ),
  //     range: Range(
  //       start: Position(line: line, character: 0),
  //       end: Position(line: line, character: 0),
  //     ),
  //   );
  // });

  await server.listen();
}