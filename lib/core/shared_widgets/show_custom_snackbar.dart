import 'package:flutter/material.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

void showCustomSnackBar(
  BuildContext context, {
  String? message,
  Color? msgColor,
  Color? backgroundColor,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message ?? '',
        style: AppTextStyles.style16W600.copyWith(
          color: msgColor ?? AppColors.primaryTextColor,
        ),
      ),
      backgroundColor: backgroundColor,
    ),
  );
}
