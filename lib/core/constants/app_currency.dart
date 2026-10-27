/// Supported display currencies.
///
/// This is a display preference only. Stored amounts are never converted.
enum AppCurrency {
  inr(code: 'INR', symbol: '₹', locale: 'en_IN', label: 'Indian Rupee'),
  usd(code: 'USD', symbol: r'$', locale: 'en_US', label: 'US Dollar');

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.locale,
    required this.label,
  });

  final String code;
  final String symbol;

  /// Locale used for digit grouping (e.g. lakh grouping for INR).
  final String locale;
  final String label;

  /// Safe lookup from a persisted [code]; falls back to [inr].
  static AppCurrency fromCode(String? code) {
    for (final currency in AppCurrency.values) {
      if (currency.code == code) return currency;
    }
    return AppCurrency.inr;
  }
}
