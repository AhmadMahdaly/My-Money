// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/monthly_plan/presentation/screens/widgets/analytics/monthly_analytics_data.dart';
import 'package:opration/features/monthly_plan/presentation/screens/widgets/analytics/spending_progress_ring.dart';

class OverviewAnalyticsCard extends StatelessWidget {
  const OverviewAnalyticsCard({required this.data, super.key});

  final MonthlyAnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).cardColor;
    return Card(
      color: surface,
      elevation: 4,
      shadowColor: Colors.black.withAlpha(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================== قسم التخطيط المالي ==================
            const _SectionHeader(
              title: 'التخطيط المالي',
              icon: Icons.flag_rounded,
            ),
            12.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    title: 'الدخل المتوقع',
                    value: data.expectedIncome,
                    accent: AppColors.primaryColor,
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: _StatTile(
                    title: 'تخطيط الميزانية',
                    value: data.plannedBudget,
                    accent: Colors.blueAccent,
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: _StatTile(
                    title: 'توفير متوقع',
                    value: data.expectedSavings,
                    accent: Colors.teal,
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            Divider(height: 1, color: AppColors.secondaryColor.withAlpha(100)),
            16.verticalSpace,

            // ================== قسم الواقع المتاح ==================
            const _SectionHeader(
              title: 'المتاح حالياً',
              icon: Icons.account_balance_wallet_rounded,
            ),
            12.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    title: 'رصيد مرحل',
                    value: data.previousBalance,
                    accent: data.previousBalance >= 0
                        ? AppColors.successColor
                        : AppColors.orangeColor,
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: _StatTile(
                    title: 'دخل الشهر',
                    value: data.currentMonthIncome,
                    accent: AppColors.successColor,
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: _StatTile(
                    title: 'إجمالي المتاح',
                    value: data.totalAvailable,
                    accent: AppColors.primaryColor,
                  ),
                ),
              ],
            ),

            16.verticalSpace,
            Divider(height: 1, color: AppColors.secondaryColor.withAlpha(100)),
            16.verticalSpace,

            // ================== قسم الاستهلاك والباقي ==================
            const _SectionHeader(
              title: 'الاستهلاك والرصيد',
              icon: Icons.pie_chart_rounded,
            ),
            16.verticalSpace,
            Row(
              children: [
                // الحلقة الدائرية
                SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SpendingProgressRing(
                        spendingPercentage: data.spendingPercentage,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${data.spendingPercentage.toStringAsFixed(1)}%',
                            style: AppTextStyle.style16W700.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Text(
                            'مُستهلك',
                            style: AppTextStyle.style9W500.copyWith(
                              color: AppColors.primaryColor.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                16.horizontalSpace,
                Expanded(
                  child: Column(
                    children: [
                      _StatTile(
                        title: 'المصروف الفعلي',
                        value: data.totalExpense,
                        accent: AppColors.errorColor,
                      ),
                      8.verticalSpace,
                      _StatTile(
                        title: 'الباقي الفعلي',
                        value: data.actualSavings,
                        accent: data.actualSavings >= 0
                            ? AppColors.successColor
                            : AppColors.errorColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.primaryColor.withAlpha(200)),
        6.horizontalSpace,
        Text(
          title,
          style: AppTextStyle.style14W600.copyWith(
            color: AppColors.primaryTextColor,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    required this.accent,
    this.dense = true,
    this.isLargeValue = false,
  });

  final String title;
  final double value;
  final Color accent;
  final bool dense;
  final bool isLargeValue;

  @override
  Widget build(BuildContext context) {
    final bg = accent.withAlpha(15);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: dense ? 10.h : 14.h,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: accent.withAlpha(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: (dense ? AppTextStyle.style9W500 : AppTextStyle.style12W500)
                .copyWith(
                  color: AppColors.primaryTextColor.withAlpha(170),
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          (dense ? 4 : 8).verticalSpace,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '${value.truncate()} ج.م',
              style:
                  (isLargeValue
                          ? AppTextStyle.style20Bold
                          : AppTextStyle.style14W600)
                      .copyWith(
                        color: accent,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
