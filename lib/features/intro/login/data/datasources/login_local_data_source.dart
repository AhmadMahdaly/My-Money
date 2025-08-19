import 'package:opration/core/services/cache_helper/cache_values.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUsername(String username);
  Future<String?> getUsername();
  Future<void> clearUsername();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  @override
  Future<void> saveUsername(String username) {
    return sharedPreferences.setString(CacheKeys.userName, username);
  }

  @override
  Future<String?> getUsername() async {
    return sharedPreferences.getString(CacheKeys.userName);
  }

  @override
  Future<void> clearUsername() {
    return sharedPreferences.remove(CacheKeys.userName);
  }
}
