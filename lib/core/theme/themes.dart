import 'package:flutter/material.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class Appthemes {
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
      useMaterial3: true,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundLightColor,
      fontFamily: kPrimaryFont,

      textTheme: TextTheme(
        titleLarge: AppTextStyle.style18W800.copyWith(
          fontFamily: kPrimaryFont,
        ),
        titleMedium: AppTextStyle.style16W500.copyWith(
          fontFamily: kPrimaryFont,
        ),
      ),
      appBarTheme: AppBarTheme(
        iconTheme: const IconThemeData(
          color: AppColors.primaryColor,
        ),
        titleTextStyle: AppTextStyle.style18Bold.copyWith(
          color: AppColors.primaryTextColor,
          fontFamily: kPrimaryFont,
        ),
        surfaceTintColor: AppColors.scaffoldBackgroundLightColor,
      ),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.secondaryColor.withAlpha(77)),
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,

      /// Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.scaffoldBackgroundLightColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 5,
        titleTextStyle: AppTextStyle.style18Bold.copyWith(
          fontFamily: kPrimaryFont,
          color: AppColors.primaryColor,
        ),
      ),

      /// ستايل الزر الرئيسي (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor:
              AppColors.scaffoldBackgroundLightColor, // لون النص والأيقونة
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          textStyle: AppTextStyle.style12W500.copyWith(
            fontFamily: kPrimaryFont,
          ),
        ),
      ),

      /// ستايل الزر الثانوي (TextButton)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textGreyColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: AppTextStyle.style14W500.copyWith(
            fontFamily: kPrimaryFont,
          ),
        ),
      ),
    );
  }
}
