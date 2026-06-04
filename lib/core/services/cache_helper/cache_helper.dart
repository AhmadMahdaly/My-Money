import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;
  static final List<void Function(String key)> _changeListeners = [];
  static bool _suppressChangeNotifications = false;

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
    if (value is String) {
      final result = await sharedPreferences.setString(key, value);
      _notifyChange(key);
      return result;
    }
    if (value is int) {
      final result = await sharedPreferences.setInt(key, value);
      _notifyChange(key);
      return result;
    }
    if (value is bool) {
      final result = await sharedPreferences.setBool(key, value);
      _notifyChange(key);
      return result;
    }
    if (value is double) {
      final result = await sharedPreferences.setDouble(key, value);
      _notifyChange(key);
      return result;
    }

    if (value is List<String>) {
      final result = await sharedPreferences.setStringList(key, value);
      _notifyChange(key);
      return result;
    }

    throw Exception(
      'Type ${value.runtimeType} is not supported by CacheHelper',
    );
  }

  static Future<bool> removeData(String key) async {
    final result = await sharedPreferences.remove(key);
    _notifyChange(key);
    return result;
  }

  static Future<bool> clearAllData() async {
    final result = await sharedPreferences.clear();
    _notifyChange('*');
    return result;
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

  static void addOnDataChangedListener(void Function(String key) listener) {
    _changeListeners.add(listener);
  }

  static Future<T> runWithSuppressedNotifications<T>(
    Future<T> Function() action,
  ) async {
    _suppressChangeNotifications = true;
    try {
      return await action();
    } finally {
      _suppressChangeNotifications = false;
    }
  }

  static void _notifyChange(String key) {
    if (_suppressChangeNotifications) return;
    for (final listener in _changeListeners) {
      listener(key);
    }
  }
}
