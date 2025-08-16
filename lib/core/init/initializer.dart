import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opration/core/di.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
