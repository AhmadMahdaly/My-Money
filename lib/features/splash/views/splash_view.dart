import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/services/cache_helper/cache_values.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundLightColor,
      body: SplashBody(),
    );
  }
}

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

    await Future.delayed(const Duration(seconds: 3));
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );
    await initRedirect();
  }

  Future<void> initRedirect() async {
    final userName =
        await CacheHelper.getData(key: CacheKeys.userName) as String;
    final isOnboardingComplete =
        await CacheHelper.getData(key: CacheKeys.isNotFirstOpen) as bool? ??
        false;

    if (!context.mounted) return;
    if (!isOnboardingComplete) {
      context.go(AppRoutes.onbordingScreen);
    } else if (userName != null && userName.isNotEmpty) {
    } else {
      context.go(AppRoutes.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Tune Your Life',
          textAlign: TextAlign.center,
          style: Styles.style20W900,
        ),
      ],
    );
  }
}
