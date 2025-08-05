import 'package:opration/core/services/cache_helper/cache_values.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LoginLocalDataSource {
  Future<void> cacheUsername(String username);
  Future<String?> getLastUsername();
}

class LoginLocalDataSourceImpl implements LoginLocalDataSource {
  LoginLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  @override
  Future<void> cacheUsername(String username) {
    return sharedPreferences.setString(CacheKeys.userName, username);
  }

  @override
  Future<String?> getLastUsername() {
    final username = sharedPreferences.getString(CacheKeys.userName);
    if (username != null) {
      return Future.value(username);
    } else {
      throw Exception('No user is registered.');
    }
  }
}
