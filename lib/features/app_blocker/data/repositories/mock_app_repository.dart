import 'package:flutter/material.dart';
import 'package:opration/features/app_blocker/data/models/mock_app_info.dart';

class MockAppRepository {
  Future<List<MockAppInfo>> getInstalledApps() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      MockAppInfo(appName: 'فيسبوك', packageName: 'com.facebook.katana', icon: Icons.facebook, usage: const Duration(minutes: 75)),
      MockAppInfo(appName: 'انستغرام', packageName: 'com.instagram.android', icon: Icons.camera_alt, usage: const Duration(minutes: 40)),
      MockAppInfo(appName: 'يوتيوب', packageName: 'com.google.android.youtube', icon: Icons.play_circle_fill, usage: const Duration(minutes: 120)),
      MockAppInfo(appName: 'تيك توك', packageName: 'com.zhiliaoapp.musically', icon: Icons.music_note, usage: const Duration(minutes: 95)),
      MockAppInfo(appName: 'واتساب', packageName: 'com.whatsapp', icon: Icons.chat, usage: const Duration(minutes: 30)),
      MockAppInfo(appName: 'خرائط جوجل', packageName: 'com.google.android.apps.maps', icon: Icons.map, usage: const Duration(minutes: 15)),
    ];
  }
}