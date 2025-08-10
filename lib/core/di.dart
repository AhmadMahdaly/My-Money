import 'package:get_it/get_it.dart';
import 'package:opration/features/login/data/datasources/login_local_data_source.dart';
import 'package:opration/features/login/data/repositories/login_repository_impl.dart';
import 'package:opration/features/login/domain/repositories/login_repository.dart';
import 'package:opration/features/login/domain/usecases/login_usecase.dart';
import 'package:opration/features/login/presentation/cubit/login_cubit.dart';
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
import 'package:opration/features/transactions/presentation/cubit/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final GetIt sl = GetIt.instance;

Future<void> setupGetIt() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl
    ..registerLazySingleton(() => sharedPreferences)
    ..registerLazySingleton(() => const Uuid())
    // ================== Login Feature Dependencies ==================
    ..registerFactory(() => LoginCubit(loginUseCase: sl()))
    ..registerLazySingleton(() => LoginUseCase(repository: sl()))
    ..registerLazySingleton<LoginRepository>(
      () => LoginRepositoryImpl(localDataSource: sl()),
    )
    ..registerLazySingleton<LoginLocalDataSource>(
      () => LoginLocalDataSourceImpl(sharedPreferences: sl()),
    )
    // ================== Transaction Feature Dependencies ==================
    // Cubit
    ..registerFactory(
      () => TransactionCubit(
        getTransactionsUseCase: sl(),
        addTransactionUseCase: sl(),
        getCategoriesUseCase: sl(),
        addCategoryUseCase: sl(),
        getFilterSettingsUseCase: sl(),
        saveFilterSettingsUseCase: sl(),
        updateCategoryUseCase: sl(),
        deleteCategoryUseCase: sl(),
        updateTransactionUseCase: sl(),
        deleteTransactionUseCase: sl(),
      ),
    )
    // UseCases
    ..registerLazySingleton(() => GetTransactionsUseCase(repository: sl()))
    ..registerLazySingleton(() => AddTransactionUseCase(repository: sl()))
    ..registerLazySingleton(() => GetCategoriesUseCase(repository: sl()))
    ..registerLazySingleton(() => AddCategoryUseCase(repository: sl()))
    ..registerLazySingleton(() => GetFilterSettingsUseCase(repository: sl()))
    ..registerLazySingleton(() => SaveFilterSettingsUseCase(repository: sl()))
    ..registerLazySingleton(() => UpdateCategoryUseCase(repository: sl()))
    ..registerLazySingleton(() => DeleteCategoryUseCase(repository: sl()))
    ..registerLazySingleton(() => UpdateTransactionUseCase(repository: sl()))
    ..registerLazySingleton(() => DeleteTransactionUseCase(repository: sl()))
    // Repository
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(localDataSource: sl()),
    )
    // Data Sources
    ..registerLazySingleton<TransactionLocalDataSource>(
      () => TransactionLocalDataSourceImpl(sharedPreferences: sl(), uuid: sl()),
    )
    //
    ..registerLazySingleton(() => GetMonthlyPlanUseCase(repository: sl()))
    ..registerLazySingleton(() => SaveMonthlyPlanUseCase(repository: sl()))
    //
    ..registerFactory(
      () => MonthlyPlanCubit(
        getMonthlyPlanUseCase: sl(),
        saveMonthlyPlanUseCase: sl(),
      ),
    );
}
