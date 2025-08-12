import 'dart:async';
import 'dart:ui';

import 'package:app_usage/app_usage.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opration/features/app_blocker/data/models/app_rule.dart';
import 'package:opration/features/app_blocker/data/repositories/rules_repository.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  // iOS specific background setup
  return true;
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Initialize Hive for the background service
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(AppRuleAdapter().typeId)) {
    Hive.registerAdapter(AppRuleAdapter());
  }
  final rulesBox = await Hive.openBox<AppRule>('rulesBox');
  final rulesRepository = RulesRepository(rulesBox);

  String? lastBlockedApp;

  Timer.periodic(const Duration(seconds: 3), (timer) async {
    try {
      // Get usage stats for the last 5 seconds to find the foreground app
      final endDate = DateTime.now();
      final startDate = endDate.subtract(
        const Duration(days: 1),
      ); // Check usage for the whole day
      final infoList = await AppUsage().getAppUsage(startDate, endDate);

      final recentApps = await AppUsage().getAppUsage(
        DateTime.now().subtract(const Duration(minutes: 1)),
        DateTime.now(),
      );

      if (recentApps.isEmpty) return;

      // Sort to find the most recently used app
      recentApps.sort((a, b) => b.lastForeground.compareTo(a.lastForeground));
      final currentAppPackage = recentApps.first.packageName;

      // Avoid checking our own app
      // IMPORTANT: Replace 'com.example.app_monitor' with your actual package name from android/app/build.gradle
      if (currentAppPackage == 'com.example.app_monitor') {
        if (lastBlockedApp != null) {
          await FlutterOverlayWindow.closeOverlay();
          lastBlockedApp = null;
        }
        return;
      }

      final rule = rulesRepository.getRuleForApp(currentAppPackage);
      final usageInfo = infoList.firstWhere(
        (info) => info.packageName == currentAppPackage,
        orElse: () => AppUsageInfo(
          currentAppPackage,
          0,
          DateTime.now(),
          DateTime.now(),
          DateTime.now(),
        ),
      );

      if (rule.isEnabled && usageInfo.usage.inMinutes > rule.timeLimitMinutes) {
        // Block the app
        if (lastBlockedApp != currentAppPackage) {
          final hasPermission =
              await FlutterOverlayWindow.isPermissionGranted();
          if (hasPermission) {
            await FlutterOverlayWindow.showOverlay(
              height: 5000, // Full screen
              width: 5000,
              alignment: OverlayAlignment.center,
              flag: OverlayFlag.focusPointer,
            );
            lastBlockedApp = currentAppPackage;
          }
        }
      } else {
        // Unblock if it's the currently blocked app
        if (lastBlockedApp == currentAppPackage) {
          await FlutterOverlayWindow.closeOverlay();
          lastBlockedApp = null;
        }
      }
    } catch (e) {
      print('Error in background service: $e');
    }
  });
}
