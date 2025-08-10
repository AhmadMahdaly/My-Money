import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opration/core/di.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (await Permission.notification.isDenied) {
  //   await Permission.notification.request();
  // }
  await setupGetIt();
  // await CacheHelper.init();
  // await createNotificationChannel();
  // await initializeService();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
