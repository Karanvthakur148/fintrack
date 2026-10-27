import 'package:flutter/material.dart';

/// Shows a floating snackbar, replacing any visible one.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: isError ? scheme.error : null,
        content: Text(
          message,
          style: isError ? TextStyle(color: scheme.onError) : null,
        ),
      ),
    );
}
