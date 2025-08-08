import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/blocker_schedule.dart';

const String blockedAppsKey = 'blocked_apps';
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
      initialNotificationTitle: 'خدمة حظر التطبيقات',
      initialNotificationContent: 'يراقب استخدام التطبيقات لحماية تركيزك...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: 'خدمة حظر التطبيقات',
      content: 'يراقب استخدام التطبيقات لحماية تركيزك...',
    );
  }

  Timer.periodic(const Duration(seconds: 3), (timer) async {
    service.invoke('requestAppUsage');
  });

  service.on('appUsageResult').listen((data) async {
    if (data == null || !data.containsKey('packageName')) return;

    final prefs = await SharedPreferences.getInstance();
    final packageName = data['packageName'] as String;
    final scheduleKey = 'schedule_$packageName';
    final scheduleJson = prefs.getString(scheduleKey);

    if (scheduleJson == null) return;

    final schedule = BlockerSchedule.fromJson(scheduleJson);
    final now = DateTime.now();
    bool isBlocked = false;

    switch (schedule.blockType) {
      case BlockType.permanent:
        isBlocked = true;
        break;
      case BlockType.scheduled:
        if (schedule.blockUntil != null && now.isBefore(schedule.blockUntil!)) {
          isBlocked = true;
        }
        break;
      case BlockType.recurring:
        if (schedule.recurringInterval != null &&
            schedule.recurringDuration != null) {
          final midnight = DateTime(now.year, now.month, now.day);
          final secondsSinceMidnight = now.difference(midnight).inSeconds;
          final intervalSeconds = schedule.recurringInterval!.inSeconds;
          final durationSeconds = schedule.recurringDuration!.inSeconds;

          final cycleStartSeconds =
              (secondsSinceMidnight ~/ intervalSeconds) * intervalSeconds;
          final cycleStart = midnight.add(Duration(seconds: cycleStartSeconds));
          final cycleEnd = cycleStart.add(schedule.recurringDuration!);

          isBlocked = now.isAfter(cycleStart) && now.isBefore(cycleEnd);
        }
        break;
    }

    if (isBlocked) {
      service.invoke('showBlockingOverlay', {
        'appName': data['appName'],
        'packageName': data['packageName'],
      });
    }
  });
}
