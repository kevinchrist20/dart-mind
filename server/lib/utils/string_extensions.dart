/// Extensions for String class
extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    return this.isNotEmpty
        ? '${this[0].toUpperCase()}${this.substring(1)}'
        : '';
  }
}
