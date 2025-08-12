import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:opration/features/app_blocker/data/models/app_rule.dart';

class AppListItem extends StatelessWidget {
  const AppListItem({
    required this.app,
    required this.rule,
    required this.usage,
    required this.onTap,
    super.key,
  });
  final AppInfo app;
  final AppRule rule;
  final Duration usage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var usagePercentage = 0.0;
    if (rule.isEnabled && rule.timeLimitMinutes > 0) {
      usagePercentage = usage.inMinutes / rule.timeLimitMinutes;
    }

    final usageText = '${usage.inMinutes} دقيقة';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (app.icon != null)
                Image.memory(app.icon!, width: 40, height: 40)
              else
                const SizedBox(width: 40, height: 40, child: Icon(Icons.apps)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (rule.isEnabled)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: usagePercentage.clamp(0.0, 1.0),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$usageText / ${rule.timeLimitMinutes} دقيقة',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        usageText,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
