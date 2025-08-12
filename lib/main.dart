import 'package:flutter/material.dart';
import 'package:opration/core/init/initializer.dart';
import 'package:opration/features/app_blocker/presentation/views/blocker_overlay.dart';
import 'package:opration/my_app.dart';

@pragma('vm:entry-point')
void overlayMain() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlockerOverlay(),
    ),
  );
}

Future<void> main() async {
  await initializeApp();
  runApp(const MyApp());
}
