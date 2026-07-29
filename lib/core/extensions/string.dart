// String extensions: ergonomic helpers for content normalization.

extension StringX on String {
  /// Returns true if the string is blank or whitespace-only.
  bool get isBlank => trim().isEmpty;

  /// Returns true if the string is non-empty after trimming.
  bool get isNotBlank => !isBlank;

  /// Truncates to [max] chars and adds ellipsis if longer.
  String truncate(int max) {
    if (length <= max) return this;
    return '${substring(0, max - 1)}…';
  }

  /// Capitalizes the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Removes all whitespace (used to normalize barcodes).
  String get stripWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Removes all non-digit characters.
  String get digitsOnly => replaceAll(RegExp(r'[^\d]'), '');

  /// Returns true if this is a valid hexadecimal color.
  bool get isHexColor => RegExp(r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$').hasMatch(this);

  /// Parses a hex color string (#RRGGBB or #AARRGGBB).
  int toHexColor() {
    var hex = replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }
}

extension NullableStringX on String? {
  bool get isNullOrBlank => this == null || this!.isBlank;
  String orEmpty() => this ?? '';
  String orDefault(String def) => (isNullOrBlank) ? def : this!;
}
