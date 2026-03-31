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
        // Row(
        //   spacing: 8.w,
        //   children: [
        //     const Icon(
        //       Icons.check_circle,
        //       color: AppColors.primaryColor,
        //     ),
        //     Text(
        //       'من غير إنترنت.',
        //       style: AppTextStyles.style16W400.copyWith(
        //         color: AppColors.secondaryTextColor,
        //       ),
        //     ),
        //   ],
        // ),
        // Row(
        //   spacing: 8.w,
        //   children: [
        //     const Icon(
        //       Icons.check_circle,
        //       color: AppColors.primaryColor,
        //     ),
        //     Text(
        //       'من غير إعلانات.',
        //       style: AppTextStyles.style16W400.copyWith(
        //         color: AppColors.secondaryTextColor,
        //       ),
        //     ),
        //   ],
        // ),
        // Row(
        //   spacing: 8.w,
        //   children: [
        //     const Icon(
        //       Icons.check_circle,
        //       color: AppColors.primaryColor,
        //     ),
        //     Text(
        //       'وكل ده على تليفونك بس.',
        //       style: AppTextStyles.style16W400.copyWith(
        //         color: AppColors.secondaryTextColor,
        //       ),
        //     ),
        //   ],
        // ),
        8.verticalSpace,
        Text(
          '✨ يلا نبدأ… اكتب اسمك وخلينا ننطلق!',
          style: AppTextStyle.style16W400.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
