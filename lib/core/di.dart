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
    ..registerFactory(() => SaveMonthlyPlanUseCase(repository: getIt()));
}
