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
          hoverProvider: Either2.t1(true)),
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
              }
            ],
          ),
        ),
      );
    }

    return codeLenses;
  });

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

extension PositionOffset on Position {
  int toOffset(String text) {
    final lines = text.split('\n');
    final line = lines[this.line].substring(0, character);
    return lines.sublist(0, this.line).join('\n').length + line.length;
  }
}
