import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/home/presentation/views/widgets/open_home_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: ListView(
          children: [
            18.verticalSpace,
            SizedBox(
              width: SizeConfig.screenWidth * 0.8,
              child: Text(
                overflow: TextOverflow.ellipsis,
                'Welcome $userName',
                style: Styles.style18W900.copyWith(
                  color: AppColors.blueDarkColor,
                ),
              ),
            ),
            18.verticalSpace,
            OpenHomeRightService(
              onTap: () => context.push(AppRoutes.trackMoney),
              text: 'Track Your Money',
              img: 'assets/image/png/money.png',
              color: AppColors.blueLightColor,
            ),
            // 12.verticalSpace,
            // OpenHomeRightService(
            //   onTap: () {},
            //   text: 'Track Your Thoughts',
            //   img: 'assets/image/png/thought.png',
            //   color: AppColors.orangeColor,
            // ),
            // 12.verticalSpace,
            // OpenHomeLeftService(
            //   onTap: () {},
            //   text: 'Do Your Tasks',
            //   img: 'assets/image/png/task-list.png',
            //   color: AppColors.primaryColor,
            // ),
            // 12.verticalSpace,
            // OpenHomeLeftService(
            //   onTap: () {},
            //   text: 'Enter Your Reads',
            //   img: 'assets/image/png/open-book.png',
            //   color: AppColors.blueDarkColor,
            // ),
            12.verticalSpace,
            OpenHomeRightService(
              onTap: () => context.push(AppRoutes.appBlockerScreen),
              text: 'Control Your Apps',
              img: 'assets/image/png/app-block.png',
              color: Colors.deepPurple.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
