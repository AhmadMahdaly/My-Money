import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/welcome_user_widget.dart';

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PageHeader({
    required this.isLeading,
    this.title,
    this.height,
    this.heightBar,
    this.actions,
    this.bottom,
    this.subTitle,
    super.key,
  });
  final double? heightBar;
  final double? height;
  final String? title;
  final List<Widget>? actions;
  final bool isLeading;
  final Widget? bottom;
  final Widget? subTitle;
  @override
  Size get preferredSize => Size.fromHeight(heightBar ?? 130.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (height ?? 8.h),
        right: 16.w,
        left: 16.w,
        bottom: 12.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, -0),
          end: Alignment(0.50, 1),
          colors: [AppColors.primaryColor, AppColors.secondaryTextColor],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          8.verticalSpace,
          Row(
            children: [
              Expanded(
                child: WelcomeUserWidget(
                  isLeading: isLeading,
                  title: title,
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          if (subTitle != null) subTitle!,
          if (bottom != null) ...[const Spacer(), bottom!],
        ],
      ),
    );
  }
}

class SubTitle extends StatelessWidget {
  const SubTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgImage(
          imagePath: 'assets/image/svg/quote-1.svg',
          height: 14.h,
        ),
        4.horizontalSpace,
        Text(
          'ما تفعله الآن هو ما تجني ثماره في الغد',
          style: AppTextStyles.style14W400.copyWith(
            color: AppColors.scaffoldBackgroundLightColor,
          ),
        ),
        4.horizontalSpace,
        SvgImage(
          imagePath: 'assets/image/svg/quote-1.svg',
          height: 14.h,
        ),
      ],
    );
  }
}
