import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/cache_helper/backup_service.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
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

class BackupScreen extends StatefulWidget {
  const BackupScreen({required this.isFromMorePage, super.key});
  final bool isFromMorePage;
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool isLoading = false;

  // Future<void> _refreshAppData() async {
  //   await context.read<AuthCubit>().checkAuthStatus();
  //   await context.read<TransactionCubit>().loadInitialData();
  //   await context.read<MonthlyPlanCubit>().loadPlanForMonth(DateTime.now());
  //   await context.read<WalletCubit>().loadWallets();
  //   await context.read<FinancialGoalCubit>().loadGoals();
  //   await context.read<DebtCubit>().processDueDebts(
  //     context.read<TransactionCubit>(),
  //     context.read<WalletCubit>(),
  //   );
  // }
  // Future<void> _pushCloudSync() async {
  //   final success = await context.read<AuthCubit>().syncToCloud();
  //   if (mounted) {
  //     showCustomSnackBar(
  //       message: success ? 'تم رفع البيانات للسحابة' : 'فشل رفع البيانات',
  //       isError: !success,
  //     );
  //   }
  // }

  // Future<void> _deleteDataFromCloud() async {
  //   final success = await context.read<AuthCubit>().deleteDataFromCloud();
  //   if (mounted) {
  //     showCustomSnackBar(
  //       message: success ? 'تم حذف البيانات من السحابة' : 'فشل حذف البيانات',
  //       isError: !success,
  //     );
  //   }
  // }

  // Future<void> _pullCloudSync() async {
  //   final success = await context.read<AuthCubit>().restoreFromCloud();
  //   if (success) {
  //     await _refreshAppData();
  //   }
  //   if (mounted) {
  //     showCustomSnackBar(
  //       message: success ? 'تم استرجاع البيانات من السحابة' : 'فشل الاسترجاع',
  //       isError: !success,
  //     );
  //   }
  // }

  void _setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void _showToast(String msg, {bool isError = false}) {
    GlobalVariable.showMessage(msg, isError: isError);
  }

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
    return Scaffold(
      appBar: PageHeader(
        isLeading: true,
        height: 16.h,
        title: widget.isFromMorePage
            ? 'النسخ الاحتياطي والاستعادة'
            : 'استعادة النسخة الاحتياطية',
      ),
      body: isLoading
          ? ColoredBox(
              color: Colors.black.withAlpha(77),
              child: const Center(child: CircularProgressIndicator()),
            )
          : BlocConsumer<AuthCubit, AuthState>(
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
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (widget.isFromMorePage) ...[
                          12.verticalSpace,

                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(20),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.red.withAlpha(77),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                ),
                                8.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    'عند الاستعادة سيتم حذف البيانات الحالية واستبدالها بالكامل، تأكد من أخذ نسخة احتياطية أولاً إذا لزم الأمر.',
                                    style: AppTextStyle.style12W300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        16.verticalSpace,
                        if (widget.isFromMorePage) ...[
                          const _Section(
                            icon: Icons.backup,
                            title: 'سحب ملف كنسخة احتياطية',
                            description:
                                'يقوم بحفظ جميع بياناتك (المعاملات، المحافظ، الفئات، والخطط الشهرية) في ملف يمكنك مشاركته أو الاحتفاظ به.',
                            color: Colors.green,
                          ),
                          16.verticalSpace,

                          CustomPrimaryButton(
                            color: Colors.green,
                            width: double.infinity,
                            onPressed: () => isLoading ? null : handleBackup(),
                            text: 'مشاركة النسخة',
                          ),
                          8.verticalSpace,
                        ],
                        8.verticalSpace,
                        const Divider(color: AppColors.secondaryColor),

                        8.verticalSpace,
                        const _Section(
                          icon: Icons.restore,
                          title: 'استعادة البيانات من ملف سابق',
                          description:
                              'يقوم بتحميل البيانات من ملف واستبدال البيانات الحالية بالكامل بالبيانات الموجودة في النسخة الاحتياطية.',
                          color: Colors.orange,
                        ),
                        16.verticalSpace,
                        CustomPrimaryButton(
                          color: Colors.orange,
                          width: double.infinity,
                          onPressed: () => isLoading ? null : handleRestore(),
                          text: 'تحميل الملف',
                        ),

                        // 8.verticalSpace,
                        // if (widget.isFromMorePage) ...[
                        // if (CloudAuthService.isLoggedIn) ...[
                        //   16.verticalSpace,
                        //   OutlinedButton.icon(
                        //     style: OutlinedButton.styleFrom(
                        //       side: BorderSide.none,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(kRadius),
                        //       ),
                        //       backgroundColor: Colors.green,
                        //       minimumSize: Size(double.infinity, 52.h),
                        //     ),
                        //     onPressed: _pushCloudSync,
                        //     icon: const Icon(
                        //       Icons.cloud_upload_outlined,
                        //       color: Colors.white,
                        //     ),
                        //     label: Text(
                        //       'رفع نسخة سحابية الآن',
                        //       style: AppTextStyle.style14W600.copyWith(
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        //   8.verticalSpace,
                        //   OutlinedButton.icon(
                        //     style: OutlinedButton.styleFrom(
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(kRadius),
                        //       ),
                        //       side: BorderSide.none,
                        //       backgroundColor: AppColors.orangeColor,
                        //       minimumSize: Size(double.infinity, 52.h),
                        //     ),

                        //     onPressed: _pullCloudSync,
                        //     icon: const Icon(
                        //       Icons.cloud_download_outlined,
                        //       color: Colors.white,
                        //     ),
                        //     label: Text(
                        //       'استرجاع من السحابة',
                        //       style: AppTextStyle.style14W600.copyWith(
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        // ],
                        16.verticalSpace,
                        const Divider(color: AppColors.secondaryColor),
                        // ],
                        20.verticalSpace,
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadius),
                            ),
                            side: BorderSide.none,
                            backgroundColor: AppColors.errorColor,
                            minimumSize: Size(double.infinity, 52.h),
                          ),

                          icon: Image.asset(
                            'assets/image/png/quit.png',
                            height: 24.r,

                            color: AppColors.errorColor,
                          ),
                          label: Text(
                            'حذف البيانات وتسجيل الخروج',
                            style: AppTextStyle.style14W600.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () async {
                            Future<void> refreshAllCubits() async {
                              await context.read<AuthCubit>().checkAuthStatus();
                              await context
                                  .read<TransactionCubit>()
                                  .loadInitialData();
                              await context
                                  .read<MonthlyPlanCubit>()
                                  .loadAllPlans();
                              await context.read<WalletCubit>().loadWallets();
                              await context
                                  .read<FinancialGoalCubit>()
                                  .loadGoals();
                              await context.read<DebtCubit>().processDueDebts(
                                context.read<TransactionCubit>(),
                                context.read<WalletCubit>(),
                              );
                            }

                            await showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('تأكيد الحذف والخروج'),
                                content: const Text(
                                  'هل أنت متأكد أنك تريد حذف البيانات وتسجيل الخروج؟',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  if (state is AuthLoading)
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  else
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        try {
                                          // await _deleteDataFromCloud();
                                          await CacheHelper.clearAllData();
                                          await refreshAllCubits();

                                          if (context.mounted) {
                                            await context
                                                .read<AuthCubit>()
                                                .logout();
                                          }
                                        } catch (e) {
                                          showCustomSnackBar(
                                            message:
                                                'حدث خطأ أثناء حذف البيانات وتسجيل الخروج',
                                            isError: true,
                                          );
                                        }
                                      },
                                      child: const Text('تأكيد'),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),

                        55.verticalSpace,
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withAlpha(50),
          child: Icon(icon, color: color),
        ),
        10.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.style16Bold,
              ),
              4.verticalSpace,
              Text(
                description,
                style: AppTextStyle.style12W300.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
