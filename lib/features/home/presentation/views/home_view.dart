import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          spacing: 12.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            24.verticalSpace,
            Text(
              'Welcome $userName',
              style: Styles.style18W900.copyWith(
                color: AppColors.blueDarkColor,
              ),
            ),
            InkWell(
              onTap: () => context.push(AppRoutes.trackMoney),
              child: Container(
                alignment: Alignment.centerLeft,
                width: SizeConfig.screenWidth,
                height: 100.h,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.blueLightColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Track Your Money',
                  style: Styles.style16W500.copyWith(
                    color: AppColors.scaffoldBackgroundLightColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
