import 'dart:async';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
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

class _AppBlockerScreenState extends State<AppBlockerScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  List<AppInfo> _apps = [];
  Map<String, BlockerSchedule> _schedules = {};
  final bool _hasUsageAccess = false;
  bool _hasOverlayPermission = false;
  bool _hasNotificationAccess = false;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const platform = MethodChannel(
    'com.mahdaly.opration/notification_control',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
    _checkPermissionsAndLoadApps();
    _listenForBlockingEvents();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint('--- App Resumed --- Re-checking permissions...');
      _checkPermissionsAndLoadApps();
    }
  }

  Future<void> _initializeNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(initializationSettings);
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
    if (!mounted) return;
    setState(() => _isLoading = true);

    debugPrint('--- Checking Permissions ---');
    // final usageStatus = await AppUsage().checkUsagePermission() ?? false;
    final overlayStatus = await Permission.systemAlertWindow.isGranted;
    final notificationStatus =
        await AppNotificationService.isNotificationPermissionGranted();

    // debugPrint('Usage Access: $usageStatus, Overlay: $overlayStatus, Notifications: $notificationStatus');

    // final allPermissionsGranted = usageStatus && overlayStatus && notificationStatus;

    if (mounted) {
      setState(() {
        // _hasUsageAccess = usageStatus;
        _hasOverlayPermission = overlayStatus;
        _hasNotificationAccess = notificationStatus;
      });

      // if (allPermissionsGranted) {
      //   debugPrint('✅ All permissions granted. Loading data...');
      await _loadData();
      // } else {
      //   debugPrint('❌ Permissions missing. Showing permissions screen.');
      //   setState(() => _isLoading = false);
      // }
    }
  }

  Future<void> _loadData() async {
    await _loadApps();
    await _loadSchedules();
    if (mounted) {
      setState(() {
        _isLoading = false;
        debugPrint('✅ Data loading complete. UI should update.');
      });
    }
  }

  Future<void> _loadApps() async {
    debugPrint('... Starting to load apps...');
    try {
      final apps = await InstalledApps.getInstalledApps(true, true);
      debugPrint('... Found ${apps.length} installed apps.');
      if (mounted) {
        setState(() {
          _apps = apps
              .where((app) => app.packageName != 'com.mahdaly.opration')
              .toList();
        });
      }
    } catch (e) {
      debugPrint('... 🚨 Error loading apps: $e');
      if (mounted) {
        setState(() {
          _apps = [];
        });
      }
    }
  }

  Future<void> _loadSchedules() async {
    debugPrint('... Loading schedules from SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final scheduleKeys = prefs.getKeys().where(
      (k) => k.startsWith('schedule_'),
    );
    final loadedSchedules = <String, BlockerSchedule>{};
    for (final key in scheduleKeys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        final packageName = key.replaceFirst('schedule_', '');
        final schedule = BlockerSchedule.fromJson(jsonString);
        if (schedule.blockType == BlockType.scheduled &&
            schedule.blockUntil != null &&
            DateTime.now().isAfter(schedule.blockUntil!)) {
          await prefs.remove(key);
        } else {
          loadedSchedules[packageName] = schedule;
        }
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
    }
  }

  Future<void> _requestUsageAccess() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(hours: 1));
      final infoList = await AppUsage().getAppUsage(
        startDate,
        endDate,
      );

      // الآن يمكنك استخدام infoList
      for (final info in infoList) {
        print(
          'App name: ${info.appName}, Usage time: ${info.usage.inMinutes} minutes',
        );
      }
    } catch (exception) {
      print(exception);
    }
  }

  Future<void> _requestOverlayPermission() async {
    await Permission.systemAlertWindow.request();
  }

  Future<void> _requestNotificationAccess() async {
    await AppNotificationService.requestNotificationPermission();
  }

  Future<void> _requestBatteryOptimization() async {
    try {
      await platform.invokeMethod('requestBatteryOptimization');
    } catch (e) {
      debugPrint('Error requesting battery optimization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '--- Building UI --- isLoading: $_isLoading, Apps count: ${_apps.length}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Apps'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !(_hasUsageAccess &&
                _hasOverlayPermission &&
                _hasNotificationAccess)
          ? _buildPermissionsRequiredView()
          : _buildAppListView(),
    );
  }

  Widget _buildAppListView() {
    if (_apps.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No apps found. Please try restarting the app.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: _apps.length,
      itemBuilder: (context, index) {
        final app = _apps[index];
        final schedule = _schedules[app.packageName];
        final isBlocked = schedule != null;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: app.icon?.isNotEmpty == true
                ? Image.memory(app.icon!, width: 40)
                : const Icon(Icons.apps, size: 40),
            title: Text(app.name),
            subtitle: Text(
              isBlocked ? schedule.description : 'Not Blocked',
              style: TextStyle(
                color: isBlocked ? Colors.red.shade700 : Colors.green,
              ),
            ),
            trailing: Switch(
              value: isBlocked,
              onChanged: (value) {
                if (value) {
                  _openScheduleDialog(app.packageName);
                } else {
                  _updateSchedule(app.packageName, null);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionsRequiredView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.shield_outlined, size: 80, color: Colors.amber),
            const SizedBox(height: 24),
            Text(
              'Permissions Required',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'The app relies on these permissions to protect you. Please grant them for it to work properly.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            if (!_hasUsageAccess)
              ElevatedButton(
                onPressed: _requestUsageAccess,
                child: const Text('1. Grant Usage Access'),
              ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _requestOverlayPermission,
              child: const Text('2. Grant Overlay Permission'),
            ),
            const SizedBox(height: 12),
            if (!_hasNotificationAccess)
              ElevatedButton(
                onPressed: _requestNotificationAccess,
                child: const Text('3. Grant Notification Access'),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _requestBatteryOptimization,
              child: const Text('4. Grant Battery Optimization (Important)'),
            ),
          ],
        ),
      ),
    );
  }
}
