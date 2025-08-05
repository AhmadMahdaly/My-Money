import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class CustomPrimaryTextfield extends StatelessWidget {
  const CustomPrimaryTextfield({
    this.controller,
    this.focusNode,
    super.key,
    this.isPassword,
    this.suffix,
    this.validator,
    this.textInputAction,
    this.autofillHints,
    this.prefix,
    this.textAlign,
    this.text,
    this.style,
    this.readOnly,
    this.onTap,
    this.onChanged,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.maxLines = 1,
  });
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? isPassword;
  final Widget? suffix;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextAlign? textAlign;
  final String? text;
  final TextStyle? style;
  final bool? readOnly;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autofocus: autofocus,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly ?? false,
      style: style ?? Styles.style14W500,

      textAlign: textAlign ?? TextAlign.center,
      validator: validator,
      focusNode: focusNode,
      controller: controller,
      cursorColor: AppColors.forthColor,
      obscureText: isPassword ?? false,
      decoration: InputDecoration(
        hint: Text(
          text ?? '',
          style: style ?? Styles.style18W500,
        ),
        border: customOutlineInputBorder(),
        focusedBorder: customOutlineInputBorder(),
        enabledBorder: customOutlineInputBorder(),
        disabledBorder: customOutlineInputBorder(),
        suffixIcon: suffix,
        prefixIcon: prefix,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        filled: true,
        fillColor: AppColors.scaffoldBackgroundLightColor,
      ),

      textInputAction: textInputAction,
      autofillHints: autofillHints,
    );
  }

  OutlineInputBorder customOutlineInputBorder() {
    return OutlineInputBorder(
      gapPadding: 0,
      borderRadius: BorderRadius.circular(8.r),
      borderSide: const BorderSide(
        width: 0.50,
        strokeAlign: BorderSide.strokeAlignOutside,
        color: AppColors.primaryColor,
      ),
    );
  }
}
