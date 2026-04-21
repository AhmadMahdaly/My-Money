import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/cache_helper/backup_service.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/Settings/more_page.dart';
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

  /// 🔹 Restore
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
      body: Stack(
        children: [
          Column(
            children: [
              BackupRestoreInfoCard(isFromMorePage: widget.isFromMorePage),
              const Spacer(),

              /// Backup Button
              if (widget.isFromMorePage)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CustomPrimaryButton(
                    color: Colors.green,
                    width: double.infinity,
                    onPressed: () => isLoading ? null : handleBackup(),
                    text: 'إنشاء نسخة احتياطية من البيانات',
                  ),
                ),

              20.verticalSpace,

              /// Restore Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CustomPrimaryButton(
                  color: Colors.orange,
                  width: double.infinity,
                  onPressed: () => isLoading ? null : handleRestore(),
                  text: 'استعادة النسخة الاحتياطية',
                ),
              ),
              if (widget.isFromMorePage) ...[
                20.verticalSpace,
                CustomOutLineMorePageCard(
                  mainAxisAlignment: MainAxisAlignment.center,
                  color: AppColors.errorColor,
                  icon: Image.asset(
                    'assets/image/png/quit.png',
                    height: 24.r,

                    color: AppColors.errorColor,
                  ),
                  text: 'حذف الحساب وتسجيل الخروج',
                  onTap: () async {
                    Future<void> refreshAllCubits() async {
                      await context.read<AuthCubit>().checkAuthStatus();
                      await context.read<TransactionCubit>().loadInitialData();
                      await context.read<MonthlyPlanCubit>().loadPlanForMonth(
                        DateTime.now(),
                      );
                      await context.read<WalletCubit>().loadWallets();
                      await context.read<FinancialGoalCubit>().loadGoals();
                      await context.read<DebtCubit>().processDueDebts(
                        context.read<TransactionCubit>(),
                        context.read<WalletCubit>(),
                      );
                    }

                    await showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تأكيد الخروج'),
                        content: const Text(
                          'هل أنت متأكد أنك تريد تسجيل الخروج وحذف كل بيانات الحساب؟',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                if (context.mounted) {
                                  await context.read<AuthCubit>().logout();
                                }
                                await CacheHelper.clearAllData();
                                await refreshAllCubits();
                                if (context.mounted) {
                                  context.go(AppRoutes.loginScreen);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  showCustomSnackBar(
                                    context,
                                    message: 'حدث خطأ أثناء تسجيل الخروج',
                                    backgroundColor: AppColors.errorColor,
                                  );
                                }
                              }
                            },
                            child: const Text('تأكيد'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                4.verticalSpace,
              ],

              55.verticalSpace,
            ],
          ),

          /// 🔹 Loading Overlay
          if (isLoading)
            ColoredBox(
              color: Colors.black.withAlpha(77),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class BackupRestoreInfoCard extends StatelessWidget {
  const BackupRestoreInfoCard({required this.isFromMorePage, super.key});
  final bool isFromMorePage;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(16.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Title
            // Row(
            //   children: [
            //     const Icon(Icons.info_outline, color: Colors.blue),
            //     8.horizontalSpace,
            //     Text(
            //       'النسخ الاحتياطي والاستعادة',
            //       style: AppTextStyle.style16Bold,
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 12),

            /// 🔹 Backup Section
            if (isFromMorePage) ...[
              const _Section(
                icon: Icons.backup,
                title: 'إنشاء نسخة احتياطية',
                description:
                    'يقوم بحفظ جميع بياناتك (المعاملات، المحافظ، الفئات، والخطط الشهرية) في ملف يمكنك مشاركته أو الاحتفاظ به.',
                color: Colors.green,
              ),
              24.verticalSpace,
            ],

            /// 🔹 Restore Section
            const _Section(
              icon: Icons.restore,
              title: 'استعادة نسخة احتياطية',
              description:
                  'يقوم بتحميل البيانات من ملف واستبدال البيانات الحالية بالكامل بالبيانات الموجودة في النسخة الاحتياطية.',
              color: Colors.orange,
            ),

            if (isFromMorePage) ...[
              12.verticalSpace,

              /// 🔥 Warning
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.withAlpha(77)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
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
          ],
        ),
      ),
    );
  }
}

/// 🔹 Section Widget
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
                  // fontSize: 10.sp,
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
