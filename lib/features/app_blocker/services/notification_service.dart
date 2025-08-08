import 'package:flutter/material.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

class AppNotificationService {
  static Future<bool> requestNotificationPermission() async {
    try {
      final bool isGranted =
          await NotificationListenerService.requestPermission();
      return isGranted;
    } catch (e) {
      debugPrint('خطأ في طلب صلاحية الإشعارات: $e');
      return false;
    }
  }

  static Future<bool> isNotificationPermissionGranted() async {
    try {
      return await NotificationListenerService.isPermissionGranted();
    } catch (e) {
      debugPrint('خطأ في التحقق من صلاحية الإشعارات: $e');
      return false;
    }
  }
}
