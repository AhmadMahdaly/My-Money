import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class Appthemes {
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: AppColors.blueLightColor,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundLightColor,
      fontFamily: GoogleFonts.cairo().fontFamily,

      textTheme: TextTheme(
        titleLarge: Styles.style20W800,
        titleMedium: Styles.style16W500,
      ),
      appBarTheme: AppBarTheme(
        iconTheme: const IconThemeData(
          color: AppColors.scaffoldBackgroundLightColor,
        ),
        toolbarHeight: 100.h,
        titleTextStyle: Styles.style16W700.copyWith(
          color: AppColors.scaffoldBackgroundLightColor,
        ),
        backgroundColor: AppColors.blueLightColor,
        surfaceTintColor: AppColors.scaffoldBackgroundLightColor,
      ),
    );
  }
}
