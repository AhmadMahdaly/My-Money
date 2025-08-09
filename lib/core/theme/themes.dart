import 'package:flutter/material.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class Appthemes {
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: AppColors.blueLightColor,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundLightColor,
      fontFamily: kPrimaryFont,

      textTheme: TextTheme(
        titleLarge: Styles.style20W800,
        titleMedium: Styles.style16W500,
      ),
      appBarTheme: AppBarTheme(
        iconTheme: const IconThemeData(
          color: AppColors.scaffoldBackgroundLightColor,
        ),
        toolbarHeight: 100.h,
        titleTextStyle: Styles.style20Bold.copyWith(
          color: AppColors.scaffoldBackgroundLightColor,
        ),
        backgroundColor: AppColors.blueLightColor,
        surfaceTintColor: AppColors.scaffoldBackgroundLightColor,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
