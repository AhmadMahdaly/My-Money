import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
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
    context.go(AppRoutes.trackMoney);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8.h,
      children: [
        SizedBox(
          width: 150.w,
          height: 150.h,
          child: const SvgImage(
            imagePath: 'assets/image/logo.svg',
          ),
        ),
        Text(
          'فلوسي',
          textAlign: TextAlign.center,
          style: Styles.style20W700.copyWith(
            color: AppColors.blueLightColor,
            fontSize: 40.sp,
          ),
        ),
      ],
    );
  }
}
