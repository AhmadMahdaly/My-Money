import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/services/cache_helper/cache_values.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUsername(String username);
  Future<String?> getUsername();
  Future<void> clearUsername();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl();

  @override
  Future<void> saveUsername(String username) {
    return CacheHelper.saveData(key: CacheKeys.userName, value: username);
  }

  @override
  Future<String?> getUsername() async {
    return CacheHelper.getData(CacheKeys.userName) as String?;
  }

  @override
  Future<void> clearUsername() {
    return CacheHelper.removeData(CacheKeys.userName);
  }
}
