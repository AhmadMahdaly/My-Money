import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/services/app_settings_service.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/services/cloud_auto_sync_service.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // App can still run locally without Firebase config.
  }
  await CacheHelper.init();
  CloudAutoSyncService.initialize();
  await AppSettingsService.loadCurrency();
  await setupGetIt();
}
