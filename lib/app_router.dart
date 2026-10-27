import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/widgets/error_view.dart';
import 'package:fintrack/features/auth/presentation/pages/auth_page.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_type.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_bloc.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_event.dart';
import 'package:fintrack/features/transactions/presentation/pages/add_edit_transaction_page.dart';
import 'package:fintrack/home_shell.dart';
import 'package:fintrack/injection_container.dart';

import 'features/splash/presentation/pages/splash_page.dart';

abstract final class AppRoutes {
  static const String home = '/';

  /// Optional argument: a [TransactionType] to preselect.
  static const String addTransaction = '/transactions/add';

  /// Required argument: the transaction id (`String`).
  static const String editTransaction = '/transactions/edit';

  /// Optional sign in / create account screen.
  static const String auth = '/auth';
  static const String splash = '/splash';
}

abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.addTransaction:
        final args = settings.arguments;
        final type = args is TransactionType ? args : TransactionType.expense;
        return _slideUp(
          settings,
          _formPage(id: null, type: type),
        );
      case AppRoutes.editTransaction:
        final args = settings.arguments;
        if (args is! String || args.trim().isEmpty) {
          return _slideUp(
            settings,
            Scaffold(
              appBar: AppBar(),
              body: const ErrorView(message: 'Invalid transaction.'),
            ),
          );
        }
        return _slideUp(settings, _formPage(id: args, type: TransactionType.expense));
      case AppRoutes.auth:
        return _slideUp(settings, const AuthPage());
      case AppRoutes.splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => SplashPage(
            onFinished: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.home,
              );
            },
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeShell(),
        );
    }
  }

  static Widget _formPage({required String? id, required TransactionType type}) {
    return BlocProvider<TransactionFormBloc>(
      create: (_) =>
          sl<TransactionFormBloc>()..add(TransactionFormStarted(transactionId: id)),
      child: AddEditTransactionPage(isEditing: id != null, initialType: type),
    );
  }

  static Route<void> _slideUp(RouteSettings settings, Widget page) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
