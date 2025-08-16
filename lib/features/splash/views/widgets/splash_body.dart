import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/login/presentation/cubit/login_cubit.dart';

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        Future.delayed(const Duration(seconds: 2), () {
          if (state is Authenticated) {
            context.go(AppRoutes.mainLayout);
          } else if (state is Unauthenticated) {
            context.go(AppRoutes.loginScreen);
          }
        });
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
        );
      },
      child: Column(
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
            style: AppTextStyles.style20W700.copyWith(
              color: AppColors.primaryColor,
              fontSize: 40.sp,
            ),
          ),
          10.verticalSpace,
          Text(
            kAppQuote,
            textAlign: TextAlign.center,
            style: AppTextStyles.style20W400.copyWith(
              color: AppColors.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
