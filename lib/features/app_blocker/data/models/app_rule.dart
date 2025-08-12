import 'package:hive/hive.dart';

part 'app_rule.g.dart'; // Run: flutter packages pub run build_runner build

@HiveType(typeId: 1)
class AppRule extends HiveObject {
  AppRule({
    required this.packageName,
    this.isEnabled = false,
    this.timeLimitMinutes = 60,
  });
  @HiveField(0)
  late String packageName;

  @HiveField(1)
  late bool isEnabled;

  @HiveField(2)
  late int timeLimitMinutes;
}
