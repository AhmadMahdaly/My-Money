import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/localization/s.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/assets.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/login/presentation/cubit/login_cubit.dart';
import 'package:opration/features/login/presentation/views/widgets/welcome_user_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blueLightColor,
        title: Row(
          spacing: 8.w,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgImage(
              imagePath: Assets.imageSvgLogo,
              height: 30.h,
              color: AppColors.scaffoldBackgroundLightColor,
            ),
            Text(
              S.of(context)!.tuneYourLife,

              style: Styles.style18W700.copyWith(
                color: AppColors.scaffoldBackgroundLightColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              showCustomSnackBar(
                context,
                message: 'Successfully logged in as: ${state.username}',
                backgroundColor: AppColors.successColor,
              );
              context.go(AppRoutes.homeScreen);
            } else if (state is LoginFailure) {
              showCustomSnackBar(
                context,
                message: state.message,
                backgroundColor: AppColors.errorColor,
              );
            }
          },
          builder: (context, state) {
            if (state is LoginLoading) {
              return const LinearProgressIndicator();
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const WelcomeUserWidget(),
                  24.verticalSpace,
                  CustomPrimaryTextfield(
                    controller: usernameController,
                    text: 'Your name',
                    prefix: const Icon(
                      Icons.person,
                      color: AppColors.thirdColor,
                    ),
                  ),
                  20.verticalSpace,
                  CustomPrimaryButton(
                    onPressed: () {
                      context.read<LoginCubit>().login(
                        usernameController.text.trim(),
                      );
                    },
                    width: double.infinity,
                    text: 'Start',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
