import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();
  await CacheHelper.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
