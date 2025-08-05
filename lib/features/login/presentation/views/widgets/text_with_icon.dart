import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class TextWithIcon extends StatelessWidget {
  const TextWithIcon({required this.icon, required this.text, super.key});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6.w,
      children: [
        Icon(icon, size: 20.r, color: AppColors.blueLightColor),
        Text(
          text,
          style: Styles.style17W500,
        ),
      ],
    );
  }
}
