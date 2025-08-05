import 'package:get_it/get_it.dart';
import 'package:opration/features/login/data/datasources/login_local_data_source.dart';
import 'package:opration/features/login/data/repositories/login_repository_impl.dart';
import 'package:opration/features/login/domain/repositories/login_repository.dart';
import 'package:opration/features/login/domain/usecases/login_usecase.dart';
import 'package:opration/features/login/presentation/cubit/login_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> setupGetIt() async {
  // Cubit
  sl
    ..registerFactory(() => LoginCubit(loginUseCase: sl()))
    // UseCases
    ..registerLazySingleton(() => LoginUseCase(repository: sl()))
    // Repository
    ..registerLazySingleton<LoginRepository>(
      () => LoginRepositoryImpl(localDataSource: sl()),
    )
    // Data Sources
    ..registerLazySingleton<LoginLocalDataSource>(
      () => LoginLocalDataSourceImpl(sharedPreferences: sl()),
    );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
