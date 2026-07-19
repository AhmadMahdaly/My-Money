import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class LoginWelcomeUserWidget extends StatelessWidget {
  const LoginWelcomeUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'دلوقتي تقدر تعرف فلوسك رايحة فين 💸',
            style: AppTextStyle.style18W700.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ),
        Text(
          'خطط شهريتك، احسب صافي دخلك، وشوف مصاريفك كلها في مكان واحد.',
          style: AppTextStyle.style16W400.copyWith(
            color: AppColors.secondaryTextColor,
          ),
        ),
        4.verticalSpace,
        Row(
          spacing: 8.w,
          children: [
            const Icon(
              Icons.volunteer_activism_rounded,
              color: AppColors.primaryColor,
            ),
            Text(
              'مجاني تماماً.',
              style: AppTextStyle.style16W500.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        Row(
          spacing: 8.w,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.primaryColor,
            ),
            Text(
              'من غير إنترنت.',
              style: AppTextStyle.style16W500.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        Row(
          spacing: 8.w,
          children: [
            const Icon(
              Icons.block_rounded,
              color: AppColors.primaryColor,
            ),
            Text(
              'من غير إعلانات.',
              style: AppTextStyle.style16W400.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),

        8.verticalSpace,
        Text(
          '✨ يلا نبدأ… اكتب اسمك وخلينا ننطلق!',
          style: AppTextStyle.style16W600.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
