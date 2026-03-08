import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/intro/login/presentation/cubit/login_cubit.dart';

class WelcomeUserWidget extends StatelessWidget {
  const WelcomeUserWidget({required this.isLeading, super.key, this.title});
  final bool isLeading;
  final String? title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isLeading)
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.scaffoldBackgroundLightColor,
            ),
          ),
        if (isLeading && title != null) ...[
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title!,
                textAlign: TextAlign.center,
                style: AppTextStyles.style18W700.copyWith(
                  color: AppColors.scaffoldBackgroundLightColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          45.horizontalSpace,
        ],
        if (!isLeading || title == null)
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
      ],
    );
  }
}
