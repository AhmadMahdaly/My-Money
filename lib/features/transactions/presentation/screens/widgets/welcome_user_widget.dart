import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/intro/login/presentation/cubit/login_cubit.dart';

class WelcomeUserWidget extends StatelessWidget {
  const WelcomeUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
