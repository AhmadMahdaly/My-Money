import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/services/background_service.dart';
import 'package:opration/features/app_blocker/data/models/app_rule.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (await Permission.notification.isDenied) {
  //   await Permission.notification.request();
  // }
  await setupGetIt();

  await Hive.initFlutter();
  Hive.registerAdapter(AppRuleAdapter());
  await Hive.openBox<AppRule>('rulesBox');
  await initializeService();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
