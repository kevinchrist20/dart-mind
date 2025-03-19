import 'package:lsp_server/lsp_server.dart';

extension StringExtension on String {
  String capitalize() {
    return this.isNotEmpty
        ? '${this[0].toUpperCase()}${this.substring(1)}'
        : '';
  }
}

extension TextDocumentPosition on TextDocumentItem {
  Position positionAt(int offset) {
    final lines = text.substring(0, offset).split('\n');
    final line = lines.length - 1;
    final character = lines.last.length;
    return Position(line: line, character: character);
  }
}

extension PositionOffset on Position {
  int toOffset(String text) {
    final lines = text.split('\n');
    final line = lines[this.line].substring(0, character);
    return lines.sublist(0, this.line).join('\n').length + line.length;
  }
}
