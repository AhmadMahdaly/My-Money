import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:opration/core/router/app_routes.dart';

class BlockingScreen extends StatelessWidget {
  const BlockingScreen({
    required this.appName,
    required this.packageName,
    super.key,
  });
  final String appName;
  final String packageName;

  @override
  Widget build(BuildContext context) {
    // إعادة توجيه إلى تطبيقك
    InstalledApps.startApp(
      'com.example.opration',
    ); // استبدل بـ packageName لتطبيقك
    return WillPopScope(
      onWillPop: () async => false, // منع زر الرجوع
      child: Material(
        color: Colors.black.withAlpha(220),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_clock, color: Colors.white, size: 80),
                const SizedBox(height: 24),
                Text(
                  'تطبيق "$appName" محظور حالياً',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لقد قمت بحظر هذا التطبيق لتحسين تركيزك. ارجع إلى الشاشة الرئيسية.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    context.go(AppRoutes.homeScreen);
                  },
                  child: const Text('العودة إلى الشاشة الرئيسية'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
