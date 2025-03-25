# DartMind

DartMind is an intelligent VS Code extension that provides real-time code analysis for Dart and Flutter projects. It helps developers write cleaner, more maintainable code by analyzing cognitive complexity, detecting code smells, and offering performance insights.

## Features

DartMind offers several powerful features to improve your Dart and Flutter development workflow:

### Code Complexity Analysis

Visualize the cognitive complexity of your Dart code directly in your editor:

- Color-coded complexity indicators in the editor margin
- Detailed breakdown of complexity factors
- Suggestions for simplifying complex methods

### Code Smell Detection

Identify potential code smells and anti-patterns in your codebase:

- Highlights code that may be difficult to maintain
- Detects common Flutter performance pitfalls
- Suggests best practices for cleaner code

### Performance Insights

Get real-time feedback on potential performance issues:

- Identifies expensive operations in build methods
- Highlights unnecessary widget rebuilds
- Suggests performance optimizations

## Requirements

- VS Code 1.60.0 or higher
- Dart SDK
- Flutter SDK (for Flutter projects)

## Extension Settings

DartMind contributes the following settings:

- `codeComplexity.enabled`: Enable/disable code complexity analysis (default: true)

## Commands

- `dartmind.showComplexity`: Show detailed code complexity analysis for the current file

## Usage

1. Open a Dart or Flutter project in VS Code
2. The extension automatically activates when you open a Dart file
3. Code complexity indicators will appear in the editor margin
4. Hover over indicators for more details
5. Use the command palette (`Ctrl+Shift+P` or `Cmd+Shift+P`) and select "Show Code Complexity" for a detailed analysis

## Known Issues

- Currently optimized for smaller files; may have performance issues with very large Dart files

## Release Notes

### 0.0.1

Initial release of DartMind with:

- Basic code complexity analysis
- Code margin indicators
- "Show Code Complexity" command

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This extension is licensed under the MIT License.

**Enjoy writing cleaner Dart code!**
