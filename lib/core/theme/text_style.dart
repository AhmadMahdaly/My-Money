import 'package:flutter/cupertino.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';

/// ===============================
/// Font base sizes
/// ===============================
final double size9 = 10.sp;
final double size12 = 11.sp;
final double size14 = 12.sp;
final double size16 = 13.sp;
final double size18 = 15.sp;
final double size20 = 17.sp;

/// ===============================
/// Font scale configuration
/// ===============================
class FontScaleConfig {
  static double scale = 1.0;
}

/// ===============================
/// App Text Styles
/// ===============================
abstract class AppTextStyles {
  static String get _fontFamily => kPrimaryFont;

  // ================= size 9 =================
  static TextStyle get style9W300 =>
      _base(phone: size9, tablet: 11, weight: FontWeight.w300);

  static TextStyle get style9W400 =>
      style9W300.copyWith(fontWeight: FontWeight.w400);
  static TextStyle get style9W500 =>
      style9W300.copyWith(fontWeight: FontWeight.w500);
  static TextStyle get style9W600 =>
      style9W300.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get style9W700 =>
      style9W300.copyWith(fontWeight: FontWeight.w700);
  static TextStyle get style9W800 =>
      style9W300.copyWith(fontWeight: FontWeight.w800);
  static TextStyle get style9W900 =>
      style9W300.copyWith(fontWeight: FontWeight.w900);
  static TextStyle get style9Bold =>
      style9W300.copyWith(fontWeight: FontWeight.bold);

  // ================= size 12 =================
  static TextStyle get style12W300 =>
      _base(phone: size12, tablet: 14, weight: FontWeight.w300);

  static TextStyle get style12W400 =>
      style12W300.copyWith(fontWeight: FontWeight.w400);
  static TextStyle get style12W500 =>
      style12W300.copyWith(fontWeight: FontWeight.w500);
  static TextStyle get style12W600 =>
      style12W300.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get style12W700 =>
      style12W300.copyWith(fontWeight: FontWeight.w700);
  static TextStyle get style12W800 =>
      style12W300.copyWith(fontWeight: FontWeight.w800);
  static TextStyle get style12W900 =>
      style12W300.copyWith(fontWeight: FontWeight.w900);
  static TextStyle get style12Bold =>
      style12W300.copyWith(fontWeight: FontWeight.bold);

  // ================= size 14 =================
  static TextStyle get style14W300 =>
      _base(phone: size14, tablet: 16, weight: FontWeight.w300);

  static TextStyle get style14W400 =>
      style14W300.copyWith(fontWeight: FontWeight.w400);
  static TextStyle get style14W500 =>
      style14W300.copyWith(fontWeight: FontWeight.w500);
  static TextStyle get style14W600 =>
      style14W300.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get style14W700 =>
      style14W300.copyWith(fontWeight: FontWeight.w700);
  static TextStyle get style14W800 =>
      style14W300.copyWith(fontWeight: FontWeight.w800);
  static TextStyle get style14W900 =>
      style14W300.copyWith(fontWeight: FontWeight.w900);
  static TextStyle get style14Bold =>
      style14W300.copyWith(fontWeight: FontWeight.bold);

  // ================= size 16 =================
  static TextStyle get style16W300 =>
      _base(phone: size16, tablet: 18, weight: FontWeight.w300);

  static TextStyle get style16W400 =>
      style16W300.copyWith(fontWeight: FontWeight.w400);
  static TextStyle get style16W500 =>
      style16W300.copyWith(fontWeight: FontWeight.w500);
  static TextStyle get style16W600 =>
      style16W300.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get style16W700 =>
      style16W300.copyWith(fontWeight: FontWeight.w700);
  static TextStyle get style16W800 =>
      style16W300.copyWith(fontWeight: FontWeight.w800);
  static TextStyle get style16W900 =>
      style16W300.copyWith(fontWeight: FontWeight.w900);
  static TextStyle get style16Bold =>
      style16W300.copyWith(fontWeight: FontWeight.bold);

  // ================= size 18 =================
  static TextStyle get style18W300 =>
      _base(phone: size18, tablet: 20, weight: FontWeight.w300);

  static TextStyle get style18W400 =>
      style18W300.copyWith(fontWeight: FontWeight.w400);
  static TextStyle get style18W500 =>
      style18W300.copyWith(fontWeight: FontWeight.w500);
  static TextStyle get style18W600 =>
      style18W300.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get style18W700 =>
      style18W300.copyWith(fontWeight: FontWeight.w700);
  static TextStyle get style18W800 =>
      style18W300.copyWith(fontWeight: FontWeight.w800);
  static TextStyle get style18W900 =>
      style18W300.copyWith(fontWeight: FontWeight.w900);
  static TextStyle get style18Bold =>
      style18W300.copyWith(fontWeight: FontWeight.bold);

  // ================= size 20 =================
  static TextStyle get style20W300 =>
      _base(phone: size20, tablet: 22, weight: FontWeight.w300);

  static TextStyle get style20W400 =>
      style20W300.copyWith(fontWeight: FontWeight.w400);
  static TextStyle get style20W500 =>
      style20W300.copyWith(fontWeight: FontWeight.w500);
  static TextStyle get style20W600 =>
      style20W300.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get style20W700 =>
      style20W300.copyWith(fontWeight: FontWeight.w700);
  static TextStyle get style20W800 =>
      style20W300.copyWith(fontWeight: FontWeight.w800);
  static TextStyle get style20W900 =>
      style20W300.copyWith(fontWeight: FontWeight.w900);
  static TextStyle get style20Bold =>
      style20W300.copyWith(fontWeight: FontWeight.bold);

  // ================= base builder =================
  static TextStyle _base({
    required double phone,
    required double tablet,
    required FontWeight weight,
  }) {
    return TextStyle(
      fontSize: SizeConfig.responsiveValue(
        phone: (phone * FontScaleConfig.scale).sp,
        tablet: (tablet * FontScaleConfig.scale).sp,
      ),
      fontWeight: weight,
      fontFamily: _fontFamily,
    );
  }
}
