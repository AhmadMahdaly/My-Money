import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/models/app_currency.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/app_settings_service.dart';
import 'package:opration/core/services/cache_helper/backup_service.dart';
import 'package:opration/core/shared_widgets/currency_picker_field.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/auth/presentation/cubit/login_cubit.dart';
import 'package:opration/features/debt/presentation/controllers/debt_cubit/debt_cubit.dart';
import 'package:opration/features/goals/presentation/controllers/financial_goal_cubit/financial_goal_cubit.dart';
import 'package:opration/features/intro/my_app.dart';
import 'package:opration/features/monthly_plan/presentation/controllers/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final _nameController = TextEditingController();
  late String _selectedCurrencyCode;
  // bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrencyCode = AppSettingsService.savedCurrencyCode;
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _nameController.text = authState.username;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showCustomSnackBar(message: 'متنساش تسجل اسمك', isError: true);
      return;
    }

    try {
      await context.read<AuthCubit>().updateUsername(name);
      await AppSettingsService.saveCurrencyCode(_selectedCurrencyCode);

      // await CloudSyncService.touchLocalUpdate();

      if (!mounted) return;
      showCustomSnackBar(message: 'تم حفظ الإعدادات');
      context.pop();
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(message: 'فشل حفظ الإعدادات', isError: true);
      }
    }
  }

  bool isLoading = false;

  void _setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void _showToast(String msg, {bool isError = false}) {
    GlobalVariable.showMessage(msg, isError: isError);
  }

  /// 🔹 Backup
  Future<void> handleBackup() async {
    try {
      _setLoading(true);

      await BackupService.shareBackup();

      _showToast('تم حفظ النسخة الاحتياطية');
    } catch (e) {
      _showToast('فشل حفظ النسخة الاحتياطية', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> handleRestore() async {
    try {
      _setLoading(true);

      await BackupService.restoreFromJson();

      // await CloudSyncService.touchLocalUpdate();

      if (!mounted) return;
      await _refreshAllCubits();
      _showToast('تم استعادة نسخة من البيانات بنجاح');
    } catch (e) {
      if (!mounted) return;
      _showToast('فشل استعادة النسخة', isError: true);
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  Future<void> _refreshAllCubits() async {
    await context.read<AuthCubit>().checkAuthStatus();
    await context.read<TransactionCubit>().loadInitialData();

    await context.read<MonthlyPlanCubit>().loadPlanForMonth(DateTime.now());
    await context.read<WalletCubit>().loadWallets();
    await context.read<FinancialGoalCubit>().loadGoals();
    await context.read<DebtCubit>().processDueDebts(
      context.read<TransactionCubit>(),
      context.read<WalletCubit>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCurrency = currencyByCode(_selectedCurrencyCode);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          showCustomSnackBar(
            message: 'تم تسجيل الدخول كـ ${state.username}',
          );
        }
        if (state is Unauthenticated) {
          showCustomSnackBar(
            message: 'تم حذف البيانات وتسجيل الخروج',
          );
          if (context.mounted) {
            context.go(AppRoutes.loginScreen);
          }
        } else if (state is AuthFailure) {
          showCustomSnackBar(
            message: state.message,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: PageHeader(
            isLeading: true,
            height: 16.h,
            title: 'إعدادات التطبيق',
          ),
          body: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              Text(
                'الاسم',
                style: AppTextStyle.style14W600.copyWith(
                  color: AppColors.primaryTextColor,
                ),
              ),
              8.verticalSpace,
              CustomPrimaryTextfield(
                controller: _nameController,
                text: 'اسمك كما يظهر في التطبيق',
                textInputAction: TextInputAction.next,
              ),
              24.verticalSpace,
              CurrencyPickerField(
                selectedCode: _selectedCurrencyCode,
                onChanged: (code) =>
                    setState(() => _selectedCurrencyCode = code),
              ),
              8.verticalSpace,
              Text(
                'العملة الحالية: ${selectedCurrency.nameAr}',
                style: AppTextStyle.style12W400.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),
              32.verticalSpace,

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomPrimaryButton(
                    width: double.infinity,
                    text: 'حفظ الإعدادات',
                    onPressed: _saveSettings,
                  ),
                  16.verticalSpace,
                  const Divider(color: AppColors.secondaryColor),
                  16.verticalSpace,

                  // if (!CloudAuthService.isLoggedIn) ...[
                  //   8.verticalSpace,
                  Text(
                    'نسخ البيانات احتياطياً أو استعادتها',
                    style: AppTextStyle.style14W600.copyWith(
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  16.verticalSpace,
                  OutlinedButton.icon(
                    onPressed: () => context.pushNamed(
                      AppRoutes.backupScreen,
                      extra: true,
                    ),
                    icon: Image.asset(
                      'assets/image/png/reset.png',
                      height: 20.r,

                      color: AppColors.primaryColor,
                    ),
                    label: const Text('إدارة نسخ البيانات'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kRadius),
                      ),
                      minimumSize: Size(double.infinity, 52.h),
                    ),
                  ),
                  // ] else if (CloudAuthService.isLoggedIn) ...[
                  //   8.verticalSpace,
                  //   Text(
                  //     'التخزين السحابي غير مفعل',
                  //     style: AppTextStyle.style14W600.copyWith(
                  //       color: AppColors.primaryTextColor,
                  //     ),
                  //   ),
                  //   16.verticalSpace,
                  //   if (state is AuthLoading)
                  //     const Center(child: CircularProgressIndicator())
                  //   else
                  //     OutlinedButton.icon(
                  //       onPressed: () {
                  //         context.read<AuthCubit>().loginWithGoogle(
                  //           currencyCode: _selectedCurrencyCode,
                  //         );
                  //       },
                  //       style: OutlinedButton.styleFrom(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(kRadius),
                  //         ),
                  //         minimumSize: Size(double.infinity, 52.h),
                  //       ),
                  //       icon: const Icon(Icons.login),
                  //       label: const Text('تسجيل الدخول بحساب جوجل'),
                  //     ),
                  // ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
