import 'package:opration/features/login/data/datasources/login_local_data_source.dart';
import 'package:opration/features/login/domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl({required this.localDataSource});
  final AuthLocalDataSource localDataSource;

  @override
  Future<void> saveUsername(String username) async {
    try {
      await localDataSource.saveUsername(username);
    } catch (e) {
      throw Exception('Failed to save the username.');
    }
  }

  @override
  Future<String?> getUsername() async {
    try {
      return await localDataSource.getUsername();
    } catch (e) {
      throw Exception('Failed to retrieve the username.');
    }
  }

  @override
  Future<void> clearUsername() async {
    try {
      return await localDataSource.clearUsername();
    } catch (e) {
      throw Exception('Failed to retrieve the username.');
    }
  }
}
