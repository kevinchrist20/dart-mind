import 'dart:async';
import 'dart:io';
import 'package:dart_mind/code_complexity.dart';
import 'package:lsp_server/lsp_server.dart';

Future<void> main(List<String> arguments) async {
  final server = Connection(stdin, stdout);

  server.onInitialize((params) async {
    return InitializeResult(
      capabilities: ServerCapabilities(
        textDocumentSync: const Either2.t1(TextDocumentSyncKind.Full),
        diagnosticProvider: Either2.t1(DiagnosticRegistrationOptions(
          interFileDependencies: false,
          workspaceDiagnostics: false,
        )),
      ),
    );
  });

  server.onDidOpenTextDocument((params) async {
    await analyzeAndSendDiagnostics(server, params.textDocument);
  });

  await server.listen();
}

Future<void> analyzeAndSendDiagnostics(
  Connection server,
  TextDocumentItem document,
) async {
  final results = getComplexity(document.text);
  final diagnostics = <Diagnostic>[];

  for (final metric in results.values) {
    final startPosition = document.positionAt(metric.startPosition);
    final endPosition = document.positionAt(metric.endPosition);

    diagnostics.add(
      Diagnostic(
        range: Range(
          start: startPosition,
          end: endPosition,
        ),
        severity: _getSeverity(metric.cognitiveComplexity),
        source: 'code-complexity',
        message:
            'Complexity: ${metric.cognitiveComplexity} - ${metric.riskAssessment}',
        code: 'complexity',
      ),
    );
  }

  server.sendDiagnostics(
    PublishDiagnosticsParams(
      uri: document.uri,
      diagnostics: diagnostics,
    ),
  );
}

DiagnosticSeverity _getSeverity(int complexity) {
  if (complexity > 15) return DiagnosticSeverity.Error;
  if (complexity > 10) return DiagnosticSeverity.Warning;
  return DiagnosticSeverity.Information;
}
