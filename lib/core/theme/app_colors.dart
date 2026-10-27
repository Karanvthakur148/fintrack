import 'package:flutter/material.dart';

/// Raw brand palette. Prefer [FinColors] / ColorScheme in widgets so that
/// light and dark themes stay consistent.
abstract final class AppColors {
  static const Color primary = Color(0xFF0F9D6B);

  static const Color incomeLight = Color(0xFF0F9D6B);
  static const Color incomeDark = Color(0xFF3DDC97);

  static const Color expenseLight = Color(0xFFD64545);
  static const Color expenseDark = Color(0xFFFF7B7B);

  static const Color warningLight = Color(0xFFC77700);
  static const Color warningDark = Color(0xFFFFB84D);

  static const Color scaffoldLight = Color(0xFFF4F8F6);
  static const Color scaffoldDark = Color(0xFF0D1411);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF16201B);
}

/// Picks black or white, whichever is readable on [background].
Color onColorFor(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : Colors.black;
}

/// Semantic finance colors that adapt to the active theme.
@immutable
class FinColors extends ThemeExtension<FinColors> {
  const FinColors({
    required this.income,
    required this.expense,
    required this.warning,
    required this.heroStart,
    required this.heroEnd,
    required this.onHero,
  });

  final Color income;
  final Color expense;
  final Color warning;
  final Color heroStart;
  final Color heroEnd;
  final Color onHero;

  static const FinColors light = FinColors(
    income: AppColors.incomeLight,
    expense: AppColors.expenseLight,
    warning: AppColors.warningLight,
    heroStart: Color(0xFF12B37A),
    heroEnd: Color(0xFF0A6E4B),
    onHero: Colors.white,
  );

  static const FinColors dark = FinColors(
    income: AppColors.incomeDark,
    expense: AppColors.expenseDark,
    warning: AppColors.warningDark,
    heroStart: Color(0xFF0F7A55),
    heroEnd: Color(0xFF083D2B),
    onHero: Colors.white,
  );

  @override
  FinColors copyWith({
    Color? income,
    Color? expense,
    Color? warning,
    Color? heroStart,
    Color? heroEnd,
    Color? onHero,
  }) {
    return FinColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      warning: warning ?? this.warning,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      onHero: onHero ?? this.onHero,
    );
  }

  @override
  FinColors lerp(ThemeExtension<FinColors>? other, double t) {
    if (other is! FinColors) return this;
    return FinColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      onHero: Color.lerp(onHero, other.onHero, t)!,
    );
  }
}

extension FinColorsContext on BuildContext {
  /// Finance semantic colors for the current theme.
  FinColors get finColors =>
      Theme.of(this).extension<FinColors>() ?? FinColors.light;
}
