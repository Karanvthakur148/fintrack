import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats INR with lakh grouping', () {
    expect(CurrencyFormatter.format(123456789, AppCurrency.inr), '₹12,34,567.89');
  });

  test('formats USD with western grouping', () {
    expect(CurrencyFormatter.format(123456789, AppCurrency.usd), r'$1,234,567.89');
    expect(CurrencyFormatter.format(0, AppCurrency.usd), r'$0.00');
  });

  test('fromCode falls back to INR', () {
    expect(AppCurrency.fromCode('USD'), AppCurrency.usd);
    expect(AppCurrency.fromCode('XYZ'), AppCurrency.inr);
    expect(AppCurrency.fromCode(null), AppCurrency.inr);
  });
}
