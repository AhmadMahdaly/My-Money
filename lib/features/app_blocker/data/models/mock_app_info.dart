import 'package:flutter/material.dart';

class MockAppInfo {
  MockAppInfo({
    required this.appName,
    required this.packageName,
    required this.icon,
    required this.usage,
  });
  final String appName;
  final String packageName;
  final IconData icon;
  final Duration usage;
}
