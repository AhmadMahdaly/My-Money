import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/features/app_blocker/services/background_service.dart';
import 'package:opration/features/app_blocker/services/notification_channel.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  await setupGetIt();
  await CacheHelper.init();
  await createNotificationChannel();
  await initializeService();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
