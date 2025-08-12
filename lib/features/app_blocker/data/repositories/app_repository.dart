import 'package:app_usage/app_usage.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class AppRepository {
  // Fetches installed apps using the new package
  Future<List<AppInfo>> getInstalledApps() async {
    return InstalledApps.getInstalledApps(
      true,
      true,
    ); // withIcon, excludeSystemApps
  }

  // Fetches usage stats for all apps
  Future<List<AppUsageInfo>> getUsageStats() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 1));
      final infoList = await AppUsage().getAppUsage(startDate, endDate);
      return infoList;
    } catch (e) {
      print('Could not get usage stats: $e');
      return [];
    }
  }
}
