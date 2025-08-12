import 'package:hive/hive.dart';
import 'package:opration/features/app_blocker/data/models/app_rule.dart';

class RulesRepository {
  RulesRepository(this._rulesBox);
  final Box<AppRule> _rulesBox;

  Future<void> saveRule(AppRule rule) async {
    await _rulesBox.put(rule.packageName, rule);
  }

  AppRule getRuleForApp(String packageName) {
    return _rulesBox.get(packageName) ?? AppRule(packageName: packageName);
  }

  List<AppRule> getAllRules() {
    return _rulesBox.values.toList();
  }
}
