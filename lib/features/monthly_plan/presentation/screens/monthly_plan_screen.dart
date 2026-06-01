import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/monthly_plan/domain/entities/monthly_plan.dart';
import 'package:opration/features/monthly_plan/presentation/controllers/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/monthly_plan/presentation/screens/widgets/analytics/monthly_analytics_data.dart';
import 'package:opration/features/monthly_plan/presentation/screens/widgets/analytics/overview_analytics_card.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_widget.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/calculator_dialog.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class MonthlyPlanScreen extends StatelessWidget {
  const MonthlyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MonthlyPlanView();
  }
}

class _MonthlyPlanView extends StatefulWidget {
  const _MonthlyPlanView();

  @override
  State<_MonthlyPlanView> createState() => _MonthlyPlanViewState();
}

class _MonthlyPlanViewState extends State<_MonthlyPlanView> {
  String? selectedWalletId;
  DateTime? _cycleStart;
  DateTime? _cycleEnd;

  @override
  void initState() {
    super.initState();
    final startStr = CacheHelper.getData('budget_cycle_start') as String?;
    final endStr = CacheHelper.getData('budget_cycle_end') as String?;
    if (startStr != null && endStr != null) {
      _cycleStart = DateTime.parse(startStr);
      _cycleEnd = DateTime.parse(endStr);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final activeStart = _cycleStart ?? DateTime.now();
        final activeEnd = _cycleEnd ?? DateTime.now();
        final dominantMonth = _getDominantMonth(activeStart, activeEnd);

        context.read<MonthlyPlanCubit>().loadPlanForMonth(dominantMonth);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionCubit = context.watch<TransactionCubit>();
    final walletState = context.watch<WalletCubit>().state;

    if (transactionCubit.state.allCategories.isEmpty &&
        !transactionCubit.state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<TransactionCubit>().loadInitialData();
        }
      });
    }

    return Scaffold(
      appBar: PageHeader(
        leading: InkWell(
          onTap: () {
            _showResetDialog(context);
          },
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
        isLeading: false,
        height: 16.h,
        title: 'الخطة الشهرية',
        actions: [
          InkWell(
            onTap: () {
              context.push(AppRoutes.monthlyAnalyticsScreen);
            },
            child: const Icon(Icons.analytics_outlined, color: Colors.white),
          ),
          16.horizontalSpace,
          InkWell(
            onTap: () {
              if (walletState is WalletLoaded &&
                  walletState.wallets.isNotEmpty) {
                _showWalletFilterSheet(context, walletState);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا توجد محافظ لعرضها')),
                );
              }
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(Icons.filter_alt_outlined, color: Colors.white),
                if (selectedWalletId != null)
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, transactionState) {
          if (transactionState.isLoading &&
              transactionState.allCategories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return BlocBuilder<MonthlyPlanCubit, MonthlyPlanState>(
            builder: (context, planState) {
              if (planState.status == MonthlyPlanStatus.loading &&
                  planState.plan == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (planState.status == MonthlyPlanStatus.saving) {
                return Padding(
                  padding: EdgeInsets.all(16.r),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }
              if (planState.status == MonthlyPlanStatus.error) {
                return Center(child: Text('فيه غلطة: ${planState.error}'));
              }
              if (planState.plan == null) {
                return const Center(child: Text('مفيش أي خطط متسجلة.'));
              }

              final month = planState.currentMonth;

              final activeStart =
                  _cycleStart ?? DateTime(month.year, month.month, 1);
              final activeEnd =
                  _cycleEnd ??
                  DateTime(month.year, month.month + 1, 0, 23, 59, 59);

              final filteredTransactions = transactionState.allTransactions
                  .where((t) {
                    final matchWallet =
                        selectedWalletId == null ||
                        t.walletId == selectedWalletId;
                    final matchDate =
                        t.date.isAfter(
                          activeStart.subtract(const Duration(seconds: 1)),
                        ) &&
                        t.date.isBefore(
                          activeEnd.add(const Duration(seconds: 1)),
                        );
                    return matchWallet && matchDate;
                  })
                  .toList();

              final walletAllTransactions = selectedWalletId == null
                  ? transactionState.allTransactions
                  : transactionState.allTransactions
                        .where((t) => t.walletId == selectedWalletId)
                        .toList();

              final data = MonthlyAnalyticsData.from(
                cycleStart: activeStart,
                cycleEnd: activeEnd,
                plan: planState.plan!,
                allTransactions: walletAllTransactions,
                allCategories: transactionState.allCategories,
              );

              return Column(
                children: [
                  _CycleSelector(
                    cycleStart: activeStart,
                    cycleEnd: activeEnd,
                    onEditCycle: _pickCycleDateRange,
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      children: [
                        OverviewAnalyticsCard(data: data),
                        8.verticalSpace,
                        _PlannedIncomeSection(
                          plan: planState.plan!,
                          transactions: filteredTransactions,
                        ),
                        8.verticalSpace,
                        _PlannedExpensesSection(
                          plan: planState.plan!,
                          transactions: filteredTransactions,
                        ),
                        30.verticalSpace,
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  DateTime _getDominantMonth(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return start;
    }

    final monthCounts = <DateTime, int>{};
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      final monthKey = DateTime(current.year, current.month, 1);
      monthCounts[monthKey] = (monthCounts[monthKey] ?? 0) + 1;
      current = current.add(const Duration(days: 1));
    }

    var dominantMonth = DateTime(start.year, start.month, 1);
    var maxDays = monthCounts[dominantMonth] ?? 0;

    monthCounts.forEach((key, count) {
      if (count > maxDays) {
        maxDays = count;
        dominantMonth = key;
      } else if (count == maxDays) {
        if (key.year == start.year && key.month == start.month) {
          dominantMonth = key;
        }
      }
    });

    return dominantMonth;
  }

  Future<void> _pickCycleDateRange() async {
    final month = context.read<MonthlyPlanCubit>().state.currentMonth;
    final initialStart = _cycleStart ?? DateTime(month.year, month.month, 1);
    final initialEnd = _cycleEnd ?? DateTime(month.year, month.month + 1, 0);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      saveText: 'تأكيد',
      helpText: 'اختر فترة الميزانية (من - إلى)',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryTextColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final start = picked.start;
      final end = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
      );

      setState(() {
        _cycleStart = start;
        _cycleEnd = end;
      });

      await CacheHelper.saveData(
        key: 'budget_cycle_start',
        value: start.toIso8601String(),
      );
      await CacheHelper.saveData(
        key: 'budget_cycle_end',
        value: end.toIso8601String(),
      );

      final dominantMonth = _getDominantMonth(start, end);

      if (context.mounted) {
        await context.read<MonthlyPlanCubit>().loadPlanForMonth(dominantMonth);
      }
    }
  }

  void _showWalletFilterSheet(BuildContext context, WalletLoaded walletState) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تصفية بالمحفظة',
                style: AppTextStyle.style16W600.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              16.verticalSpace,
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(
                  'الكل',
                  style: AppTextStyle.style14W500,
                ),
                trailing: selectedWalletId == null
                    ? const Icon(Icons.check, color: AppColors.primaryColor)
                    : null,
                onTap: () {
                  setState(() => selectedWalletId = null);
                  Navigator.pop(ctx);
                },
              ),
              ...walletState.wallets.map((wallet) {
                return ListTile(
                  leading: const Icon(Icons.account_balance_wallet_rounded),
                  title: Text(
                    wallet.name,
                    style: AppTextStyle.style14W500,
                  ),
                  trailing: selectedWalletId == wallet.id
                      ? const Icon(Icons.check, color: AppColors.primaryColor)
                      : null,
                  onTap: () {
                    setState(() => selectedWalletId = wallet.id);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text('هل تريد إعادة تعيين كل الميزانية لهذا الشهر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<MonthlyPlanCubit>().resetPlan();
              Navigator.pop(context);
            },
            child: const Text('نعم، امسح'),
          ),
        ],
      ),
    );
  }
}

class _CycleSelector extends StatelessWidget {
  const _CycleSelector({
    required this.cycleStart,
    required this.cycleEnd,
    required this.onEditCycle,
  });

  final DateTime cycleStart;
  final DateTime cycleEnd;
  final VoidCallback onEditCycle;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd MMM', 'ar');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: InkWell(
        onTap: onEditCycle,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primaryColor.withAlpha(40)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primaryColor,
                size: 22.r,
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دورة الميزانية الحالية',
                      style: AppTextStyle.style9W500.copyWith(
                        color: AppColors.primaryTextColor.withAlpha(150),
                      ),
                    ),
                    4.verticalSpace,
                    Row(
                      children: [
                        Text(
                          'من ${format.format(cycleStart)}  إلى  ${format.format(cycleEnd)}',
                          style: AppTextStyle.style14W600.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        8.horizontalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '(تغطي ${DateTime(cycleEnd.year, cycleEnd.month, cycleEnd.day).difference(DateTime(cycleStart.year, cycleStart.month, cycleStart.day)).inDays + 1} يوم)',
                            style: AppTextStyle.style9W500.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit, color: AppColors.primaryColor, size: 20.r),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlannedIncomeSection extends StatelessWidget {
  const _PlannedIncomeSection({required this.plan, required this.transactions});
  final MonthlyPlan plan;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final transactionCubit = context.watch<TransactionCubit>();

    final allIncomeCategories = transactionCubit.state.allCategories
        .where(
          (c) => c.type == TransactionType.income && c.name != 'تحويل وارد',
        )
        .toList();

    final mainCategories = allIncomeCategories
        .where((c) => c.parentId == null)
        .toList();

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'الدخل المتوقع',
            style: AppTextStyle.style14W500.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          initiallyExpanded: false,
          children: [
            if (mainCategories.isEmpty)
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    const Text('لسا مضيفتش فئات للدخل'),
                    8.verticalSpace,
                    ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.manageCategoriesScreen);
                      },
                      child: const Text('ضيف فئة دخل جديدة'),
                    ),
                  ],
                ),
              )
            else
              ...mainCategories.map((mainCat) {
                final subCategories = allIncomeCategories
                    .where((c) => c.parentId == mainCat.id)
                    .toList();

                final parentBudgeted = plan.incomes
                    .where((i) => i.name == mainCat.name)
                    .fold(0.0, (sum, item) => sum + item.amount);

                final parentActual = transactions
                    .where(
                      (t) =>
                          t.categoryId == mainCat.id &&
                          t.type == TransactionType.income,
                    )
                    .fold(0.0, (sum, t) => sum + t.amount);

                final showGeneral = parentBudgeted > 0 || parentActual > 0;

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: _IncomeBudgetTile(
                        category: mainCat,
                        plan: plan,
                        transactions: transactions,
                        isSubCategory: false,
                      ),
                    ),
                    if (subCategories.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(right: 24.w),
                        child: Column(
                          children: [
                            if (showGeneral)
                              Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: _IncomeBudgetTile(
                                  category: mainCat,
                                  plan: plan,
                                  transactions: transactions,
                                  isSubCategory: true,
                                  customName: 'عام',
                                ),
                              ),
                            ...subCategories.map((subCat) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: _IncomeBudgetTile(
                                  category: subCat,
                                  plan: plan,
                                  transactions: transactions,
                                  isSubCategory: true,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                );
              }),
            ListTile(
              tileColor: AppColors.primaryColor,
              title: Text(
                'إدارة فئات الدخل...',
                style: AppTextStyle.style12Bold.copyWith(
                  color: AppColors.scaffoldBackgroundLightColor,
                ),
              ),
              leading: Icon(
                Icons.settings,
                size: 16.r,
                color: AppColors.scaffoldBackgroundLightColor,
              ),
              onTap: () => context.push(AppRoutes.manageCategoriesScreen),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeBudgetTile extends StatefulWidget {
  const _IncomeBudgetTile({
    required this.category,
    required this.plan,
    required this.transactions,
    this.isSubCategory = false,
    this.customName,
  });
  final TransactionCategory category;
  final MonthlyPlan plan;
  final List<Transaction> transactions;
  final bool isSubCategory;
  final String? customName;

  @override
  State<_IncomeBudgetTile> createState() => _IncomeBudgetTileState();
}

class _IncomeBudgetTileState extends State<_IncomeBudgetTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(covariant _IncomeBudgetTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plan != oldWidget.plan ||
        widget.category.id != oldWidget.category.id) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    final budgetedAmount = widget.plan.incomes
        .where((i) => i.name == widget.category.name)
        .fold(0.0, (sum, item) => sum + item.amount);

    final textValue = (budgetedAmount == budgetedAmount.truncate())
        ? budgetedAmount.truncate().toString()
        : budgetedAmount.toString();

    if (_controller.text != textValue) {
      _controller.text = textValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateIncomeInCubit(double amount) {
    final category = widget.category;
    final planState = context.read<MonthlyPlanCubit>().state;

    final otherIncomes = widget.plan.incomes
        .where((i) => i.name != category.name)
        .toList();

    final updatedIncomes = [...otherIncomes];

    if (amount > 0) {
      final existingIncome = widget.plan.incomes.firstWhere(
        (i) => i.name == category.name,
        orElse: () => PlannedIncome(
          id: getIt<Uuid>().v4(),
          name: '',
          amount: 0,
          date: DateTime.now(),
        ),
      );

      final newIncome = PlannedIncome(
        id: existingIncome.id,
        name: category.name,
        amount: amount,
        date: DateTime(
          planState.currentMonth.year,
          planState.currentMonth.month,
          1,
        ),
      );
      updatedIncomes.add(newIncome);
    }

    context.read<MonthlyPlanCubit>().updatePlan(
      widget.plan.copyWith(incomes: updatedIncomes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = context.watch<TransactionCubit>().state;

    final allCategories = transactionState.allCategories;
    final subCategories = widget.isSubCategory
        ? <TransactionCategory>[]
        : allCategories
              .where(
                (c) =>
                    c.parentId == widget.category.id &&
                    c.type == TransactionType.income,
              )
              .toList();

    final hasSubCategories = subCategories.isNotEmpty;
    final subCategoryIds = subCategories.map((c) => c.id).toList();
    final subCategoryNames = subCategories.map((c) => c.name).toList();

    var budgetedAmount = widget.plan.incomes
        .where((i) => i.name == widget.category.name)
        .fold(0.0, (sum, item) => sum + item.amount);

    for (final subName in subCategoryNames) {
      budgetedAmount += widget.plan.incomes
          .where((i) => i.name == subName)
          .fold(0.0, (sum, item) => sum + item.amount);
    }

    final categoryTransactions = widget.transactions
        .where(
          (t) =>
              (t.categoryId == widget.category.id ||
                  subCategoryIds.contains(t.categoryId)) &&
              t.type == TransactionType.income,
        )
        .toList();

    final actualReceivedAmount = categoryTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );

    final progressValue = (budgetedAmount > 0)
        ? (actualReceivedAmount / budgetedAmount).clamp(0.0, 1.0)
        : 0.0;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.r),
      title: Row(
        children: [
          if (widget.isSubCategory) ...[
            Icon(
              Icons.subdirectory_arrow_left,
              size: 16.r,
              color: widget.category.color.withAlpha(150),
            ),
            4.horizontalSpace,
          ],
          if (!widget.isSubCategory) ...[
            SpeedDial(
              direction: SpeedDialDirection.down,
              buttonSize: const Size(30, 30),
              backgroundColor: widget.category.color,
              iconTheme: const IconThemeData(
                color: AppColors.scaffoldBackgroundLightColor,
              ),
              icon: Icons.add,
              activeIcon: Icons.close,
              elevation: 0,
              spacing: 4.h,
              spaceBetweenChildren: 4.h,
              overlayOpacity: 0.8,
              children: [
                SpeedDialChild(
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 20.r,
                    color: widget.category.color,
                  ),
                  label: 'إضافة فئة',
                  onTap: () => _showAddSubCategoryBottomSheet(
                    context: context,
                    parentCategory: widget.category,
                  ),
                ),
                SpeedDialChild(
                  child: Icon(
                    Icons.settings,
                    size: 20.r,
                    color: AppColors.primaryColor,
                  ),
                  label: 'إدارة المخصصات',
                  onTap: () => context.push(AppRoutes.manageCategoriesScreen),
                ),
              ],
            ),
          ],
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showTransactionsSheet(
                          context,
                          categoryTransactions,
                        ),
                        child: Text(
                          widget.customName ?? widget.category.name,
                          style: AppTextStyle.style12Bold.copyWith(
                            fontSize: widget.isSubCategory ? 12.sp : 14.sp,
                            color: AppColors.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (hasSubCategories)
                      SizedBox(
                        width: 80.w,
                        child: Center(
                          child: Text(
                            '${budgetedAmount.truncate()} $appCurrencySymbol',
                            style: AppTextStyle.style14W700.copyWith(
                              color: widget.category.color,
                            ),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _showEditBudgetSheet(context, true),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(16),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withAlpha(77),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _controller.text.isEmpty
                                    ? '0'
                                    : '${_controller.text}  $appCurrencySymbol',
                                style: AppTextStyle.style14W500.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              8.horizontalSpace,
                              Icon(
                                Icons.edit_note,
                                size: 18.r,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                8.verticalSpace,
                LinearProgressIndicator(
                  value: budgetedAmount > 0 ? progressValue : 0.0,
                  backgroundColor: AppColors.secondaryColor.withAlpha(50),
                  color: budgetedAmount > 0
                      ? widget.category.color
                      : AppColors.secondaryColor.withAlpha(100),
                  minHeight: 8.h,
                ),
                4.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الإفتراضي: ${budgetedAmount.truncate()} $appCurrencySymbol',
                      style: AppTextStyle.style9W400.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      'الفعلي: ${actualReceivedAmount.truncate()} $appCurrencySymbol',
                      style: AppTextStyle.style9W400.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetSheet(BuildContext context, bool isIn) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom,
            left: 20.w,
            right: 20.w,
            top: 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تعديل ميزانية ${widget.category.name}',
                style: AppTextStyle.style16W600,
              ),
              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: CustomPrimaryTextfield(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      text: 'المبلغ',
                    ),
                  ),
                  10.horizontalSpace,
                  IconButton(
                    onPressed: () async {
                      final result = await showDialog<double>(
                        context: context,
                        builder: (_) => CalculatorDialog(
                          initialValue: double.tryParse(_controller.text) ?? 0,
                        ),
                      );
                      if (result != null) {
                        _controller.text = result.truncate().toString();
                      }
                    },
                    icon: Icon(
                      Icons.calculate_outlined,
                      size: 35.r,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(_controller.text) ?? 0.0;
                    if (isIn) {
                      _updateIncomeInCubit(amount);
                    }

                    Navigator.pop(context);
                    setState(
                      () {},
                    );
                  },
                  child: const Text(
                    'حفظ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              20.verticalSpace,
            ],
          ),
        );
      },
    );
  }

  void _showTransactionsSheet(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Column(
              children: [
                Text(
                  'معاملات ${widget.customName ?? widget.category.name}',
                  style: AppTextStyle.style16W600.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                10.verticalSpace,
                const Divider(height: 1),
                Expanded(
                  child: transactions.isEmpty
                      ? Center(
                          child: Text(
                            'مفيش عمليات مسجلة هنا',
                            style: AppTextStyle.style14W500.copyWith(
                              color: AppColors.primaryTextColor.withAlpha(150),
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: EdgeInsets.all(16.r),
                          itemCount: transactions.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final t = transactions[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${t.amount.truncate()} $appCurrencySymbol',
                                style: AppTextStyle.style14Bold.copyWith(
                                  color: t.type == TransactionType.income
                                      ? AppColors.successColor
                                      : AppColors.errorColor,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'd MMM yyyy - hh:mm a',
                                  'ar',
                                ).format(t.date),
                                style: AppTextStyle.style9W500.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: t.note != null && t.note!.isNotEmpty
                                  ? SizedBox(
                                      width: 120.w,
                                      child: Text(
                                        t.note!,
                                        style: AppTextStyle.style9W500.copyWith(
                                          color: AppColors.primaryTextColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _PlannedExpensesSection extends StatelessWidget {
  const _PlannedExpensesSection({
    required this.plan,
    required this.transactions,
  });
  final MonthlyPlan plan;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final allExpenseCategories = context
        .watch<TransactionCubit>()
        .state
        .allCategories
        .where(
          (c) => c.type == TransactionType.expense && c.name != 'تحويل صادر',
        )
        .toList();

    final mainCategories = allExpenseCategories
        .where((c) => c.parentId == null)
        .toList();

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Text(
              'مصاريفك المتوقعة (الإلتزامات الثابتة)',
              style: AppTextStyle.style14W500.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
          if (mainCategories.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  const Text('لسا مضيفتش فئات'),
                  8.verticalSpace,
                  ElevatedButton(
                    onPressed: () {
                      context.push(AppRoutes.manageCategoriesScreen);
                    },
                    child: const Text('إدارة الفئات'),
                  ),
                ],
              ),
            )
          else
            ...mainCategories.map((mainCat) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: _ExpenseBudgetTile(
                  category: mainCat,
                  plan: plan,
                  transactions: transactions,
                  isSubCategory: false,
                ),
              );
            }),
          ListTile(
            tileColor: AppColors.primaryColor,
            title: Text(
              'إدارة فئات المصاريف...',
              style: AppTextStyle.style12Bold.copyWith(
                color: AppColors.scaffoldBackgroundLightColor,
              ),
            ),
            leading: Icon(
              Icons.settings,
              size: 18.r,
              color: AppColors.scaffoldBackgroundLightColor,
            ),
            onTap: () => context.push(AppRoutes.manageCategoriesScreen),
          ),
        ],
      ),
    );
  }
}

class _ExpenseBudgetTile extends StatefulWidget {
  const _ExpenseBudgetTile({
    required this.isSubCategory,
    required this.category,
    required this.plan,
    required this.transactions,
    this.customName,
  });
  final TransactionCategory category;
  final MonthlyPlan plan;
  final List<Transaction> transactions;
  final bool isSubCategory;
  final String? customName;

  @override
  State<_ExpenseBudgetTile> createState() => _ExpenseBudgetTileState();
}

class _ExpenseBudgetTileState extends State<_ExpenseBudgetTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(covariant _ExpenseBudgetTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plan != oldWidget.plan ||
        widget.category.id != oldWidget.category.id) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    final existingExpense = widget.plan.getExpenseForCategory(
      widget.category.id,
    );
    final amount = existingExpense?.budgetedAmount ?? 0.0;

    final textValue = (amount == amount.truncate())
        ? amount.truncate().toString()
        : amount.toString();

    if (_controller.text != textValue ||
        (textValue == '0' && _controller.text.isEmpty)) {
      _controller.text = textValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateExpenseInCubit(double amount) {
    final newExpense = PlannedExpense(
      categoryId: widget.category.id,
      budgetedAmount: amount,
    );
    final otherExpenses = widget.plan.expenses
        .where((e) => e.categoryId != widget.category.id)
        .toList();

    final updatedExpenses = [...otherExpenses];
    if (amount > 0) {
      updatedExpenses.add(newExpense);
    }

    context.read<MonthlyPlanCubit>().updatePlan(
      widget.plan.copyWith(expenses: updatedExpenses),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = context.watch<TransactionCubit>().state;

    final allCategories = transactionState.allCategories;
    final subCategories = widget.isSubCategory
        ? <TransactionCategory>[]
        : allCategories
              .where(
                (c) =>
                    c.parentId == widget.category.id &&
                    c.type == TransactionType.expense,
              )
              .toList();
    final hasSubCategories = subCategories.isNotEmpty;
    final subCategoryIds = subCategories.map((c) => c.id).toList();

    var budgetedAmount =
        widget.plan.getExpenseForCategory(widget.category.id)?.budgetedAmount ??
        0.0;
    for (final subId in subCategoryIds) {
      budgetedAmount +=
          widget.plan.getExpenseForCategory(subId)?.budgetedAmount ?? 0.0;
    }

    final categoryTransactions = widget.transactions
        .where(
          (t) =>
              (t.categoryId == widget.category.id ||
                  subCategoryIds.contains(t.categoryId)) &&
              t.type == TransactionType.expense,
        )
        .toList();

    final actualSpentAmount = categoryTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );

    final remainingAmount = budgetedAmount - actualSpentAmount;

    final progressValue = (budgetedAmount > 0)
        ? (actualSpentAmount / budgetedAmount).clamp(0.0, 1.0)
        : 0.0;

    final parentOnlySpentAmount = widget.transactions
        .where(
          (t) =>
              t.categoryId == widget.category.id &&
              t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
    final parentOnlyBudgeted =
        widget.plan.getExpenseForCategory(widget.category.id)?.budgetedAmount ??
        0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withAlpha(100),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.category.color.withAlpha(30),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            if (hasSubCategories) {
              final showGeneral =
                  parentOnlyBudgeted > 0 || parentOnlySpentAmount > 0;
              _showSubCategoriesSheet(context, subCategories, showGeneral);
            } else {
              _showEditBudgetSheet(context);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.isSubCategory) ...[
                      Icon(
                        Icons.subdirectory_arrow_left,
                        size: 16.r,
                        color: AppColors.primaryColor.withAlpha(150),
                      ),
                      4.horizontalSpace,
                    ],
                    if (!widget.isSubCategory) ...[
                      SpeedDial(
                        direction: SpeedDialDirection.down,
                        buttonSize: const Size(30, 30),
                        backgroundColor: widget.category.color,
                        iconTheme: const IconThemeData(
                          color: AppColors.scaffoldBackgroundLightColor,
                        ),
                        icon: Icons.add,
                        activeIcon: Icons.close,
                        elevation: 0,
                        spacing: 4.h,
                        spaceBetweenChildren: 4.h,
                        overlayOpacity: 0.8,
                        children: [
                          SpeedDialChild(
                            child: Icon(
                              Icons.add_circle_outline,
                              size: 20.r,
                              color: widget.category.color,
                            ),
                            label: 'إضافة فئة',
                            onTap: () => _showAddSubCategoryBottomSheet(
                              context: context,
                              parentCategory: widget.category,
                            ),
                          ),
                          SpeedDialChild(
                            child: Icon(
                              Icons.settings,
                              size: 20.r,
                              color: AppColors.primaryColor,
                            ),
                            label: 'إدارة المخصصات',
                            onTap: () =>
                                context.push(AppRoutes.manageCategoriesScreen),
                          ),
                        ],
                      ),
                    ],
                    8.horizontalSpace,
                    Expanded(
                      child: InkWell(
                        onTap: () => _showTransactionsSheet(
                          context,
                          categoryTransactions,
                        ),
                        child: Text(
                          widget.customName ?? widget.category.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.style14Bold.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    if (hasSubCategories && !widget.isSubCategory)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.forthColor.withAlpha(16),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.forthColor.withAlpha(77),
                          ),
                        ),
                        child: Text(
                          '${budgetedAmount.truncate()} $appCurrencySymbol',
                          style: AppTextStyle.style12W500.copyWith(
                            color: AppColors.forthColor.withAlpha(200),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _showEditBudgetSheet(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(16),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withAlpha(77),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _controller.text.isEmpty
                                    ? '0'
                                    : '${_controller.text} $appCurrencySymbol',
                                style: AppTextStyle.style12W500.copyWith(
                                  color: AppColors.primaryTextColor,
                                ),
                              ),
                              4.horizontalSpace,
                              Icon(
                                Icons.edit_note,
                                size: 18.r,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                10.verticalSpace,
                LinearProgressIndicator(
                  value: budgetedAmount > 0
                      ? (1.0 - progressValue).clamp(0.0, 1.0)
                      : 0.0,
                  backgroundColor: AppColors.secondaryColor.withAlpha(50),
                  color: budgetedAmount > 0
                      ? widget.category.color
                      : AppColors.secondaryColor.withAlpha(100),
                  minHeight: 8.h,
                ),
                8.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'صرفت: ${actualSpentAmount.truncate()} $appCurrencySymbol',
                        style: AppTextStyle.style9W400.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        textAlign: TextAlign.end,
                        'باقي: ${remainingAmount.truncate()} $appCurrencySymbol',
                        style: AppTextStyle.style9W400.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasSubCategories && !widget.isSubCategory) ...[
                  8.verticalSpace,
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: [
                      if (parentOnlyBudgeted > 0 || parentOnlySpentAmount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: widget.category.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: widget.category.color.withAlpha(80),
                            ),
                          ),
                          child: Text(
                            'عام',
                            style: AppTextStyle.style9W400.copyWith(
                              color: widget.category.color.withAlpha(200),
                            ),
                          ),
                        ),
                      ...subCategories.map((sub) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: sub.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: sub.color.withAlpha(80),
                            ),
                          ),
                          child: Text(
                            sub.name,
                            style: AppTextStyle.style9W400.copyWith(
                              color: sub.color.withAlpha(200),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSubCategoriesSheet(
    BuildContext context,
    List<TransactionCategory> subCategories,
    bool showGeneral,
  ) {
    showModalBottomSheet<TransactionCategory>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (_, controller) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الفئات الفرعية لـ ${widget.category.name}',
                        style: AppTextStyle.style16W600,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.secondaryColor),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    itemCount: subCategories.length + (showGeneral ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (showGeneral && index == 0) {
                        return _ExpenseBudgetTile(
                          category: widget.category,
                          plan: widget.plan,
                          transactions: widget.transactions,
                          isSubCategory: true,
                          customName: 'عام',
                        );
                      }

                      final actualIndex = showGeneral ? index - 1 : index;

                      return _ExpenseBudgetTile(
                        category: subCategories[actualIndex],
                        plan: widget.plan,
                        transactions: widget.transactions,
                        isSubCategory: true,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBudgetSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20.w,
            right: 20.w,
            top: 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تعديل ميزانية ${widget.category.name}',
                style: AppTextStyle.style16W600,
              ),
              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: CustomPrimaryTextfield(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      text: 'المبلغ',
                    ),
                  ),
                  10.horizontalSpace,
                  IconButton(
                    onPressed: () async {
                      final result = await showDialog<double>(
                        context: context,
                        builder: (_) => CalculatorDialog(
                          initialValue: double.tryParse(_controller.text) ?? 0,
                        ),
                      );
                      if (result != null) {
                        _controller.text = result.truncate().toString();
                      }
                    },
                    icon: Icon(
                      Icons.calculate_outlined,
                      size: 35.r,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(_controller.text) ?? 0.0;
                    _updateExpenseInCubit(amount);
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text(
                    'حفظ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              20.verticalSpace,
            ],
          ),
        );
      },
    );
  }

  void _showTransactionsSheet(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Column(
              children: [
                Text(
                  'معاملات ${widget.customName ?? widget.category.name}',
                  style: AppTextStyle.style16W600.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                10.verticalSpace,
                const Divider(height: 1),
                Expanded(
                  child: transactions.isEmpty
                      ? Center(
                          child: Text(
                            'مفيش عمليات مسجلة هنا',
                            style: AppTextStyle.style14W500.copyWith(
                              color: AppColors.primaryTextColor.withAlpha(150),
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: EdgeInsets.all(16.r),
                          itemCount: transactions.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final t = transactions[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${t.amount.truncate()} $appCurrencySymbol',
                                style: AppTextStyle.style14Bold.copyWith(
                                  color: t.type == TransactionType.income
                                      ? AppColors.successColor
                                      : AppColors.errorColor,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'd MMM yyyy - hh:mm a',
                                  'ar',
                                ).format(t.date),
                                style: AppTextStyle.style9W500.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: t.note != null && t.note!.isNotEmpty
                                  ? SizedBox(
                                      width: 120.w,
                                      child: Text(
                                        t.note!,
                                        style: AppTextStyle.style9W500.copyWith(
                                          color: AppColors.primaryTextColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void _showAddSubCategoryBottomSheet({
  required BuildContext context,
  required TransactionCategory parentCategory,
}) {
  final dummy = TransactionCategory(
    id: '',
    name: '',
    colorValue: parentCategory.colorValue,
    type: parentCategory.type,
    parentId: parentCategory.id,
  );

  showModalBottomSheet<TransactionCategory>(
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    context: context,
    builder: (_) => AddCategoryWidget(
      type: parentCategory.type,
      categoryToEdit: dummy,
    ),
  ).then((result) {
    if (result != null) {
      final newSub = result.copyWith(id: getIt<Uuid>().v4());
      context.read<TransactionCubit>().addCategory(newSub);
    }
  });
}
