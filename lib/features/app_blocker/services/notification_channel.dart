import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> create() async {
  FlutterBackgroundService().on('requestAppUsage').listen((event) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(minutes: 1));
      final usageInfos = await AppUsage().getAppUsage(startDate, endDate);

      if (usageInfos.isNotEmpty) {
        usageInfos.sort((a, b) => b.lastForeground.compareTo(a.lastForeground));
        final foregroundApp = usageInfos.first;

        // ترجع النتيجة للخلفية
        FlutterBackgroundService().invoke('appUsageResult', {
          'appName': foregroundApp.appName,
          'packageName': foregroundApp.packageName,
        });
      }
    } catch (e) {
      debugPrint('AppUsage error: $e');
    }
  });
}

Future<void> createNotificationChannel() async {
  const channel = AndroidNotificationChannel(
    'app_blocker_channel',
    'App Blocker Service',
    description: 'Channel for App Blocker foreground service',
    importance: Importance.low,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}
