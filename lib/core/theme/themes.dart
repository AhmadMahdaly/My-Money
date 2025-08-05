import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class Appthemes {
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundLightColor,
      fontFamily: GoogleFonts.cairo().fontFamily,

      textTheme: TextTheme(
        titleLarge: Styles.style20W800,
        titleMedium: Styles.style16W500,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        surfaceTintColor: AppColors.scaffoldBackgroundLightColor,
      ),
    );
  }
}
