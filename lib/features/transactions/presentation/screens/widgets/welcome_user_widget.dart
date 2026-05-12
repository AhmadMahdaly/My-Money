import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/auth/presentation/cubit/login_cubit.dart';

class WelcomeUserWidget extends StatelessWidget {
  const WelcomeUserWidget({
    required this.isLeading,
    super.key,
    this.title,
    this.leading,
  });
  final bool isLeading;
  final String? title;
  final Widget? leading;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null)
          leading!
        else if (isLeading)
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.scaffoldBackgroundLightColor,
            ),
          ),
        if (title != null && title!.isNotEmpty) ...[
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title!,
                textAlign: TextAlign.center,
                style: AppTextStyle.style18W700.copyWith(
                  color: AppColors.scaffoldBackgroundLightColor,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
        if (title != null && title!.isEmpty) const SizedBox.shrink(),
        if (title == null)
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return Text(
                  ' مرحبـــــًا بك ${state.username}',
                  style: AppTextStyle.style20W700.copyWith(
                    color: AppColors.scaffoldBackgroundLightColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              }

              return Text(
                ' مرحبـــــًا بك ',
                style: AppTextStyle.style20W700.copyWith(
                  color: AppColors.scaffoldBackgroundLightColor,
                ),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
      ],
    );
  }
}
