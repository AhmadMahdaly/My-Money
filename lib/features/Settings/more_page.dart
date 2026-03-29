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
        height: 16.h,
        title: '',
        isLeading: false,
        subTitle: const SubTitle(),
      ),
      body: ListView(
        children: [
          12.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/target.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'الأهداف المالية',
            onTap: () => context.pushNamed(AppRoutes.financialGoalsScreen),
          ),
          4.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/money-bag.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'الديون والإلتزامات',
            onTap: () => context.pushNamed(AppRoutes.debtsView),
          ),
          4.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/shopping-cart.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'قائمة المشتريات',
            onTap: () => context.pushNamed(AppRoutes.shoppingListView),
          ),
          4.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/categories.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'إدارة فئات الدخل والمصاريف',
            onTap: () => context.pushNamed(AppRoutes.manageCategoriesScreen),
          ),
          4.verticalSpace,
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 120.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomOutLineMorePageCard(
              icon: Icon(
                Icons.file_upload_outlined,
                size: 18.r,
                color: AppColors.primaryColor,
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
          color: AppColors.primaryColor,
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                icon,
                12.horizontalSpace,
                Text(
                  text,
                  style: AppTextStyles.style14W400.copyWith(
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
    this.onTap,
    super.key,
  });
  final Widget? icon;
  final String text;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primaryColor,
            ),
          ),

          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) icon!,
                12.horizontalSpace,
                Text(
                  text,
                  style: AppTextStyles.style14W400.copyWith(
                    color: AppColors.primaryColor,
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
