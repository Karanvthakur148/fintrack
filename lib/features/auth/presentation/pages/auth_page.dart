import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/theme/app_spacing.dart';
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/core/widgets/app_snackbar.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_event.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_state.dart';

/// Sign in / create account. Optional: the app works without an account.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isSignUp = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final bloc = context.read<AuthBloc>();
    if (_isSignUp) {
      bloc.add(AuthSignUpRequested(email: _email.text, password: _password.text));
    } else {
      bloc.add(AuthSignInRequested(email: _email.text, password: _password.text));
    }
  }

  void _forgotPassword() {
    final error = Validators.email(_email.text);
    if (error != null) {
      showAppSnackBar(context, 'Enter your email above first.', isError: true);
      return;
    }
    context.read<AuthBloc>().add(AuthPasswordResetRequested(_email.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.message != null) {
          showAppSnackBar(context, state.message!, isError: state.messageIsError);
          context.read<AuthBloc>().add(const AuthMessageDismissed());
        }
        if (state.isSignedIn) {
          Navigator.of(context).maybePop();
        }
      },
      builder: (context, state) {
        final busy = state.busy;
        return Scaffold(
          appBar: AppBar(title: Text(_isSignUp ? 'Create account' : 'Sign in')),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              Icon(
                Icons.cloud_sync_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Back up and sync your data',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your transactions and budgets stay available offline and '
                'sync across your devices when you are signed in.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (!state.isAvailable)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Cloud sync is not set up in this build yet. Follow '
                      'FIREBASE_SETUP.md, then restart the app.',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _email,
                      enabled: !busy && state.isAvailable,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _password,
                      enabled: !busy && state.isAvailable,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: _isSignUp
                          ? Validators.password
                          : (v) => (v == null || v.isEmpty)
                              ? 'Please enter your password'
                              : null,
                    ),
                  ],
                ),
              ),
              if (!_isSignUp)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: busy || !state.isAvailable ? null : _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: busy || !state.isAvailable ? null : _submit,
                child: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isSignUp ? 'Create account' : 'Sign in'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: busy ? null : () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign in'
                      : 'New here? Create an account',
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Continue without an account'),
              ),
            ],
          ),
        );
      },
    );
  }
}
