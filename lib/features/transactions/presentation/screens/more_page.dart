import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/launch_url.dart';
import 'package:opration/core/shared_widgets/app_version_widget.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/intro/login/presentation/cubit/login_cubit.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _PageHeader(),
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
      bottomNavigationBar: SizedBox(
        height: 130.h,
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

class _PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const _PageHeader();

  @override
  Size get preferredSize => Size.fromHeight(85.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        right: 16.w,
        left: 16.w,
        bottom: 10.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, -0),
          end: Alignment(0.50, 1),
          colors: [AppColors.primaryColor, AppColors.secondaryTextColor],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 20.r,
              color: AppColors.scaffoldBackgroundLightColor,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return Text(
                      'مرحبــًا بك ${state.username}!',
                      style: AppTextStyles.style20W700.copyWith(
                        color: AppColors.scaffoldBackgroundLightColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }

                  return Text(
                    'مرحبــًا بك!',
                    style: AppTextStyles.style20W700.copyWith(
                      color: AppColors.scaffoldBackgroundLightColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              12.verticalSpace,
              Row(
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
