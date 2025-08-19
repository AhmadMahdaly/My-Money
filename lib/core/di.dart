import 'package:get_it/get_it.dart';
import 'package:opration/features/financial_goals/data/datasources/financial_goal_local_data_source.dart';
import 'package:opration/features/financial_goals/data/repositories/financial_goal_repository_impl.dart';
import 'package:opration/features/financial_goals/domain/repositories/financial_goal_repository.dart';
import 'package:opration/features/financial_goals/domain/usecases/add_financial_goal.dart';
import 'package:opration/features/financial_goals/domain/usecases/delete_financial_goal.dart';
import 'package:opration/features/financial_goals/domain/usecases/get_financial_goals.dart';
import 'package:opration/features/financial_goals/domain/usecases/update_financial_goal.dart';
import 'package:opration/features/financial_goals/presentation/cubit/financial_goal_cubit.dart';
import 'package:opration/features/intro/login/data/datasources/login_local_data_source.dart';
import 'package:opration/features/intro/login/data/repositories/login_repository_impl.dart';
import 'package:opration/features/intro/login/domain/repositories/login_repository.dart';
import 'package:opration/features/intro/login/domain/usecases/login_usecase.dart';
import 'package:opration/features/intro/login/presentation/cubit/login_cubit.dart';
import 'package:opration/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:opration/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:opration/features/transactions/domain/usecases/add_category.dart';
import 'package:opration/features/transactions/domain/usecases/add_transaction.dart';
import 'package:opration/features/transactions/domain/usecases/delete_category.dart';
import 'package:opration/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:opration/features/transactions/domain/usecases/get_categories.dart';
import 'package:opration/features/transactions/domain/usecases/get_filter_settings.dart';
import 'package:opration/features/transactions/domain/usecases/get_monthly_plan.dart';
import 'package:opration/features/transactions/domain/usecases/get_transactions.dart';
import 'package:opration/features/transactions/domain/usecases/save_filter_settings.dart';
import 'package:opration/features/transactions/domain/usecases/save_monthly_plan.dart';
import 'package:opration/features/transactions/domain/usecases/update_category.dart';
import 'package:opration/features/transactions/domain/usecases/update_transaction.dart';
import 'package:opration/features/wallets/data/datasources/wallet_local_data_source.dart';
import 'package:opration/features/wallets/data/repositories/wallet_repository_impl.dart';
import 'package:opration/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:opration/features/wallets/domain/usecases/add_wallet.dart';
import 'package:opration/features/wallets/domain/usecases/delete_wallet.dart';
import 'package:opration/features/wallets/domain/usecases/get_show_main_wallet_pref.dart';
import 'package:opration/features/wallets/domain/usecases/get_wallets.dart';
import 'package:opration/features/wallets/domain/usecases/set_main_wallet.dart';
import 'package:opration/features/wallets/domain/usecases/set_show_main_wallet_pref.dart';
import 'package:opration/features/wallets/domain/usecases/update_wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final GetIt getIt = GetIt.instance;
Future<void> setupGetIt() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<SharedPreferences>(sharedPreferences)
    ..registerLazySingleton(() => const Uuid())
    // login
    ..registerLazySingleton(() => LoginUseCase(repository: getIt()))
    ..registerLazySingleton<LoginRepository>(
      () => LoginRepositoryImpl(localDataSource: getIt()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sharedPreferences: getIt()),
    )
    ..registerFactory(() => AuthCubit(localDataSource: getIt()))
    // transactions
    ..registerFactory<TransactionLocalDataSource>(
      () => TransactionLocalDataSourceImpl(
        sharedPreferences: getIt(),
        uuid: getIt(),
      ),
    )
    ..registerFactory<WalletLocalDataSource>(
      () => WalletLocalDataSourceImpl(
        sharedPreferences: getIt(),
        uuid: getIt(),
      ),
    )
    ..registerFactory<WalletRepository>(
      () => WalletRepositoryImpl(localDataSource: getIt()),
    )
    ..registerFactory<TransactionRepository>(
      () => TransactionRepositoryImpl(localDataSource: getIt()),
    )
    ..registerFactory(() => GetTransactionsUseCase(repository: getIt()))
    ..registerFactory(() => AddTransactionUseCase(repository: getIt()))
    ..registerFactory(() => GetCategoriesUseCase(repository: getIt()))
    ..registerFactory(() => AddCategoryUseCase(repository: getIt()))
    ..registerFactory(() => GetFilterSettingsUseCase(repository: getIt()))
    ..registerFactory(() => SaveFilterSettingsUseCase(repository: getIt()))
    ..registerFactory(() => UpdateCategoryUseCase(repository: getIt()))
    ..registerFactory(() => DeleteCategoryUseCase(repository: getIt()))
    ..registerFactory(() => UpdateTransactionUseCase(repository: getIt()))
    ..registerFactory(() => DeleteTransactionUseCase(repository: getIt()))
    ..registerFactory(() => GetMonthlyPlanUseCase(repository: getIt()))
    ..registerFactory(() => SaveMonthlyPlanUseCase(repository: getIt()))
    ..registerFactory(() => UpdateWalletUseCase(repository: getIt()))
    ..registerFactory(() => SaveShowMainWalletPrefUseCase(repository: getIt()))
    ..registerFactory(() => SetMainWalletUseCase(repository: getIt()))
    ..registerFactory(() => GetWalletsUseCase(repository: getIt()))
    ..registerFactory(() => GetShowMainWalletPrefUseCase(repository: getIt()))
    ..registerFactory(() => DeleteWalletUseCase(repository: getIt()))
    ..registerFactory(() => AddWalletUseCase(repository: getIt()))
    ..registerLazySingleton<FinancialGoalLocalDataSource>(
      () => FinancialGoalLocalDataSourceImpl(sharedPreferences: getIt()),
    )
    ..registerLazySingleton<FinancialGoalRepository>(
      () => FinancialGoalRepositoryImpl(localDataSource: getIt()),
    )
    ..registerLazySingleton(() => GetFinancialGoalsUseCase(repository: getIt()))
    ..registerLazySingleton(() => AddFinancialGoalUseCase(repository: getIt()))
    ..registerLazySingleton(
      () => UpdateFinancialGoalUseCase(repository: getIt()),
    )
    ..registerLazySingleton(
      () => DeleteFinancialGoalUseCase(repository: getIt()),
    )
    ..registerFactory(
      () => FinancialGoalCubit(
        getFinancialGoalsUseCase: getIt(),
        addFinancialGoalUseCase: getIt(),
        updateFinancialGoalUseCase: getIt(),
        deleteFinancialGoalUseCase: getIt(),
      ),
    );
}
