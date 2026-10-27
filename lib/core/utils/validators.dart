import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/utils/money.dart';

/// Form validators. Each returns an error message, or `null` when valid.
abstract final class Validators {
  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter a title';
    if (text.length > AppConstants.maxTitleLength) {
      return 'Title is too long (max ${AppConstants.maxTitleLength} characters)';
    }
    return null;
  }

  static String? amount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter an amount';
    final minor = Money.parse(text);
    if (minor == null) return 'Enter a valid amount (up to 2 decimals)';
    if (minor <= 0) return 'Amount must be greater than zero';
    return null;
  }

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email';
    if (!_email.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Please enter a password';
    if (text.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? notes(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > AppConstants.maxNotesLength) {
      return 'Notes are too long (max ${AppConstants.maxNotesLength} characters)';
    }
    return null;
  }
}
