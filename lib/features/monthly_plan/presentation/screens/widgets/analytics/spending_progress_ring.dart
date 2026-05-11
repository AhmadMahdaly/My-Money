import 'package:flutter/material.dart';
import 'package:opration/core/theme/colors.dart';

class SpendingProgressRing extends StatelessWidget {
  const SpendingProgressRing({
    required this.spendingPercentage,
    this.size = 140,
    this.strokeWidth = 18,
    super.key,
  });

  final double spendingPercentage;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final value = (spendingPercentage / 100).clamp(0.0, 1.0);
    final color = spendingPercentage > 90
        ? AppColors.errorColor
        : AppColors.successColor;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: v,
            strokeWidth: strokeWidth,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha(18),
            color: color,
          ),
        );
      },
    );
  }
}
