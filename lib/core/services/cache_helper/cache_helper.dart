import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static dynamic getData(String key) {
    return sharedPreferences.get(key);
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return sharedPreferences.setString(key, value);
    if (value is int) return sharedPreferences.setInt(key, value);
    if (value is bool) return sharedPreferences.setBool(key, value);
    if (value is double) return sharedPreferences.setDouble(key, value);

    if (value is List<String>) {
      return sharedPreferences.setStringList(key, value);
    }

    throw Exception(
      'Type ${value.runtimeType} is not supported by CacheHelper',
    );
  }

  static Future<bool> removeData(String key) async {
    return sharedPreferences.remove(key);
  }

  static Future<bool> clearAllData() async {
    return sharedPreferences.clear();
  }

  static Future<Map<String, dynamic>> getAllData() async {
    final data = <String, dynamic>{};

    for (final key in sharedPreferences.getKeys()) {
      data[key] = sharedPreferences.get(key);
    }
    return data;
  }

  static Future<String> exportToJson() async {
    final data = await getAllData();
    return jsonEncode(data);
  }

  static Future<void> restoreFromJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        await saveData(key: key, value: value);
      } else if (value is int) {
        await saveData(key: key, value: value);
      } else if (value is bool) {
        await saveData(key: key, value: value);
      } else if (value is double) {
        await saveData(key: key, value: value);
      } else if (value is List || value is Map) {
        await CacheHelper.saveData(
          key: key,
          value: jsonEncode(value),
        );
      } else {
        throw Exception(
          'Type ${value.runtimeType} is not supported by CacheHelper',
        );
      }
    }
  }
}
