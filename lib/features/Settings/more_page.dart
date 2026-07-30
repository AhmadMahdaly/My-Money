import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/launch_url.dart';
import 'package:opration/core/shared_widgets/app_version_widget.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(
        height: 32.h,
        title: '',
        isLeading: false,
        subTitle: const SubTitle(),
      ),
      body: ListView(
        children: [
          8.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/categories.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'إدارة فئات الدخل والمصاريف',
            onTap: () => context.pushNamed(AppRoutes.manageCategoriesScreen),
          ),
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/refresh.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'إدارة العمليات المتكررة',
            onTap: () => context.pushNamed(AppRoutes.recurringOperationsScreen),
          ),

          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/money-bag.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'الديون والإلتزامات',
            onTap: () => context.pushNamed(AppRoutes.debtsView),
          ),
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/money-bag.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'المستحقات والتحصيلات',
            onTap: () => context.pushNamed(AppRoutes.creditsView),
          ),
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/target.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'مدخراتك وأهدافك المالية',
            onTap: () => context.pushNamed(AppRoutes.financialGoalsScreen),
          ),
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/shopping-cart.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'قائمة المشتريات',
            onTap: () => context.pushNamed(AppRoutes.shoppingListView),
          ),

          CustomMorePageCard(
            icon: Icon(
              Icons.settings_outlined,
              size: 24.r,
              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'إعدادات التطبيق',
            onTap: () => context.pushNamed(AppRoutes.appSettingsScreen),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 120.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomOutLineMorePageCard(
              color: AppColors.forthColor.withAlpha(100),
              icon: Icon(
                Icons.file_upload_outlined,
                size: 18.r,
                color: AppColors.forthColor.withAlpha(100),
              ),
              text: 'تابع آخر التحسينات والتحديثات',
              onTap: () => launchURL(appGooglePlayUrl),
            ),
            10.verticalSpace,
            const AppVersionWidget(),
          ],
        ),
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
          color: AppColors.primaryColor.withAlpha(250),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            child: Row(
              children: [
                icon,
                12.horizontalSpace,
                Text(
                  text,
                  style: AppTextStyle.style14W400.copyWith(
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

class CustomOutLineMorePageCard extends StatelessWidget {
  const CustomOutLineMorePageCard({
    required this.icon,
    required this.text,
    this.color = AppColors.primaryColor,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.onTap,
    super.key,
  });
  final Widget? icon;
  final String text;
  final void Function()? onTap;
  final MainAxisAlignment mainAxisAlignment;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius),
            border: Border.all(
              color: color,
            ),
          ),

          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: mainAxisAlignment,
              children: [
                if (icon != null) icon!,
                12.horizontalSpace,
                Text(
                  text,
                  style: AppTextStyle.style14W400.copyWith(
                    color: color,
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
