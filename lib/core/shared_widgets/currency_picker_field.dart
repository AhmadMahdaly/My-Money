import 'package:flutter/material.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/models/app_currency.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class CurrencyPickerField extends StatelessWidget {
  const CurrencyPickerField({
    required this.selectedCode,
    required this.onChanged,
    this.showPreview = true,
    super.key,
  });

  final String selectedCode;
  final ValueChanged<String> onChanged;
  final bool showPreview;

  @override
  Widget build(BuildContext context) {
    // final selected = currencyByCode(selectedCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العملة',
          style: AppTextStyle.style14W600.copyWith(
            color: AppColors.primaryTextColor,
          ),
        ),
        8.verticalSpace,
        Container(
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackgroundLightColor,
            borderRadius: BorderRadius.circular(kRadius),
            border: Border.all(color: AppColors.secondaryColor),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedCode,
              items: kAppCurrencies
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency.code,
                      child: Text(
                        '${currency.nameAr} (${currency.symbol})',
                        style: AppTextStyle.style14W400,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (code) {
                if (code != null) onChanged(code);
              },
            ),
          ),
        ),
        // if (showPreview) ...[
        //   6.verticalSpace,
        //   Text(
        //     'معاينة: 1500 ${selected.symbol}.',
        //     style: AppTextStyle.style12W400.copyWith(
        //       fontSize: 11.sp,
        //       color: AppColors.secondaryTextColor,
        //     ),
        //   ),
        // ],
      ],
    );
  }
}
