import 'dart:async';

import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/services/cloud_auth_service.dart';
import 'package:opration/core/services/cloud_sync_service.dart';

class CloudAutoSyncService {
  static Timer? _debounceTimer;
  static Timer? _periodicTimer;
  static bool _isSyncRunning = false;
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    CacheHelper.addOnDataChangedListener((_) {
      _scheduleSync();
    });

    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _syncNow(),
    );
  }

  static void _scheduleSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 8), _syncNow);
  }

  static Future<void> _syncNow() async {
    if (_isSyncRunning) return;
    final user = CloudAuthService.currentUser;
    if (user == null) return;

    _isSyncRunning = true;
    try {
      await CloudSyncService.pushAllData(uid: user.uid);
    } catch (_) {
      // Silent by design for background sync.
    } finally {
      _isSyncRunning = false;
    }
  }
}
