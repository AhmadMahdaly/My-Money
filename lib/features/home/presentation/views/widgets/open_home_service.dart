import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class OpenHomeRightService extends StatelessWidget {
  const OpenHomeRightService({
    required this.onTap,
    required this.text,
    required this.img,
    required this.color,
    super.key,
  });
  final void Function() onTap;
  final String text;
  final String img;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: SizeConfig.screenWidth,
        height: 100.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: Styles.style16W500.copyWith(
                color: AppColors.scaffoldBackgroundLightColor,
              ),
            ),
            Image.asset(
              img,
              color: AppColors.scaffoldBackgroundLightColor,
              height: 50.h,
              fit: BoxFit.fitHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class OpenHomeLeftService extends StatelessWidget {
  const OpenHomeLeftService({
    required this.onTap,
    required this.text,
    required this.img,
    required this.color,
    super.key,
  });
  final void Function() onTap;
  final String text;
  final String img;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: SizeConfig.screenWidth,
        height: 100.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              img,
              color: AppColors.scaffoldBackgroundLightColor,
              height: 40.h,
              fit: BoxFit.fitHeight,
            ),
            Text(
              text,
              style: Styles.style16W500.copyWith(
                color: AppColors.scaffoldBackgroundLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
