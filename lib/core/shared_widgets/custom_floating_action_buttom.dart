import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({
    required this.onPressed,
    super.key,
    this.tooltip,
  });
  final void Function()? onPressed;
  final String? tooltip;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(320.r)),
      backgroundColor: AppColors.primaryColor,
      onPressed: onPressed,
      tooltip: tooltip,
      child: const Icon(
        Icons.add,
        color: AppColors.scaffoldBackgroundLightColor,
      ),
    );
  }
}
