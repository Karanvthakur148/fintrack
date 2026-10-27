import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/app_router.dart';
import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/constants/app_currency.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/core/widgets/app_snackbar.dart';
import 'package:fintrack/core/widgets/confirm_dialog.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_event.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_state.dart';
import 'package:fintrack/features/settings/domain/entities/app_settings.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_event.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen: (p, c) => c.message != null && p.message != c.message,
      listener: (context, state) {
        showAppSnackBar(context, state.message!, isError: state.messageIsError);
        context.read<SettingsBloc>().add(const SettingsMessageDismissed());
      },
      builder: (context, state) {
        final bloc = context.read<SettingsBloc>();

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            children: [
              const _AccountSection(),
              const SizedBox(height: AppSpacing.lg),
              _Section(
                title: 'Appearance',
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AppThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_rounded),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_rounded),
                      ),
                    ],
                    selected: {state.settings.themeMode},
                    onSelectionChanged: (s) =>
                        bloc.add(SettingsThemeModeChanged(s.first)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Section(
                title: 'Currency',
                child: Column(
                  children: [
                    for (final currency in AppCurrency.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(
                            currency.symbol,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text('${currency.label} (${currency.code})'),
                        trailing: currency == state.settings.currency
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () => bloc.add(SettingsCurrencyChanged(currency)),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        'Changing the currency only changes how amounts are '
                        'displayed. Stored amounts are not converted.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Section(
                title: 'Data',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: !state.isClearing,
                  leading: Icon(
                    Icons.delete_forever_rounded,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Clear all app data',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: const Text(
                    'Deletes every transaction and budget (also from the '
                    'cloud when signed in).',
                  ),
                  trailing: state.isClearing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: 'Clear all data?',
                      message:
                          'All transactions and budgets will be permanently '
                          'deleted, including your cloud copy if you are '
                          'signed in. This cannot be undone.',
                      confirmLabel: 'Delete everything',
                      destructive: true,
                    );
                    if (confirmed) {
                      bloc.add(const SettingsClearDataRequested());
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Section(
                title: 'About',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text(AppConstants.appName),
                  subtitle: const Text('Version ${AppConstants.appVersion}'),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: AppConstants.appName,
                    applicationVersion: AppConstants.appVersion,
                    applicationIcon: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 36,
                    ),
                    children: const [
                      Text(
                        '${AppConstants.appTagline}. All of your data is '
                        'stored on this device and works without internet.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) => c.message != null && p.message != c.message,
      listener: (context, state) {
        showAppSnackBar(context, state.message!, isError: state.messageIsError);
        context.read<AuthBloc>().add(const AuthMessageDismissed());
      },
      builder: (context, state) {
        final Widget content;
        if (!state.isAvailable) {
          content = const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.cloud_off_rounded),
            title: Text('Cloud sync not set up'),
            subtitle: Text(
              'Your data stays on this device. See FIREBASE_SETUP.md to '
              'enable backup and sync.',
            ),
          );
        } else if (state.user == null) {
          content = ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cloud_upload_rounded),
            title: const Text('Sign in to back up & sync'),
            subtitle: const Text(
              'Right now your data is stored only on this device.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRoutes.auth),
          );
        } else {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(state.user!.email),
                subtitle: const Text('Backed up and synced across your devices'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: state.busy
                    ? null
                    : () async {
                        final bloc = context.read<AuthBloc>();
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'Sign out?',
                          message:
                              'Data on this device will be removed. It stays '
                              'safe in your account and returns when you sign '
                              'in again.',
                          confirmLabel: 'Sign out',
                          destructive: true,
                        );
                        if (confirmed) bloc.add(const AuthSignOutRequested());
                      },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ],
          );
        }
        return _Section(title: 'Account', child: content);
      },
    );
  }
}
