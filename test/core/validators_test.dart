import 'package:fintrack/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('title validation', () {
    expect(Validators.title(null), isNotNull);
    expect(Validators.title('   '), isNotNull);
    expect(Validators.title('a' * 61), isNotNull);
    expect(Validators.title('Groceries'), isNull);
  });

  test('amount validation', () {
    for (final bad in ['', 'abc', '0', '0.00', '-10', '1.234']) {
      expect(Validators.amount(bad), isNotNull, reason: bad);
    }
    for (final good in ['10', '1,250.75', '0.01']) {
      expect(Validators.amount(good), isNull, reason: good);
    }
  });

  test('notes validation', () {
    expect(Validators.notes(null), isNull);
    expect(Validators.notes('n' * 201), isNotNull);
  });

  test('email and password validation', () {
    for (final bad in [null, '', 'abc', 'a@b', '@b.com', 'a b@c.com']) {
      expect(Validators.email(bad), isNotNull, reason: '$bad');
    }
    expect(Validators.email('user@example.com'), isNull);
    expect(Validators.password(''), isNotNull);
    expect(Validators.password('12345'), isNotNull);
    expect(Validators.password('123456'), isNull);
  });
}
