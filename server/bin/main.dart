import 'dart:async';
import 'dart:io';
import 'package:dart_mind/code_complexity.dart';
import 'package:lsp_server/lsp_server.dart';

Future<void> main(List<String> arguments) async {
  final server = Connection(stdin, stdout);
  final Map<String, String> documentContents = {};

  server.onInitialize((params) async {
    return InitializeResult(
      capabilities: ServerCapabilities(
        textDocumentSync: const Either2.t1(TextDocumentSyncKind.Full),
        codeLensProvider: CodeLensOptions(resolveProvider: false),
        // hoverProvider: Either2.t1(true),
      ),
    );
  });

  server.onDidOpenTextDocument((params) async {
    documentContents[params.textDocument.uri.toString()] =
        params.textDocument.text;
  });

  server.onDidChangeTextDocument((params) async {
    final uri = params.textDocument.uri;
    final textChanges = params.contentChanges
        .map((change) =>
            TextDocumentItem.fromJson(change as Map<String, dynamic>))
        .toList();

    if (params.contentChanges.isNotEmpty) {
      documentContents[uri.toString()] = textChanges.first.text;
    }
  });

  server.onDidCloseTextDocument((params) async {
    documentContents.remove(params.textDocument.uri.toString());
  });

  server.onCodeLens((CodeLensParams params) async {
    final uri = params.textDocument.uri;
    final text = documentContents[uri.toString()];

    if (text == null) return [];

    final results = getComplexity(text);
    final codeLenses = <CodeLens>[];

    for (final metric in results.values) {
      final startLine = _getLineFromOffset(text, metric.startPosition);

      codeLenses.add(
        CodeLens(
          range: Range(
            start: Position(line: startLine, character: 0),
            end: Position(line: startLine, character: 0),
          ),
          command: Command(
            title: metric.riskAssessment,
            command: "complexity.showComplexity",
            arguments: [
              {
                'name': metric.name,
                'type': metric.type,
                'complexityCategory': metric.complexityCategory,
                'cognitiveComplexity': metric.cognitiveComplexity,
                'nestingLevel': metric.nestingLevel,
                'numberOfParameters': metric.numberOfParameters,
                'refactoringSuggestions': metric.refactoringSuggestions,
              }
            ],
          ),
        ),
      );
    }

    return codeLenses;
  });

  // server.onHover((params) async {
  //   final uri = params.textDocument.uri;
  //   final text = documentContents[uri.toString()];

  //   if (text == null) return Future.error('No text found for document');

  //   final offset = params.position.toOffset(text);
  //   final line = _getLineFromOffset(text, offset);

  //   final results = getComplexity(text);
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
  //         - **Line Count:** ${metric.lineCount}
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

int _getLineFromOffset(String text, int offset) {
  int line = 0;

  for (int i = 0; i < offset && i < text.length; i++) {
    if (text[i] == '\n') {
      line++;
    }
  }

  return line;
}