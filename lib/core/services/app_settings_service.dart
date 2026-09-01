import 'package:opration/core/constants.dart';
import 'package:opration/core/models/app_currency.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/services/cache_helper/cache_values.dart';

class AppSettingsService {
  static Future<void> loadCurrency() async {
    final code =
        CacheHelper.getData(CacheKeys.appCurrencyCode) as String? ??
        kDefaultCurrencyCode;
    appCurrencySymbol = currencyByCode(code).symbol;
  }

  static Future<void> saveCurrencyCode(String code) async {
    await CacheHelper.saveData(key: CacheKeys.appCurrencyCode, value: code);
    appCurrencySymbol = currencyByCode(code).symbol;
    // await CloudSyncService.touchLocalUpdate();
  }

  static String get savedCurrencyCode {
    return CacheHelper.getData(CacheKeys.appCurrencyCode) as String? ??
        kDefaultCurrencyCode;
  }
}
