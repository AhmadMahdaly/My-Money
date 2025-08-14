import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgImage(
              imagePath: Assets.imageSvgLogo,
              height: 30.h,
              color: AppColors.scaffoldBackgroundLightColor,
            ),
            SizedBox(width: 8.w),
            Text(
              'tuneYourLife',
              style: AppTextStyles.style18W700.copyWith(
                color: AppColors.scaffoldBackgroundLightColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              showCustomSnackBar(
                context,
                message: 'Welcome back, ${state.username}!',
                msgColor: AppColors.scaffoldBackgroundLightColor,
                backgroundColor: AppColors.successColor,
              );
              context.go(AppRoutes.trackMoney);
            } else if (state is AuthFailure) {
              showCustomSnackBar(
                context,
                message: state.message,
                msgColor: AppColors.scaffoldBackgroundLightColor,
                backgroundColor: AppColors.errorColor,
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const WelcomeUserWidget(),
                  SizedBox(height: 24.h),
                  CustomPrimaryTextfield(
                    controller: usernameController,
                    text: 'Your name',
                    prefix: const Icon(
                      Icons.person,
                      color: AppColors.thirdColor,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  if (state is AuthLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    CustomPrimaryButton(
                      onPressed: () {
                        context.read<AuthCubit>().login(
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
