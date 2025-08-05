import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class CustomPrimaryButton extends StatelessWidget {
  const CustomPrimaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.width,
  });
  final void Function()? onPressed;
  final String text;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.blueLightColor),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: WidgetStateProperty.all(Size(width ?? 300.w, 52.h)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          ),
        ),
        child: Text(
          text,
          style: Styles.style16W700.copyWith(
            color: AppColors.scaffoldBackgroundLightColor,
          ),
        ),
      ),
    );
  }
}
