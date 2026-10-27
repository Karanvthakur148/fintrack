import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/theme/app_colors.dart';
import 'package:fintrack/core/utils/currency_formatter.dart';

/// Visual treatment for an amount.
enum AmountTone { income, expense, neutral }

/// Displays a minor-unit amount in the selected currency, colored by [tone].
class AmountText extends StatelessWidget {
  const AmountText({
    required this.minor,
    required this.currency,
    super.key,
    this.tone = AmountTone.neutral,
    this.style,
  });

  final int minor;
  final AppCurrency currency;
  final AmountTone tone;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.finColors;
    final (Color? color, String prefix) = switch (tone) {
      AmountTone.income => (colors.income, '+'),
      AmountTone.expense => (colors.expense, '−'),
      AmountTone.neutral => (null, ''),
    };

    final value = tone == AmountTone.neutral ? minor : minor.abs();
    final text = '$prefix${CurrencyFormatter.format(value, currency)}';

    return Text(
      text,
      style: (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
