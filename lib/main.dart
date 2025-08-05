import 'package:flutter/material.dart';
import 'package:opration/core/init/initializer.dart';
import 'package:opration/my_app.dart';

Future<void> main() async {
  await initializeApp();
  runApp(const MyApp());
}
