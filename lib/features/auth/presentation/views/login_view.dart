import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/app_settings_service.dart';
import 'package:opration/core/shared_widgets/currency_picker_field.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/features/auth/presentation/cubit/login_cubit.dart';
import 'package:opration/features/auth/presentation/views/widgets/welcome_user_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  late String _selectedCurrencyCode;

  @override
  void initState() {
    super.initState();
    _selectedCurrencyCode = AppSettingsService.savedCurrencyCode;
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(AppRoutes.backupScreen, extra: false);
            },
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRoutes.mainLayoutScreen);
          } else if (state is AuthFailure) {
            showCustomSnackBar(
              message: 'فشل تسجيل الدخول: حاول مرة أخرى',
              isError: true,
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgImage(
                      imagePath: 'assets/image/logo.svg',
                      height: 150.h,
                    ),
                    24.verticalSpace,
                    const LoginWelcomeUserWidget(),
                    24.verticalSpace,

                    CustomPrimaryTextfield(
                      controller: usernameController,
                      text: 'سجل اسمك',
                    ),
                    16.verticalSpace,
                    CurrencyPickerField(
                      selectedCode: _selectedCurrencyCode,
                      onChanged: (code) {
                        setState(() => _selectedCurrencyCode = code);
                      },
                    ),
                    36.verticalSpace,
                    if (state is AuthLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Column(
                        children: [
                          CustomPrimaryButton(
                            onPressed: () {
                              context.read<AuthCubit>().login(
                                usernameController.text.trim(),
                                currencyCode: _selectedCurrencyCode,
                              );
                            },
                            width: double.infinity,
                            text: 'ابدأ',
                          ),

                          // 12.verticalSpace,
                          // IconButton(
                          //   onPressed: () {
                          //     context.read<AuthCubit>().loginWithGoogle(
                          //       currencyCode: _selectedCurrencyCode,
                          //     );
                          //   },
                          //   icon: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Text(
                          //         'أو سجل الدخول بحساب جوجل',
                          //         style: AppTextStyle.style14W600.copyWith(
                          //           color: AppColors.primaryColor,
                          //         ),
                          //       ),
                          //       10.horizontalSpace,
                          //       SvgImage(
                          //         height: 30.h,
                          //         imagePath: 'assets/image/svg/google-icon.svg',
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          36.verticalSpace,
                        ],
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
