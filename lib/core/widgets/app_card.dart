import 'package:flutter/material.dart';
import 'package:fintrack/core/theme/app_radii.dart';
import 'package:fintrack/core/theme/app_spacing.dart';

/// Rounded surface card with an optional tap handler and gradient.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.gradient,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// When set, replaces the solid card color (e.g. the balance hero card).
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadow = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.05);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadii.lgAll,
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Card(
        color: gradient == null ? null : Colors.transparent,
        shape: gradient == null
            ? null
            : const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
