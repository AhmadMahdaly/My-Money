import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        // title: Text('إدارة فئاتك', style: AppTextStyles.style20Bold),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          12.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/target.png',
              height: 30.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'أهدافك المالية',
            onTap: () => context.pushNamed(AppRoutes.financialGoalsScreen),
          ),
          4.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/categories.png',
              height: 30.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'إدارة فئات الدخل والمصاريف',
            onTap: () => context.pushNamed(AppRoutes.manageCategoriesScreen),
          ),
        ],
      ),
    );
  }
}

class CustomMorePageCard extends StatelessWidget {
  const CustomMorePageCard({
    required this.icon,
    required this.text,
    this.onTap,
    super.key,
  });
  final Widget icon;
  final String text;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Card(
          color: AppColors.primaryColor,
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                icon,
                12.horizontalSpace,
                Text(
                  text,
                  style: AppTextStyles.style16W400.copyWith(
                    color: AppColors.scaffoldBackgroundLightColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
