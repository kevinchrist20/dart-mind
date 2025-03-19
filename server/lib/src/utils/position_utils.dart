import 'package:lsp_server/lsp_server.dart';

/// Utilities for handling document positions and offsets
class PositionUtils {
  /// Convert from offset to line number
  static int getLineFromOffset(String text, int offset) {
    int line = 0;

    for (int i = 0; i < offset && i < text.length; i++) {
      if (text[i] == '\n') {
        line++;
      }
    }

    return line;
  }

  /// Convert from line and character to offset
  static int getOffsetFromPosition(String text, Position position) {
    final lines = text.split('\n');
    if (position.line >= lines.length) {
      return text.length;
    }

    int offset = 0;
    for (int i = 0; i < position.line; i++) {
      offset += lines[i].length + 1; // +1 for the newline
    }

    return offset + Math.min(position.character, lines[position.line].length);
  }
}

/// Math utilities
class Math {
  static int min(int a, int b) => a < b ? a : b;
}
