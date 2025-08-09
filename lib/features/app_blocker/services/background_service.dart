import 'dart:async';
import 'dart:ui';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:opration/features/app_blocker/models/blocker_schedule.dart';
import 'package:opration/features/app_blocker/services/notification_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String notificationChannelId = 'app_blocker_channel';
const int notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'App Blocker Service',
      initialNotificationContent:
          'Monitoring app usage to protect your focus...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

// ✨ دالة مساعدة للتحقق من حالة الحظر لتجنب تكرار الكود
bool isAppCurrentlyBlocked(BlockerSchedule schedule) {
  final now = DateTime.now();
  switch (schedule.blockType) {
    case BlockType.permanent:
      return true;
    case BlockType.scheduled:
      // التأكد من أن وقت الانتهاء لم يأت بعد
      return schedule.blockUntil != null && now.isBefore(schedule.blockUntil!);
    case BlockType.recurring:
      if (schedule.recurringInterval != null &&
          schedule.recurringDuration != null) {
        final midnight = DateTime(now.year, now.month, now.day);
        final secondsSinceMidnight = now.difference(midnight).inSeconds;
        final intervalSeconds = schedule.recurringInterval!.inSeconds;

        // التأكد من أن الفاصل الزمني أكبر من صفر لتجنب القسمة على صفر
        if (intervalSeconds == 0) return false;

        final cycleStartSeconds =
            (secondsSinceMidnight ~/ intervalSeconds) * intervalSeconds;
        final cycleStart = midnight.add(Duration(seconds: cycleStartSeconds));
        final cycleEnd = cycleStart.add(schedule.recurringDuration!);

        return now.isAfter(cycleStart) && now.isBefore(cycleEnd);
      }
      return false;
  }
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  if (await NotificationListenerService.isPermissionGranted()) {
    NotificationListenerService.notificationsStream.listen((
      notification,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final packageName = notification.packageName;

      if (packageName == null) return;

      final scheduleKey = 'schedule_$packageName';
      final scheduleJson = prefs.getString(scheduleKey);

      if (scheduleJson != null) {
        final schedule = BlockerSchedule.fromJson(scheduleJson);
        // استخدام الدالة المساعدة للتحقق
        if (isAppCurrentlyBlocked(schedule)) {
          debugPrint(
            'Notification Blocker: Cancelling notification from $packageName',
          );
          // إلغاء الإشعار فوراً
          await flutterLocalNotificationsPlugin.cancel(notification.id!);
        }
      }
    });
  }
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(seconds: 3));
      final usageInfos = await AppUsage().getAppUsage(startDate, endDate);

      if (usageInfos.isNotEmpty) {
        // ترتيب التطبيقات حسب آخر وقت استخدام لمعرفة التطبيق في الواجهة
        usageInfos.sort((a, b) => b.lastForeground.compareTo(a.lastForeground));
        final foregroundApp = usageInfos.first;

        // لا تحظر تطبيقك الخاص
        if (foregroundApp.packageName == 'com.mahdaly.opration') return;

        final prefs = await SharedPreferences.getInstance();
        final scheduleKey = 'schedule_${foregroundApp.packageName}';
        final scheduleJson = prefs.getString(scheduleKey);

        if (scheduleJson != null) {
          final schedule = BlockerSchedule.fromJson(scheduleJson);
          // استخدام الدالة المساعدة للتحقق
          if (isAppCurrentlyBlocked(schedule)) {
            // إرسال أمر لواجهة المستخدم لعرض شاشة الحظر
            service.invoke('showBlockingOverlay', {
              'appName': foregroundApp.appName,
              'packageName': foregroundApp.packageName,
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Background Service Error: $e');
    }
  });
}
