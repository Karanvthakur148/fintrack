import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintrack/core/constants/box_names.dart';
import 'package:fintrack/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:fintrack/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fintrack/features/auth/domain/repositories/auth_repository.dart';
import 'package:fintrack/features/auth/domain/usecases/auth_usecases.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintrack/features/auth/presentation/bloc/auth_event.dart';
import 'package:fintrack/features/sync/data/firestore_mappers.dart';
import 'package:fintrack/features/sync/data/firestore_remote_data_source.dart';
import 'package:fintrack/features/sync/data/remote_data_source.dart';
import 'package:fintrack/features/sync/data/sync_coordinator.dart';
import 'package:fintrack/firebase_options.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_category_distribution.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_monthly_comparison.dart';
import 'package:fintrack/features/analytics/domain/usecases/compute_weekly_spending.dart';
import 'package:fintrack/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:fintrack/features/budgets/data/datasources/budget_local_data_source.dart';
import 'package:fintrack/features/budgets/data/models/budget_model.dart';
import 'package:fintrack/features/budgets/data/models/budget_model_adapter.dart';
import 'package:fintrack/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:fintrack/features/budgets/domain/repositories/budget_repository.dart';
import 'package:fintrack/features/budgets/domain/usecases/calculate_budget_progress.dart';
import 'package:fintrack/features/budgets/domain/usecases/clear_budgets.dart';
import 'package:fintrack/features/budgets/domain/usecases/create_budget.dart';
import 'package:fintrack/features/budgets/domain/usecases/delete_budget.dart';
import 'package:fintrack/features/budgets/domain/usecases/update_budget.dart';
import 'package:fintrack/features/budgets/domain/usecases/watch_budgets.dart';
import 'package:fintrack/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:fintrack/features/dashboard/domain/usecases/build_dashboard_data.dart';
import 'package:fintrack/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fintrack/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:fintrack/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fintrack/features/settings/domain/repositories/settings_repository.dart';
import 'package:fintrack/features/settings/domain/usecases/settings_usecases.dart';
import 'package:fintrack/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:fintrack/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:fintrack/features/transactions/data/models/transaction_model.dart';
import 'package:fintrack/features/transactions/data/models/transaction_model_adapter.dart';
import 'package:fintrack/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:fintrack/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fintrack/features/transactions/domain/usecases/add_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/calculate_summary.dart';
import 'package:fintrack/features/transactions/domain/usecases/clear_transactions.dart';
import 'package:fintrack/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/filter_transactions.dart';
import 'package:fintrack/features/transactions/domain/usecases/get_transaction_by_id.dart';
import 'package:fintrack/features/transactions/domain/usecases/update_transaction.dart';
import 'package:fintrack/features/transactions/domain/usecases/watch_transactions.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_form_bloc.dart';
import 'package:fintrack/features/transactions/presentation/bloc/transaction_list_bloc.dart';

final GetIt sl = GetIt.instance;

/// Tries to start Firebase. Returns false when it is not configured yet
/// (no `flutterfire configure` run); the app then works local-only.
Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return true;
  } catch (_) {
    return false;
  }
}

/// Initializes Hive (adapters first, then boxes), SharedPreferences and
/// registers every dependency. Throws if storage cannot be opened.
Future<void> configureDependencies() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(TransactionModelAdapter().typeId)) {
    Hive.registerAdapter(TransactionModelAdapter());
  }
  if (!Hive.isAdapterRegistered(BudgetModelAdapter().typeId)) {
    Hive.registerAdapter(BudgetModelAdapter());
  }
  final transactionBox =
      await Hive.openBox<TransactionModel>(BoxNames.transactions);
  final budgetBox = await Hive.openBox<BudgetModel>(BoxNames.budgets);
  final prefs = await SharedPreferences.getInstance();
  final cloudReady = await _initFirebase();

  // ---- Auth + cloud (only when Firebase is configured) ----
  if (cloudReady) {
    sl
      ..registerLazySingleton<AuthRemoteDataSource>(
        () => FirebaseAuthDataSource(FirebaseAuth.instance),
      )
      ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
      ..registerLazySingleton<RemoteDataSource<TransactionModel>>(
        () => FirestoreRemoteDataSource<TransactionModel>(
          firestore: FirebaseFirestore.instance,
          collection: 'transactions',
          toMap: FirestoreMappers.transactionToMap,
          fromMap: FirestoreMappers.transactionFromMap,
          idOf: (m) => m.id,
        ),
      )
      ..registerLazySingleton<RemoteDataSource<BudgetModel>>(
        () => FirestoreRemoteDataSource<BudgetModel>(
          firestore: FirebaseFirestore.instance,
          collection: 'budgets',
          toMap: FirestoreMappers.budgetToMap,
          fromMap: FirestoreMappers.budgetFromMap,
          idOf: (m) => m.id,
        ),
      );
  } else {
    sl.registerLazySingleton<AuthRepository>(
      () => const UnavailableAuthRepository(),
    );
  }
  String? currentUid() => sl<AuthRepository>().currentUser?.uid;

  // ---- Data sources ----
  sl
    ..registerLazySingleton<TransactionLocalDataSource>(
      () => HiveTransactionLocalDataSource(transactionBox),
    )
    ..registerLazySingleton<BudgetLocalDataSource>(
      () => HiveBudgetLocalDataSource(budgetBox),
    )
    ..registerLazySingleton<SettingsLocalDataSource>(
      () => SharedPrefsSettingsDataSource(prefs),
    )
    // ---- Repositories ----
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(
        sl(),
        remote: cloudReady ? sl<RemoteDataSource<TransactionModel>>() : null,
        currentUid: currentUid,
      ),
    )
    ..registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(
        sl(),
        remote: cloudReady ? sl<RemoteDataSource<BudgetModel>>() : null,
        currentUid: currentUid,
      ),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()),
    )
    // ---- Transaction use cases ----
    ..registerLazySingleton(() => WatchTransactions(sl()))
    ..registerLazySingleton(() => GetTransactionById(sl()))
    ..registerLazySingleton(() => AddTransaction(sl()))
    ..registerLazySingleton(() => UpdateTransaction(sl()))
    ..registerLazySingleton(() => DeleteTransaction(sl()))
    ..registerLazySingleton(() => ClearTransactions(sl()))
    ..registerLazySingleton(() => const FilterTransactions())
    ..registerLazySingleton(() => const CalculateSummary())
    // ---- Analytics / dashboard use cases ----
    ..registerLazySingleton(() => const ComputeCategoryDistribution())
    ..registerLazySingleton(() => const ComputeWeeklySpending())
    ..registerLazySingleton(() => const ComputeMonthlyComparison())
    ..registerLazySingleton(() => const BuildDashboardData())
    // ---- Budget use cases ----
    ..registerLazySingleton(() => WatchBudgets(sl()))
    ..registerLazySingleton(() => CreateBudget(sl()))
    ..registerLazySingleton(() => UpdateBudget(sl()))
    ..registerLazySingleton(() => DeleteBudget(sl()))
    ..registerLazySingleton(() => ClearBudgets(sl()))
    ..registerLazySingleton(() => const CalculateBudgetProgress())
    // ---- Settings use cases ----
    ..registerLazySingleton(() => LoadSettings(sl()))
    ..registerLazySingleton(() => SaveThemeMode(sl()))
    ..registerLazySingleton(() => SaveCurrency(sl()))
    ..registerLazySingleton(
      () => ClearAllData(transactions: sl(), budgets: sl()),
    )
    // ---- Auth use cases ----
    ..registerLazySingleton(() => WatchAuthState(sl()))
    ..registerLazySingleton(() => SignIn(sl()))
    ..registerLazySingleton(() => SignUp(sl()))
    ..registerLazySingleton(() => SendPasswordReset(sl()))
    ..registerLazySingleton(() => SignOut(sl(), () => sl<ClearAllData>()()))
    // ---- BLoCs ----
    ..registerFactory(
      () => TransactionListBloc(
        watchTransactions: sl(),
        deleteTransaction: sl(),
        filterTransactions: sl(),
      ),
    )
    ..registerFactory(
      () => TransactionFormBloc(
        addTransaction: sl(),
        updateTransaction: sl(),
        deleteTransaction: sl(),
        getTransactionById: sl(),
      ),
    )
    ..registerFactory(
      () => DashboardBloc(watchTransactions: sl(), buildDashboardData: sl()),
    )
    ..registerFactory(
      () => AnalyticsBloc(
        watchTransactions: sl(),
        calculateSummary: sl(),
        computeCategoryDistribution: sl(),
        computeWeeklySpending: sl(),
        computeMonthlyComparison: sl(),
      ),
    )
    ..registerFactory(
      () => BudgetsBloc(
        watchBudgets: sl(),
        watchTransactions: sl(),
        createBudget: sl(),
        updateBudget: sl(),
        deleteBudget: sl(),
        calculateProgress: sl(),
      ),
    );

  // Settings are loaded first so the very first frame uses the saved theme.
  final settings = await sl<LoadSettings>()();
  sl.registerLazySingleton(
    () => SettingsBloc(
      saveThemeMode: sl(),
      saveCurrency: sl(),
      clearAllData: sl(),
      initial: settings,
    ),
  );

  sl.registerLazySingleton(
    () => AuthBloc(
      watchAuthState: sl(),
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      sendPasswordReset: sl(),
      isAvailable: cloudReady,
      initialUser: sl<AuthRepository>().currentUser,
    ),
  );
  sl<AuthBloc>().add(const AuthStarted());

  // Pulls cloud changes into Hive while a user is signed in.
  if (cloudReady) {
    final transactionSource = sl<TransactionLocalDataSource>();
    final budgetSource = sl<BudgetLocalDataSource>();
    sl.registerSingleton<SyncCoordinator>(
      SyncCoordinator(
        auth: sl(),
        tasks: [
          CollectionSync<TransactionModel>(
            localAll: transactionSource.getAll,
            localUpsert: transactionSource.upsert,
            localDelete: transactionSource.deleteIfExists,
            remote: sl<RemoteDataSource<TransactionModel>>(),
            idOf: (m) => m.id,
            updatedAtOf: (m) => m.updatedAtMs,
          ),
          CollectionSync<BudgetModel>(
            localAll: budgetSource.getAll,
            localUpsert: budgetSource.upsert,
            localDelete: budgetSource.deleteIfExists,
            remote: sl<RemoteDataSource<BudgetModel>>(),
            idOf: (m) => m.id,
            updatedAtOf: (m) => m.updatedAtMs,
          ),
        ],
      )..start(),
    );
  }
}
