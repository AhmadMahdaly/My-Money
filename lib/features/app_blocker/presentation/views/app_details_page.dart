import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/app_info.dart';
import 'package:opration/features/app_blocker/data/models/app_rule.dart';
import 'package:opration/features/app_blocker/data/repositories/rules_repository.dart';

class AppDetailsPage extends StatefulWidget {
  const AppDetailsPage({required this.app, super.key});
  final AppInfo app;

  @override
  State<AppDetailsPage> createState() => _AppDetailsPageState();
}

class _AppDetailsPageState extends State<AppDetailsPage> {
  late AppRule _rule;
  late bool _isRuleEnabled;
  late double _timeLimit;

  @override
  void initState() {
    super.initState();
    final rulesRepo = context.read<RulesRepository>();
    _rule = rulesRepo.getRuleForApp(widget.app.packageName);
    _isRuleEnabled = _rule.isEnabled;
    _timeLimit = _rule.timeLimitMinutes.toDouble();
  }

  void _saveRule() {
    final rulesRepo = context.read<RulesRepository>();
    final updatedRule = AppRule(
      packageName: widget.app.packageName,
      isEnabled: _isRuleEnabled,
      timeLimitMinutes: _timeLimit.toInt(),
    );
    rulesRepo.saveRule(updatedRule);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ القاعدة بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.app.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Image.memory(
                  widget.app.icon!,
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.app.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.app.packageName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),

            // Usage Stats Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.orange,
                      size: 30,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'الاستخدام اليومي: ${_rule.timeLimitMinutes} دقيقة',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Control Rules Section
            Text(
              'قواعد التحكم',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('تفعيل التحكم'),
                      subtitle: const Text(
                        'ضع حداً زمنياً لاستخدام هذا التطبيق',
                      ),
                      value: _isRuleEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isRuleEnabled = value;
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                    if (_isRuleEnabled) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحد الزمني اليومي: ${_timeLimit.toInt()} دقيقة',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Slider(
                              value: _timeLimit,
                              min: 15,
                              max: 240,
                              divisions: 15,
                              label: '${_timeLimit.toInt()} د',
                              onChanged: (value) {
                                setState(() {
                                  _timeLimit = value;
                                });
                              },
                              activeColor: Colors.teal,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('حفظ القاعدة'),
                onPressed: _saveRule,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
