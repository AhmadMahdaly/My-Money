// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:opration/core/services/cache_helper/cache_values.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class CacheHelper {
//   static late SharedPreferences sharedPreferences;
//   static const flutterSecureStorage = FlutterSecureStorage();

//   static Future<void> init() async {
//     sharedPreferences = await SharedPreferences.getInstance();
//   }

//   static dynamic getData({required String key}) {
//     return sharedPreferences.get(key);
//   }

//   static Future<void> cacheLanguageCode(String languageCode) async {
//     await sharedPreferences.setString(CacheKeys.currentLanguage, languageCode);
//   }

//   static dynamic getCurrentLanguage() {
//     return CacheHelper.getData(key: CacheKeys.currentLanguage) ?? 'en';
//   }

//   static Future setBool({required String key, required bool value}) async {
//     return sharedPreferences.setBool(key, value);
//   }

//   static Future saveData({required String key, required dynamic value}) async {
//     if (value is String) return sharedPreferences.setString(key, value);
//     if (value is int) return sharedPreferences.setInt(key, value);
//     if (value is bool) return sharedPreferences.setBool(key, value);

//     if (value is double) {
//       return sharedPreferences.setDouble(key, value);
//     }
//     if (value is List<String>) {
//       return sharedPreferences.setStringList(key, value);
//     }
//     return null;
//     // log('Unsupported type for SharedPreferences: ${value.runtimeType}');
//   }

//   static Future<bool> removeData({required String key}) async {
//     return sharedPreferences.remove(key);
//   }

//   static Future<bool> clearAllData() async {
//     return sharedPreferences.clear();
//   }

//   ///
//   static Future saveSecuredString({
//     required String key,
//     required dynamic value,
//   }) async {
//     await flutterSecureStorage.write(key: key, value: value.toString());
//   }

//   static Future<String?>? getSecuredString({required String key}) async {
//     try {
//       return flutterSecureStorage.read(key: key);
//     } catch (e) {
//       return null;
//     }
//   }

//   static Future removeSecuredData({required String key}) async {
//     await flutterSecureStorage.delete(key: key);
//   }

//   static Future clearAllSecuredData() async {
//     await flutterSecureStorage.deleteAll();
//   }
// }
