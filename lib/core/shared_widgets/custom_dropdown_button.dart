import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class CustomDropdownButtonFormField<T> extends StatelessWidget {
  const CustomDropdownButtonFormField({
    required this.items,
    required this.onChanged,
    super.key,
    this.value,
    this.hintText,
    this.validator,
    this.prefix,
  });

  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final T? value;
  final String? hintText;
  final String? Function(T?)? validator;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      // الخصائص الأساسية
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,

      // خصائص التصميم
      isExpanded: true, // لجعل العنصر يملأ المساحة الأفقية
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.secondaryColor,
      ),
      style: Styles.style14W500.copyWith(
        color: AppColors.thirdColor,
      ), // ستايل النص المختار
      dropdownColor:
          AppColors.scaffoldBackgroundLightColor, // لون القائمة المنسدلة

      decoration: InputDecoration(
        // استخدام نفس الـ hint والـ style من الويدجت الأخرى
        hintText: hintText,
        hintStyle: Styles.style14W500.copyWith(
          color: AppColors.secondaryColor,
        ),

        // استخدام نفس الإطار (Border)
        border: customOutlineInputBorder(),
        focusedBorder: customOutlineInputBorder(),
        enabledBorder: customOutlineInputBorder(),
        disabledBorder: customOutlineInputBorder(),

        // بقية الخصائص
        prefixIcon: prefix,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
        filled: true,
        fillColor: AppColors.scaffoldBackgroundLightColor,
      ),
    );
  }
}
