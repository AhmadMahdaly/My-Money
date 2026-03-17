import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/launch_url.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/intro/login/presentation/cubit/login_cubit.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        toolbarHeight: 100.h,
        // centerTitle: true,
        // title: Text('إدارة فئاتك', style: AppTextStyles.style20Bold),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return Text(
                      'أهلاً ${state.username}!',
                      style: AppTextStyles.style20W700.copyWith(
                        color: AppColors.scaffoldBackgroundLightColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }

                  return Text(
                    'أهلاً بك!',
                    style: AppTextStyles.style20W700.copyWith(
                      color: AppColors.scaffoldBackgroundLightColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            Row(
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
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.scaffoldBackgroundLightColor,
          ),
          onPressed: () => context.pop(),
        ),
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
            text: 'أهدافك المالية',
            onTap: () => context.pushNamed(AppRoutes.financialGoalsScreen),
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
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 30.h),
        child: CustomOutLineMorePageCard(
          icon: Icon(
            Icons.file_upload_outlined,
            size: 18.r,
            color: AppColors.primaryColor,
          ),
          text: 'تابع آخر التحسينات والتحديثات',
          onTap: () => launchURL(
            'https://play.google.com/store/apps/details?id=com.mahdaly.mymoney',
          ),
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
