import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/monthly_plan/domain/entities/monthly_plan.dart';
import 'package:opration/features/monthly_plan/presentation/controllers/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';

/// Legacy analytics screen (kept for reference).
/// The active analytics screen lives under monthly_plan feature.
class MonthlyAnalyticsScreen extends StatelessWidget {
  const MonthlyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionState = context.watch<TransactionCubit>().state;
    final planState = context.watch<MonthlyPlanCubit>().state;

    if (transactionState.isLoading ||
        planState.status == MonthlyPlanStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentMonth = planState.currentMonth;
    final startOfCurrentMonth = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );

    final previousTransactions = transactionState.allTransactions.where(
      (t) => t.date.isBefore(startOfCurrentMonth),
    );
    final previousIncome = previousTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final previousExpense = previousTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final previousMonthBalance = previousIncome - previousExpense;

    final currentMonthTransactions = transactionState.allTransactions
        .where(
          (t) =>
              t.date.year == currentMonth.year &&
              t.date.month == currentMonth.month,
        )
        .toList();

    final currentMonthIncome = currentMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = currentMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalAvailable = previousMonthBalance + currentMonthIncome;
    final savedAmount = totalAvailable - totalExpense;

    final spendingPercentage = totalAvailable > 0
        ? (totalExpense / totalAvailable) * 100
        : 0.0;

    final expenseCategories = transactionState.allCategories
        .where((c) => c.type == TransactionType.expense && c.parentId == null)
        .toList();

    final categorySpent = <TransactionCategory, double>{};
    for (final category in expenseCategories) {
      final subCatIds = transactionState.allCategories
          .where((c) => c.parentId == category.id)
          .map((c) => c.id)
          .toList();

      final spent = currentMonthTransactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                (t.categoryId == category.id ||
                    subCatIds.contains(t.categoryId)),
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      if (spent > 0) {
        categorySpent[category] = spent;
      }
    }

    final sortedCategories = categorySpent.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final subCategorySpent = <TransactionCategory, double>{};

    for (final category in expenseCategories) {
      final subCategories = transactionState.allCategories
          .where((c) => c.parentId == category.id)
          .toList();

      for (final sub in subCategories) {
        final spent = currentMonthTransactions
            .where(
              (t) =>
                  t.type == TransactionType.expense && t.categoryId == sub.id,
            )
            .fold(0.0, (sum, t) => sum + t.amount);

        if (spent > 0) {
          subCategorySpent[sub] = spent;
        }
      }
    }
    final sortedSubCategories = subCategorySpent.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Scaffold(
      appBar: PageHeader(
        isLeading: true,
        height: 16.h,
        title: 'تحليل شهر ${DateFormat.MMMM('ar').format(currentMonth)}',
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          _OverviewCard(
            previousBalance: previousMonthBalance,
            currentMonthIncome: currentMonthIncome,
            totalAvailable: totalAvailable,
            totalExpense: totalExpense,
            savedAmount: savedAmount,
            spendingPercentage: spendingPercentage,
          ),
          20.verticalSpace,

          SmartInsightsCard(
            currentMonthTransactions: currentMonthTransactions,
            sortedCategories: sortedSubCategories,
            totalAvailable: totalAvailable,
            totalExpense: totalExpense,
            plan: planState.plan!,
            allCategories: transactionState.allCategories,
          ),
          20.verticalSpace,

          Text(
            'أين تذهب أموالك؟',
            style: AppTextStyle.style16W600.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          12.verticalSpace,
          if (sortedCategories.isEmpty)
            const Center(child: Text('لا توجد مصاريف مسجلة هذا الشهر.'))
          else
            ...sortedCategories.map((entry) {
              final percentage = (entry.value / totalExpense) * 100;
              return _CategoryBarChart(
                category: entry.key,
                amount: entry.value,
                percentage: percentage,
              );
            }),

          40.verticalSpace,
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.previousBalance,
    required this.currentMonthIncome,
    required this.totalAvailable,
    required this.totalExpense,
    required this.savedAmount,
    required this.spendingPercentage,
  });
  final double previousBalance;
  final double currentMonthIncome;
  final double totalAvailable;
  final double totalExpense;
  final double savedAmount;
  final double spendingPercentage;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryColor,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Text(
              'معدل الصرف من إجمالي المتاح',
              style: AppTextStyle.style14W500.copyWith(color: Colors.white70),
            ),
            30.verticalSpace,
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140.r,
                  height: 140.r,
                  child: AnimatedCircularProgress(
                    spendingPercentage: spendingPercentage,
                  ),
                ),
                Text(
                  '${spendingPercentage.toStringAsFixed(1)}%',
                  style: AppTextStyle.style20Bold.copyWith(color: Colors.white),
                ),
              ],
            ),
            30.verticalSpace,
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    title: 'رصيد مرحل',
                    amount: previousBalance,
                    color: Colors.white,
                  ),
                  _StatItem(
                    title: 'دخل الشهر',
                    amount: currentMonthIncome,
                    color: Colors.white,
                  ),
                  _StatItem(
                    title: 'إجمالي المتاح',
                    amount: totalAvailable,
                    color: AppColors.successColor,
                  ),
                ],
              ),
            ),
            12.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  title: 'المصروف الفعلي',
                  amount: totalExpense,
                  color: AppColors.orangeColor,
                ),
                _StatItem(
                  title: 'الباقي (الرصيد)',
                  amount: savedAmount,
                  color: AppColors.successColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.amount,
    required this.color,
  });
  final String title;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyle.style12W500.copyWith(color: Colors.white70),
        ),
        4.verticalSpace,
        Text(
          '${amount.truncate()}',
          style: AppTextStyle.style14Bold.copyWith(color: color),
        ),
      ],
    );
  }
}

class _CategoryBarChart extends StatelessWidget {
  const _CategoryBarChart({
    required this.category,
    required this.amount,
    required this.percentage,
  });
  final TransactionCategory category;
  final double amount;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: category.color, radius: 8.r),
                  8.horizontalSpace,
                  Text(category.name, style: AppTextStyle.style14W500),
                ],
              ),
              Text(
                '${amount.truncate()} ج (${percentage.toStringAsFixed(1)}%)',
                style: AppTextStyle.style12W500.copyWith(
                  color: AppColors.secondaryColor,
                ),
              ),
            ],
          ),
          6.verticalSpace,
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percentage / 100),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: category.color.withAlpha(30),
                  color: category.color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SmartInsightsCard extends StatelessWidget {
  const SmartInsightsCard({
    required this.sortedCategories,
    required this.totalAvailable,
    required this.totalExpense,
    required this.plan,
    required this.currentMonthTransactions,
    required this.allCategories,
    super.key,
  });

  final List<MapEntry<TransactionCategory, double>> sortedCategories;
  final double totalAvailable;
  final double totalExpense;
  final MonthlyPlan plan;
  final List<Transaction> currentMonthTransactions;
  final List<TransactionCategory> allCategories;

  @override
  Widget build(BuildContext context) {
    final insights = <Widget>[];

    // ================================
    // 🔥 1. استخراج SubCategories
    // ================================
    final subCategorySpent = <TransactionCategory, double>{};

    for (final cat in allCategories.where((c) => c.parentId != null)) {
      final spent = currentMonthTransactions
          .where((t) => t.categoryId == cat.id)
          .fold(0.0, (sum, t) => sum + t.amount);

      if (spent > 0) {
        subCategorySpent[cat] = spent;
      }
    }

    final sortedSubCategories = subCategorySpent.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // ================================
    // 🧨 2. أكبر SubCategories
    // ================================
    if (sortedSubCategories.isNotEmpty) {
      final topSubs = sortedSubCategories.take(3).toList();

      final details = topSubs
          .map((e) {
            final percent = (e.value / totalExpense) * 100;
            return '${e.key.name} (${percent.toStringAsFixed(1)}%)';
          })
          .join(' - ');

      insights.add(
        _InsightRow(
          icon: Icons.search,
          color: AppColors.primaryColor,
          title: 'مصادر الصرف الحقيقية',
          text: 'أكبر استهلاك لديك جاء من: $details، وليس فقط الفئات العامة.',
        ),
      );
    }

    // ================================
    // ⚠️ 3. تسريبات قوية (Sub)
    // ================================
    for (final entry in sortedSubCategories.take(3)) {
      final percent = (entry.value / totalExpense) * 100;

      if (percent > 20) {
        insights.add(
          _InsightRow(
            icon: Icons.warning_amber,
            color: AppColors.orangeColor,
            title: 'تسريب مالي واضح',
            text:
                '(${entry.key.name}) تمثل ${percent.toStringAsFixed(1)}% من إجمالي مصاريفك.',
          ),
        );
      }
    }

    // ================================
    // 💰 4. فرص توفير من Sub
    // ================================
    for (final entry in sortedSubCategories.take(3)) {
      final save = entry.value * 0.15;

      if (save > 30) {
        insights.add(
          _InsightRow(
            icon: Icons.lightbulb,
            color: AppColors.successColor,
            title: 'فرصة توفير مباشرة',
            text:
                'تقليل (${entry.key.name}) بنسبة بسيطة يوفر لك (${save.truncate()} ج).',
          ),
        );
      }
    }

    // ================================
    // 🧠 5. ربط Main بـ Sub
    // ================================
    final mainCategories = allCategories
        .where((c) => c.parentId == null)
        .toList();

    for (final main in mainCategories) {
      final subs = sortedSubCategories
          .where((e) => e.key.parentId == main.id)
          .toList();

      if (subs.isNotEmpty) {
        final biggestSub = subs.first;

        final totalMain = subs.fold(0.0, (sum, e) => sum + e.value);

        final percent = (biggestSub.value / totalMain) * 100;

        if (percent > 50) {
          insights.add(
            _InsightRow(
              icon: Icons.account_tree,
              color: AppColors.primaryColor,
              title: 'سبب رئيسي داخل (${main.name})',
              text:
                  '(${biggestSub.key.name}) تمثل ${percent.toStringAsFixed(1)}% من هذه الفئة.',
            ),
          );
        }
      }
    }

    // ================================
    // 💧 6. Budget مقارنة Sub
    // ================================
    for (final entry in sortedSubCategories) {
      final budgeted =
          plan.getExpenseForCategory(entry.key.id)?.budgetedAmount ?? 0.0;

      if (budgeted > 0 && entry.value > budgeted) {
        final diff = entry.value - budgeted;

        insights.add(
          _InsightRow(
            icon: Icons.warning,
            color: AppColors.errorColor,
            title: 'تجاوز في (${entry.key.name})',
            text: 'تجاوزت الميزانية بـ (${diff.truncate()} ج).',
          ),
        );
      }
    }

    // ================================
    // ⚖️ 7. عدم توازن
    // ================================
    if (sortedSubCategories.length >= 2) {
      final first = sortedSubCategories[0];
      final second = sortedSubCategories[1];

      if (first.value > second.value * 2) {
        insights.add(
          _InsightRow(
            icon: Icons.balance,
            color: AppColors.orangeColor,
            title: 'عدم توازن واضح',
            text: '(${first.key.name}) أعلى بكثير من (${second.key.name}).',
          ),
        );
      }
    }

    // ================================
    // Empty
    // ================================
    if (insights.isEmpty) {
      insights.add(
        const Text('لا توجد بيانات كافية للتحليل.'),
      );
    }

    // ================================
    // ✨ UI + Animation
    // ================================
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackgroundLightColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.orangeColor),
              8.horizontalSpace,
              Text(
                'تحليل للمصاريف',
                style: AppTextStyle.style16W600.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          16.verticalSpace,

          ...List.generate(insights.length, (index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + (index * 120)),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: insights[index],
            );
          }),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.style14Bold.copyWith(color: color),
                ),
                4.verticalSpace,
                Text(
                  text,
                  style: AppTextStyle.style12W500.copyWith(
                    height: 1.5,
                    color: AppColors.primaryTextColor.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCircularProgress extends StatefulWidget {
  const AnimatedCircularProgress({required this.spendingPercentage, super.key});
  final double spendingPercentage;

  @override
  State<AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0, end: widget.spendingPercentage / 100)
        .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CircularProgressIndicator(
          value: _animation.value,
          strokeWidth: 20.r,
          backgroundColor: Colors.white24,
          color: widget.spendingPercentage > 90
              ? AppColors.errorColor
              : AppColors.successColor,
        );
      },
    );
  }
}
