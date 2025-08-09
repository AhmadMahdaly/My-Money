import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/localization/s.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/services/cache_helper/cache_values.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/assets.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class SplashBody extends StatefulWidget {
  const SplashBody({
    super.key,
  });

  @override
  State<SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody> {
  @override
  void initState() {
    super.initState();
    initSplashScreen();
  }

  Future<void> initSplashScreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    await Future.delayed(const Duration(seconds: 1));
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );
    await initRedirect();
  }

  Future<void> initRedirect() async {
    userName =
        await CacheHelper.getData(key: CacheKeys.userName) as String? ?? '';

    if (userName != null && userName.isNotEmpty) {
      context.go(AppRoutes.homeScreen);
    } else {
      context.go(AppRoutes.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8.h,
      children: [
        SizedBox(
          height: SizeConfig.screenHeight / 8,
          child: const SvgImage(
            imagePath: Assets.imageSvgLogo,
            color: AppColors.blueLightColor,
          ),
        ),
        Text(
          S.of(context)!.tuneYourLife,
          textAlign: TextAlign.center,
          style: Styles.style20W900.copyWith(color: AppColors.blueLightColor),
        ),
      ],
    );
  }
}
