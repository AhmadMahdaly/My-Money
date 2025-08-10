import 'dart:async';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/app_blocker/models/blocker_schedule.dart';
import 'package:opration/features/app_blocker/presentation/views/blocking_screen.dart';
import 'package:opration/features/app_blocker/presentation/views/widgets/schedule_dialog.dart';
import 'package:opration/features/app_blocker/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBlockerScreen extends StatefulWidget {
  const AppBlockerScreen({super.key});

  @override
  State<AppBlockerScreen> createState() => _AppBlockerScreenState();
}

class _AppBlockerScreenState extends State<AppBlockerScreen> {
  bool _isLoading = true;
  List<AppInfo> _apps = [];
  Map<String, BlockerSchedule> _schedules = {};
  bool _hasUsageAccess = false;
  bool _hasOverlayPermission = false;
  bool _hasNotificationPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadApps();
    _listenForBlockingEvents();
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkPermissionsAndLoadApps();
    });
  }

  void _listenForBlockingEvents() {
    FlutterBackgroundService().on('showBlockingOverlay').listen((event) {
      if (mounted &&
          event != null &&
          event.containsKey('appName') &&
          event.containsKey('packageName')) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => BlockingScreen(
              appName: event['appName'].toString(),
              packageName: event['packageName'].toString(),
            ),
          ),
        );
      }
    });
  }

  Future<void> _checkPermissionsAndLoadApps() async {
    setState(() => _isLoading = true);

    final hasUsageAccess = await _requestUsageAccess();
    final hasOverlayPermission = await _requestOverlayPermission();
    final hasNotificationPermission = await _requestNotificationPermission();

    setState(() {
      _hasUsageAccess = hasUsageAccess;
      _hasOverlayPermission = hasOverlayPermission;
      _hasNotificationPermission = hasNotificationPermission;
    });

    if (hasUsageAccess && hasOverlayPermission) {
      await _loadApps();
      await _loadSchedules();
    }

    setState(() => _isLoading = false);
  }

  Future<bool> _requestUsageAccess() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(seconds: 1));
      await AppUsage().getAppUsage(startDate, endDate);
      return true;
    } catch (exception) {
      // AppUsage().openUsageSettings();
      return false;
    }
  }

  Future<bool> _requestOverlayPermission() async {
    try {
      final status = await Permission.systemAlertWindow.request();
      if (!status.isGranted) {
        await openAppSettings();
      }
      return status.isGranted;
    } catch (e) {
      debugPrint('خطأ في صلاحية التغطية: $e');
      return false;
    }
  }

  Future<bool> _requestNotificationPermission() async {
    try {
      final isGranted =
          await AppNotificationService.requestNotificationPermission();
      if (!isGranted) {
        await openAppSettings();
      }
      return isGranted;
    } catch (e) {
      debugPrint('خطأ في صلاحية الإشعارات: $e');
      return false;
    }
  }

  Future<void> _loadApps() async {
    final apps = await InstalledApps.getInstalledApps(true, false);
    if (mounted) {
      setState(() {
        _apps = apps;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final scheduleKeys = prefs.getKeys().where(
      (k) => k.startsWith('schedule_'),
    );
    final loadedSchedules = <String, BlockerSchedule>{};
    for (final key in scheduleKeys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        final packageName = key.replaceFirst('schedule_', '');
        loadedSchedules[packageName] = BlockerSchedule.fromJson(jsonString);
      }
    }
    if (mounted) {
      setState(() {
        _schedules = loadedSchedules;
      });
    }
  }

  Future<void> _updateSchedule(
    String packageName,
    BlockerSchedule? schedule,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'schedule_$packageName';
    setState(() {
      if (schedule != null) {
        _schedules[packageName] = schedule;
        prefs.setString(key, schedule.toJson());
      } else {
        _schedules.remove(packageName);
        prefs.remove(key);
      }
    });
  }

  Future<void> _openScheduleDialog(String packageName) async {
    final result = await showDialog<BlockerSchedule>(
      context: context,
      builder: (_) => const ScheduleDialog(),
    );
    if (result != null) {
      await _updateSchedule(packageName, result);
      // فتح إعدادات الإشعارات لتعطيلها يدويًا
      await InstalledApps.openSettings(packageName);
      // عرض إشعار توضيحي
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تعطيل إشعارات تطبيق $packageName لضمان الحظر الكامل',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحكم في التطبيقات'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !(_hasUsageAccess && _hasOverlayPermission)
          ? _buildPermissionsRequiredView()
          : _buildAppListView(),
    );
  }

  Widget _buildAppListView() {
    return ListView.builder(
      itemCount: _apps.length,
      itemBuilder: (context, index) {
        final app = _apps[index];
        final schedule = _schedules[app.packageName];
        final isBlocked = schedule != null;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          child: ListTile(
            title: Text(app.name),
            subtitle: Text(
              isBlocked ? schedule.description : 'غير محظور',
              style: TextStyle(
                color: isBlocked ? Colors.red.shade700 : Colors.green,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBlocked)
                  IconButton(
                    icon: const Icon(Icons.notifications_off),
                    onPressed: () {
                      InstalledApps.openSettings(app.packageName);
                    },
                    tooltip: 'تعطيل الإشعارات',
                  ),
                Switch(
                  value: isBlocked,
                  onChanged: (value) {
                    if (value) {
                      _openScheduleDialog(app.packageName);
                    } else {
                      _updateSchedule(app.packageName, null);
                    }
                  },
                ),
              ],
            ),
            onTap: () => _openScheduleDialog(app.packageName),
          ),
        );
      },
    );
  }

  Widget _buildPermissionsRequiredView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.amber),
            SizedBox(height: 16.h),
            Text(
              'صلاحيات مطلوبة',
              style: Styles.style18W700,
            ),
            SizedBox(height: 8.h),
            Text(
              'هذه الميزة تتطلب صلاحيات للوصول إلى استخدام التطبيقات وعرض شاشة الحظر. يرجى منح جميع الصلاحيات.',
              textAlign: TextAlign.center,
              style: Styles.style16W500,
            ),
            SizedBox(height: 16.h),
            if (!_hasUsageAccess)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: ElevatedButton(
                  onPressed: _requestUsageAccess,
                  child: const Text('منح صلاحية استخدام التطبيقات'),
                ),
              ),
            if (!_hasOverlayPermission)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: ElevatedButton(
                  onPressed: _requestOverlayPermission,
                  child: const Text('منح صلاحية شاشة التغطية'),
                ),
              ),
            if (!_hasNotificationPermission)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: ElevatedButton(
                  onPressed: _requestNotificationPermission,
                  child: const Text('منح صلاحية الإشعارات (اختياري)'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
