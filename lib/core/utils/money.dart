/// Money helpers. All monetary values in FinTrack are `int` **minor units**
/// (paise / cents), so arithmetic is exact. Conversion to a decimal string
/// happens only at the UI edge.
abstract final class Money {
  /// Largest supported whole-unit digit count (keeps values well inside int).
  static const int maxWholeDigits = 12;

  static final RegExp _pattern = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$');

  /// Parses user input such as `1234`, `1,234.5` or `0.99` into minor units.
  ///
  /// Returns `null` when the input is empty, negative, has more than two
  /// decimal places, or is otherwise invalid. No floating-point math is used.
  static int? parse(String input) {
    final cleaned = input.trim().replaceAll(',', '');
    final match = _pattern.firstMatch(cleaned);
    if (match == null) return null;

    final whole = match.group(1)!;
    if (whole.length > maxWholeDigits) return null;

    final fraction = (match.group(2) ?? '').padRight(2, '0');
    return int.parse(whole) * 100 + int.parse(fraction);
  }

  /// Converts minor units to an editable plain string, e.g. `123450 -> "1234.50"`.
  static String toPlainString(int minor) {
    final negative = minor < 0;
    final abs = minor.abs();
    final whole = abs ~/ 100;
    final fraction = (abs % 100).toString().padLeft(2, '0');
    return '${negative ? '-' : ''}$whole.$fraction';
  }

  /// Safe ratio `part / whole`. Returns `0` when [whole] is zero or negative.
  static double ratio(int part, int whole) {
    if (whole <= 0) return 0;
    return part / whole;
  }
}
