import 'package:fintrack/core/constants/app_currency.dart';
import 'package:intl/intl.dart';

/// Formats minor-unit amounts for display. Formatters are cached per currency.
abstract final class CurrencyFormatter {
  static final Map<AppCurrency, NumberFormat> _full = {};
  static final Map<AppCurrency, NumberFormat> _compact = {};

  /// e.g. `123456789` with INR -> `₹12,34,567.89`.
  static String format(int minor, AppCurrency currency) {
    final formatter = _full.putIfAbsent(
      currency,
      () => NumberFormat.currency(
        locale: currency.locale,
        symbol: currency.symbol,
        decimalDigits: 2,
      ),
    );
    return formatter.format(minor / 100);
  }

  /// Short form for chart axes, e.g. `₹1.2K`.
  static String formatCompact(int minor, AppCurrency currency) {
    final formatter = _compact.putIfAbsent(
      currency,
      () => NumberFormat.compactCurrency(
        locale: currency.locale,
        symbol: currency.symbol,
        decimalDigits: 1,
      ),
    );
    return formatter.format(minor / 100);
  }
}
