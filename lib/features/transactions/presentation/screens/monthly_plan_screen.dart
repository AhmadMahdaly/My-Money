// ignore_for_file: prefer_int_literals

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/monthly_plan.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_dialog.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/calculator_dialog.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/welcome_user_widget.dart';
import 'package:uuid/uuid.dart';

class MonthlyPlanScreen extends StatelessWidget {
  const MonthlyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MonthlyPlanView();
  }
}

class _MonthlyPlanView extends StatelessWidget {
  const _MonthlyPlanView();

  @override
  Widget build(BuildContext context) {
    final transactionCubit = context.watch<TransactionCubit>();
    if (transactionCubit.state.allCategories.isEmpty &&
        !transactionCubit.state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<TransactionCubit>().loadInitialData();
        }
      });
    }
    return Scaffold(
      appBar: const _PageHeader(),
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

              return Column(
                children: [
                  _MonthSelector(),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(8.r),
                      children: [
                        _PlannedSummarySection(plan: planState.plan!),

                        16.verticalSpace,
                        _SummarySection(plan: planState.plan!),
                        16.verticalSpace,
                        _PlannedIncomeSection(plan: planState.plan!),
                        16.verticalSpace,
                        _PlannedExpensesSection(plan: planState.plan!),
                        // 20.verticalSpace,
                        // CustomPrimaryButton(
                        //   width: double.infinity,
                        //   text: 'احفظ حسبة الشهر',
                        //   onPressed: () => context
                        //       .read<MonthlyPlanCubit>()
                        //       .saveCurrentPlan(),
                        // ),
                        16.verticalSpace,
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
}

class _PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const _PageHeader();

  @override
  Size get preferredSize => Size.fromHeight(120.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        right: 16.w,
        left: 16.w,
        bottom: 10.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, -0),
          end: Alignment(0.50, 1),
          colors: [AppColors.primaryColor, AppColors.secondaryTextColor],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const WelcomeUserWidget(isLeading: true, title: 'الخطة الشهرية'),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgImage(
                    imagePath: 'assets/image/svg/quote-1.svg',
                    height: 14.h,
                  ),
                  4.horizontalSpace,
                  Text(
                    kAppQuote,
                    style: AppTextStyles.style14W400.copyWith(
                      color: AppColors.scaffoldBackgroundLightColor,
                    ),
                  ),
                  4.horizontalSpace,
                  SvgImage(
                    imagePath: 'assets/image/svg/quote-1.svg',
                    height: 14.h,
                  ),
                ],
              ),
              8.verticalSpace,
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'احسب هنا بادجت الشهر بعد أي إلتزامات ثابتة',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style14Bold.copyWith(
                    color: AppColors.scaffoldBackgroundLightColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MonthlyPlanCubit>();
    final currentMonth = cubit.state.currentMonth;

    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              final prevMonth = DateTime(
                currentMonth.year,
                currentMonth.month - 1,
              );
              cubit.loadPlanForMonth(prevMonth);
            },
          ),
          Text(
            DateFormat.yMMMM('ar').format(currentMonth),
            style: AppTextStyles.style16W400.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              final nextMonth = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
              );
              cubit.loadPlanForMonth(nextMonth);
            },
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.plan});
  final MonthlyPlan plan;

  @override
  Widget build(BuildContext context) {
    final transactionState = context.watch<TransactionCubit>().state;
    final planState = context.watch<MonthlyPlanCubit>().state;

    final currentMonth = planState.currentMonth;
    final year = currentMonth.year;
    final month = currentMonth.month;

    final actualTotalIncome = transactionState.allTransactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.date.year == year &&
              t.date.month == month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final actualTotalExpense = transactionState.allTransactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.year == year &&
              t.date.month == month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final actualSavings = actualTotalIncome - actualTotalExpense;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ملخصك الفعلي',
            style: AppTextStyles.style14W400.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          16.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(
                title: 'الدخل',
                amount: actualTotalIncome,
                color: AppColors.successColor.withAlpha(200),
              ),
              _SummaryItem(
                title: 'المصروف',
                amount: actualTotalExpense,
                color: AppColors.errorColor.withAlpha(200),
              ),
              _SummaryItem(
                title: 'الباقي',
                amount: actualSavings,
                color: actualSavings >= 0
                    ? AppColors.primaryColor.withAlpha(200)
                    : AppColors.orangeColor.withAlpha(200),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlannedSummarySection extends StatelessWidget {
  const _PlannedSummarySection({required this.plan});
  final MonthlyPlan plan;

  @override
  Widget build(BuildContext context) {
    final plannedIncome = plan.totalPlannedIncome;
    final plannedExpense = plan.totalBudgetedExpense;
    final expectedSavings = plan.projectedSavings;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ملخص خطتك (المتوقع)',
            style: AppTextStyles.style14W400.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          16.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(
                title: 'دخل متوقع',
                amount: plannedIncome,
                color: AppColors.successColor.withAlpha(200),
              ),
              _SummaryItem(
                title: 'الميزانية',
                amount: plannedExpense,
                color: AppColors.errorColor.withAlpha(200),
              ),
              _SummaryItem(
                title: 'توفير متوقع',
                amount: expectedSavings,
                color: expectedSavings >= 0
                    ? AppColors.primaryColor.withAlpha(200)
                    : AppColors.orangeColor.withAlpha(200),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.amount,
    required this.color,
  });
  final String title;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 100.h,
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: AppTextStyles.style16W300.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                4.verticalSpace,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${amount.truncate()}',
                    style: AppTextStyles.style20Bold.copyWith(
                      color: color,
                    ),
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

class _PlannedIncomeSection extends StatelessWidget {
  const _PlannedIncomeSection({required this.plan});
  final MonthlyPlan plan;

  @override
  Widget build(BuildContext context) {
    final incomeCategories = context
        .watch<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.income)
        .toList();

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'الدخل المتوقع (المخطط له)',
            style: AppTextStyles.style14W400.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          initiallyExpanded: false,
          children: [
            if (incomeCategories.isEmpty)
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
              ...incomeCategories.map((category) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: _IncomeBudgetTile(category: category, plan: plan),
                );
              }),
            ListTile(
              title: const Text('ضيف فئة جديدة لدخلك...'),
              leading: Icon(Icons.add, color: AppColors.successColor),
              onTap: () => _showAddIncomeCategoryDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeBudgetTile extends StatefulWidget {
  const _IncomeBudgetTile({required this.category, required this.plan});
  final TransactionCategory category;
  final MonthlyPlan plan;

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
    final planState = context.watch<MonthlyPlanCubit>().state;

    final currentMonth = planState.currentMonth;
    final year = currentMonth.year;
    final month = currentMonth.month;

    final budgetedAmount = widget.plan.incomes
        .where((i) => i.name == widget.category.name)
        .fold(0.0, (sum, item) => sum + item.amount);

    final actualReceivedAmount = transactionState.allTransactions
        .where(
          (t) =>
              t.categoryId == widget.category.id &&
              t.type == TransactionType.income &&
              t.date.year == year &&
              t.date.month == month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final progressValue = (budgetedAmount > 0)
        ? (actualReceivedAmount / budgetedAmount).clamp(0.0, 1.0)
        : 0.0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: widget.category.color,
        radius: 15.r,
      ),

      title: Text(widget.category.name),

      // العنوان الفرعي: شريط التقدم + المبلغ المخطط له
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.verticalSpace,
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: AppColors.secondaryColor,
            color: widget.category.color,
            minHeight: 6.h,
          ),
          4.verticalSpace,
          Text(
            'المخطط له: ${budgetedAmount.truncate()} ج.م',
            style: AppTextStyles.style12W400.copyWith(
              color: AppColors.secondaryTextColor,
            ),
          ),
          Text(
            'الفعلي: ${actualReceivedAmount.truncate()} ج.م',
            style: AppTextStyles.style12W400.copyWith(
              color: AppColors.secondaryTextColor,
            ),
          ),
        ],
      ),

      // الحقل الجانبي: لتحديد الدخل "المخطط له"
      trailing: SizedBox(
        // <-- الحقل يجب أن يكون هنا
        width: 120.w, // يمكنك تعديل العرض حسب رغبتك
        child: CustomPrimaryTextfield(
          controller: _controller,
          text: 'المخطط',
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          suffix: IconButton(
            // <-- إضافة أيقونة الآلة الحاسبة مجدداً
            icon: Icon(
              Icons.calculate_outlined,
              size: 24.r,
              color: AppColors.primaryColor,
            ),
            onPressed: () async {
              final result = await showDialog<double>(
                context: context,
                builder: (_) => CalculatorDialog(
                  initialValue: double.tryParse(_controller.text) ?? 0,
                ),
              );
              if (result != null && mounted) {
                _controller.text = result.truncate().toString();
                _updateIncomeInCubit(result);
              }
            },
          ),
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0.0;
            _updateIncomeInCubit(amount);
          },
        ),
      ),
    );
  }
}

void _showAddIncomeCategoryDialog(BuildContext context) {
  final transactionCubit = context.read<TransactionCubit>();

  showDialog<TransactionCategory>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: transactionCubit,
      child: const AddCategoryDialog(type: TransactionType.income),
    ),
  ).then((newCategory) {
    if (newCategory != null) {
      transactionCubit.addCategory(newCategory);
    }
  });
}

void _showAddExpenseCategoryDialog(BuildContext context) {
  final transactionCubit = context.read<TransactionCubit>();

  showDialog<TransactionCategory>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: transactionCubit,

      child: const AddCategoryDialog(type: TransactionType.expense),
    ),
  ).then((newCategory) {
    if (newCategory != null) {
      transactionCubit.addCategory(newCategory);
    }
  });
}

class _PlannedExpensesSection extends StatelessWidget {
  const _PlannedExpensesSection({required this.plan});
  final MonthlyPlan plan;

  @override
  Widget build(BuildContext context) {
    final expenseCategories = context
        .watch<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.expense)
        .toList();

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            'الإلتزامات الثابتة (مصاريفك المتوقعة)',
            style: AppTextStyles.style14W400.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          children: [
            if (expenseCategories.isEmpty)
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
                      child: const Text('ضيف فئة جديدة'),
                    ),
                  ],
                ),
              )
            else
              ...expenseCategories.map((category) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: _ExpenseBudgetTile(category: category, plan: plan),
                );
              }),
            ListTile(
              title: const Text('ضيف فئة جديدة لمصاريفك...'),
              leading: const Icon(Icons.add, color: Colors.red),
              onTap: () => _showAddExpenseCategoryDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseBudgetTile extends StatefulWidget {
  const _ExpenseBudgetTile({required this.category, required this.plan});
  final TransactionCategory category;
  final MonthlyPlan plan;

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
    // نتحقق من الخطة أو الفئة لضمان تحديث النص في الحقل
    if (widget.plan != oldWidget.plan ||
        widget.category.id != oldWidget.category.id) {
      _updateControllerText();
    }
  }

  // هذه الدالة مسؤولة فقط عن تحديث "حقل إدخال الميزانية"
  void _updateControllerText() {
    final existingExpense = widget.plan.getExpenseForCategory(
      widget.category.id,
    );
    final amount = existingExpense?.budgetedAmount ?? 0.0;

    final textValue = (amount == amount.truncate())
        ? amount.truncate().toString()
        : amount.toString();

    // نتأكد أن النص مختلف قبل التحديث لتجنب مشاكل مع المؤشر
    if (_controller.text != textValue) {
      _controller.text = textValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // هذه الدالة تحدث "الميزانية" نفسها عند التغيير في الحقل
  void _updateExpenseInCubit(double amount) {
    final newExpense = PlannedExpense(
      categoryId: widget.category.id,
      budgetedAmount: amount,
    );
    final otherExpenses = widget.plan.expenses
        .where((e) => e.categoryId != widget.category.id)
        .toList();

    // نضيف المصروف الجديد فقط إذا كانت قيمته أكبر من صفر
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
    // --- الجزء الجديد: حساب المصروفات الفعلية ---

    // 1. قراءة الـ state من الكيوبت الخاصة بالمعاملات والخطة
    final transactionState = context.watch<TransactionCubit>().state;
    final planState = context.watch<MonthlyPlanCubit>().state;

    final currentMonth = planState.currentMonth;
    final year = currentMonth.year;
    final month = currentMonth.month;
    final existingExpense = widget.plan.getExpenseForCategory(
      widget.category.id,
    );
    final budgetedAmount = existingExpense?.budgetedAmount ?? 0.0;
    final actualSpentAmount = transactionState.allTransactions
        .where(
          (t) =>
              t.categoryId == widget.category.id &&
              t.type == TransactionType.expense &&
              t.date.year == year &&
              t.date.month == month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final remainingAmount = budgetedAmount - actualSpentAmount;

    final progressValue = (budgetedAmount > 0)
        ? (actualSpentAmount / budgetedAmount).clamp(0.0, 1.0)
        : 0.0;

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: widget.category.color,
            radius: 10.r,
          ),
          SizedBox(
            width: SizeConfig.screenWidth / 3 - 10.w,
            child: Text(
              widget.category.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: widget.category.color),
            ),
          ),
          SizedBox(
            width: SizeConfig.screenWidth / 2 - 40.w,
            child: CustomPrimaryTextfield(
              controller: _controller,
              text: 'الميزانية',
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,

              suffix: InkWell(
                child: Icon(
                  Icons.calculate_outlined,
                  size: 24.r,
                  color: AppColors.primaryColor,
                ),
                onTap: () async {
                  final result = await showDialog<double>(
                    context: context,
                    builder: (_) => CalculatorDialog(
                      initialValue: double.tryParse(_controller.text) ?? 0,
                    ),
                  );
                  if (result != null && mounted) {
                    _controller.text = result.truncate().toString();
                    _updateExpenseInCubit(result);
                  }
                },
              ),
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                _updateExpenseInCubit(amount);
              },
            ),
          ),
        ],
      ),
      // العنوان الفرعي سيعرض شريط التقدم والتفاصيل
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.verticalSpace,
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: AppColors.secondaryColor,
            color: widget.category.color,
            minHeight: 6.h,
          ),
          4.verticalSpace,

          Text(
            'الميزانية المتوقعة: ${budgetedAmount.truncate()} ج.م\nالمصروف فعلياً: ${actualSpentAmount.truncate()} ج.م\nالباقي الفعلي: ${remainingAmount.truncate()} ج.م',
            style: AppTextStyles.style12W400.copyWith(
              color: widget.category.color,
            ),
          ),
        ],
      ),
    );
  }
}
