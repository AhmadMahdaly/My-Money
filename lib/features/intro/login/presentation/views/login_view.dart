import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/features/intro/login/presentation/cubit/login_cubit.dart';
import 'package:opration/features/intro/login/presentation/views/widgets/welcome_user_widget.dart';

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
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRoutes.mainLayout);
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
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    30.verticalSpace,
                    SvgImage(
                      imagePath: 'assets/image/logo.svg',
                      height: 150.h,
                    ),
                    24.verticalSpace,
                    const WelcomeUserWidget(),
                    30.verticalSpace,

                    CustomPrimaryTextfield(
                      controller: usernameController,
                      text: 'سجل اسمك',
                    ),
                    20.verticalSpace,
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
                        text: 'ابدأ',
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
