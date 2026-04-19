import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/services/launch_url.dart';
import 'package:opration/core/shared_widgets/app_version_widget.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/auth/presentation/cubit/login_cubit.dart';
import 'package:opration/features/debt/presentation/controllers/debt_cubit/debt_cubit.dart';
import 'package:opration/features/goals/presentation/controllers/financial_goal_cubit/financial_goal_cubit.dart';
import 'package:opration/features/monthly_plan/presentation/controllers/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(
        height: 16.h,
        title: '',
        isLeading: false,
        subTitle: const SubTitle(),
      ),
      body: ListView(
        children: [
          12.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/categories.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'إدارة مخصصات الدخل والمصاريف',
            onTap: () => context.pushNamed(AppRoutes.manageCategoriesScreen),
          ),
          4.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/refresh.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'إدارة العمليات المتكررة',
            onTap: () => context.pushNamed(AppRoutes.recurringOperationsScreen),
          ),
          4.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/shopping-cart.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'قائمة المشتريات',
            onTap: () => context.pushNamed(AppRoutes.shoppingListView),
          ),
          4.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/target.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'الأهداف المالية',
            onTap: () => context.pushNamed(AppRoutes.financialGoalsScreen),
          ),
          4.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/money-bag.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'الديون والإلتزامات',
            onTap: () => context.pushNamed(AppRoutes.debtsView),
          ),
          4.verticalSpace,
          CustomMorePageCard(
            icon: Image.asset(
              'assets/image/png/reset.png',
              height: 24.r,

              color: AppColors.scaffoldBackgroundLightColor,
            ),
            text: 'نسخ البيانات احتياطياً أو استعادتها',
            onTap: () => context.pushNamed(AppRoutes.backupScreen),
          ),
          8.verticalSpace,
          CustomOutLineMorePageCard(
            mainAxisAlignment: MainAxisAlignment.start,
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
      ),
      bottomNavigationBar: SizedBox(
        height: 120.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomOutLineMorePageCard(
              color: AppColors.forthColor.withAlpha(100),
              icon: Icon(
                Icons.file_upload_outlined,
                size: 18.r,
                color: AppColors.forthColor.withAlpha(100),
              ),
              text: 'تابع آخر التحسينات والتحديثات',
              onTap: () => launchURL(appGooglePlayUrl),
            ),
            10.verticalSpace,
            const AppVersionWidget(),
          ],
        ),
      ),
    );
  }
}

class CustomMorePageCard extends StatelessWidget {
  const CustomMorePageCard({
    required this.icon,
    required this.text,
    this.onTap,
    super.key,
  });
  final Widget icon;
  final String text;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Card(
          color: AppColors.primaryColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Row(
              children: [
                icon,
                12.horizontalSpace,
                Text(
                  text,
                  style: AppTextStyle.style14W400.copyWith(
                    color: AppColors.scaffoldBackgroundLightColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomOutLineMorePageCard extends StatelessWidget {
  const CustomOutLineMorePageCard({
    required this.icon,
    required this.text,
    this.color = AppColors.primaryColor,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.onTap,
    super.key,
  });
  final Widget? icon;
  final String text;
  final void Function()? onTap;
  final MainAxisAlignment mainAxisAlignment;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: color,
            ),
          ),

          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: mainAxisAlignment,
              children: [
                if (icon != null) icon!,
                12.horizontalSpace,
                Text(
                  text,
                  style: AppTextStyle.style14W400.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
