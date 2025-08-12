import 'package:flutter/material.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class Appthemes {
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blueLightColor),
      useMaterial3: true,
      primaryColor: AppColors.blueLightColor,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundLightColor,
      fontFamily: kPrimaryFont,

      textTheme: TextTheme(
        titleLarge: Styles.style18W800,
        titleMedium: Styles.style16W500,
      ),
      appBarTheme: AppBarTheme(
        iconTheme: const IconThemeData(
          color: AppColors.scaffoldBackgroundLightColor,
        ),
        toolbarHeight: 100.h,
        titleTextStyle: Styles.style18Bold.copyWith(
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

      /// Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor:
            AppColors.scaffoldBackgroundLightColor, // لون خلفية النافذة
        shape: RoundedRectangleBorder(
          // شكل الحواف
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 5,
        titleTextStyle: Styles.style20Bold,
      ),

      /// ستايل الزر الرئيسي (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueLightColor, // لون خلفية الزر
          foregroundColor:
              AppColors.scaffoldBackgroundLightColor, // لون النص والأيقونة
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          textStyle: Styles.style12W500,
        ),
      ),

      /// ستايل الزر الثانوي (TextButton)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryColor, // لون النص
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: Styles.style14W500,
        ),
      ),
    );
  }
}
