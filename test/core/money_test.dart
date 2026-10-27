import 'package:fintrack/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.parse', () {
    test('parses whole numbers', () => expect(Money.parse('1234'), 123400));
    test('parses one decimal', () => expect(Money.parse('1234.5'), 123450));
    test('parses two decimals', () => expect(Money.parse('0.99'), 99));
    test('ignores separators and spaces', () {
      expect(Money.parse(' 1,234.50 '), 123450);
    });
    test('is exact where doubles are not', () {
      expect(Money.parse('0.10')! + Money.parse('0.20')!, 30);
      expect(Money.parse('19.99'), 1999);
    });
    test('rejects invalid input', () {
      expect(Money.parse('1.999'), isNull);
      expect(Money.parse(''), isNull);
      expect(Money.parse('abc'), isNull);
      expect(Money.parse('-5'), isNull);
      expect(Money.parse('1.'), isNull);
      expect(Money.parse('1e5'), isNull);
      expect(Money.parse('9' * 13), isNull);
    });
  });

  group('Money.toPlainString', () {
    test('formats values', () {
      expect(Money.toPlainString(123450), '1234.50');
      expect(Money.toPlainString(5), '0.05');
      expect(Money.toPlainString(-250), '-2.50');
    });
    test('round-trips', () {
      expect(Money.parse(Money.toPlainString(987654)), 987654);
    });
  });

  test('Money.ratio is safe for zero denominators', () {
    expect(Money.ratio(25, 100), 0.25);
    expect(Money.ratio(10, 0), 0);
    expect(Money.ratio(10, -5), 0);
  });
}
