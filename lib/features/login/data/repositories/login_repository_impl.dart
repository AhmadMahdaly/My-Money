import 'package:opration/features/login/data/datasources/login_local_data_source.dart';
import 'package:opration/features/login/domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl({required this.localDataSource});
  final LoginLocalDataSource localDataSource;

  @override
  Future<void> saveUsername(String username) async {
    try {
      await localDataSource.cacheUsername(username);
    } catch (e) {
      throw Exception('Failed to save the username.');
    }
  }

  @override
  Future<String?> getUsername() async {
    try {
      return await localDataSource.getLastUsername();
    } catch (e) {
      throw Exception('Failed to retrieve the username.');
    }
  }
}
