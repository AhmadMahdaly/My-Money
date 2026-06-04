import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_floating_action_buttom.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/goals/domain/entities/financial_goal.dart';
import 'package:opration/features/goals/domain/entities/saving_entry.dart';
import 'package:opration/features/goals/presentation/controllers/financial_goal_cubit/financial_goal_cubit.dart';
import 'package:uuid/uuid.dart';

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(
        isLeading: true,
        title: 'مدخراتك وأهدافك',
        bottom: Container(
          height: 50.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.scaffoldBackgroundLightColor,
              width: 0.5.w,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorPadding: EdgeInsets.all(3.r),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.scaffoldBackgroundLightColor,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.scaffoldBackgroundLightColor,
            labelStyle: AppTextStyle.style14W600,
            unselectedLabelStyle: AppTextStyle.style14W600,
            tabs: const [
              Tab(text: 'الأهداف المالية'),
              Tab(text: 'المدخرات'),
            ],
          ),
        ),
        heightBar: 130.h,
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GoalsListView(),
          _SavingsListView(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          final isSavingsTab = _tabController.index == 1;
          return CustomFloatingActionButton(
            onPressed: () {
              if (isSavingsTab) {
                _showAddEditSavingDialog(context);
              } else {
                _showAddEditGoalDialog(context);
              }
            },
            tooltip: isSavingsTab ? 'إضافة مدخر' : 'إضافة هدف',
          );
        },
      ),
    );
  }
}

class _GoalsListView extends StatelessWidget {
  const _GoalsListView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialGoalCubit, FinancialGoalState>(
      builder: (context, state) {
        if (state is FinancialGoalLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FinancialGoalError) {
          return Center(child: Text('فيه غلطة: ${state.message}'));
        }
        if (state is FinancialGoalLoaded) {
          final goals = state.goals
              .where((g) => g.type == GoalType.goal)
              .toList();

          if (goals.isEmpty) {
            return const _EmptyState(
              icon: CupertinoIcons.star_lefthalf_fill,
              message: 'مفيش أهداف مسجلة، ضيف هدف جديد!',
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: ListView.builder(
              padding: EdgeInsets.all(8.r),
              itemCount: goals.length,
              itemBuilder: (context, index) => _GoalCard(goal: goals[index]),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SavingsListView extends StatelessWidget {
  const _SavingsListView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialGoalCubit, FinancialGoalState>(
      builder: (context, state) {
        if (state is FinancialGoalLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FinancialGoalError) {
          return Center(child: Text('فيه غلطة: ${state.message}'));
        }
        if (state is FinancialGoalLoaded) {
          final savings = state.goals
              .where((g) => g.type == GoalType.saving)
              .toList();
          final totalBalance = savings.fold<double>(
            0,
            (sum, s) => sum + s.balance,
          );

          if (savings.isEmpty) {
            return const _EmptyState(
              icon: CupertinoIcons.money_dollar_circle,
              message: 'أنشئ مدخراً لتتبع رصيدك (إيداع وسحب) مع سجل لكل حركة',
            );
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                child: Card(
                  color: AppColors.primaryColor.withAlpha(20),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إجمالي المدخرات',
                          style: AppTextStyle.style14W600.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Text(
                          '${totalBalance.truncate()} $appCurrencySymbol',
                          style: AppTextStyle.style18W700.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  itemCount: savings.length,
                  itemBuilder: (context, index) =>
                      _SavingCard(saving: savings[index]),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.r,
              color: AppColors.textGreyColor.withAlpha(100),
            ),
            12.verticalSpace,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.style14W400.copyWith(
                color: AppColors.textGreyColor.withAlpha(100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});
  final FinancialGoal goal;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: appCurrencySymbol,
      decimalDigits: 0,
    );
    final remaining = goal.targetAmount - goal.savedAmount;
    final isCompleted = goal.isGoalCompleted;
    final textStyle = Theme.of(context).textTheme.titleMedium;
    final strikethroughStyle = textStyle?.copyWith(
      decoration: TextDecoration.lineThrough,
      color: Colors.grey,
    );
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.name,
                  style: isCompleted ? strikethroughStyle : textStyle,
                ),
                _GoalPopupMenu(goal: goal, isCompleted: isCompleted),
              ],
            ),
            8.verticalSpace,
            Text(
              'تم تجميع ${currencyFormat.format(goal.savedAmount.truncate())} من ${currencyFormat.format(goal.targetAmount.truncate())}',
              style: isCompleted
                  ? const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    )
                  : null,
            ),
            8.verticalSpace,
            LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8.h,
              borderRadius: BorderRadius.circular(4.r),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
            8.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isCompleted)
                  Text(
                    'اتبقى: ${currencyFormat.format(remaining.truncate())}',
                    style: TextStyle(color: Colors.grey.shade600),
                  )
                else
                  const Text(
                    '🎉 حققت هدفك',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  'الهدف: ${DateFormat.yMMMd('ar').format(goal.targetDate)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalPopupMenu extends StatelessWidget {
  const _GoalPopupMenu({required this.goal, required this.isCompleted});
  final FinancialGoal goal;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'add_funds') {
          _showGoalFundsDialog(context, goal);
        }
        if (value == 'edit') {
          _showAddEditGoalDialog(context, goal: goal);
        }
        if (value == 'delete') {
          context.read<FinancialGoalCubit>().deleteGoal(goal.id);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'add_funds',
          enabled: !isCompleted,
          child: const Text('ضيف للهدف'),
        ),
        const PopupMenuItem(value: 'edit', child: Text('عدّل')),
        const PopupMenuItem(
          value: 'delete',
          child: Text('مسح', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class _SavingCard extends StatefulWidget {
  const _SavingCard({required this.saving});
  final FinancialGoal saving;

  @override
  State<_SavingCard> createState() => _SavingCardState();
}

class _SavingCardState extends State<_SavingCard> {
  bool _historyExpanded = false;

  @override
  Widget build(BuildContext context) {
    final saving = widget.saving;
    final history = saving.sortedHistory;
    final preview = history.take(3).toList();

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(saving.name, style: AppTextStyle.style14Bold),
                      4.verticalSpace,
                      Text(
                        'الرصيد الحالي',
                        style: AppTextStyle.style12W400.copyWith(
                          fontSize: 11.sp,
                          color: AppColors.textGreyColor,
                        ),
                      ),
                      Text(
                        '${saving.balance.truncate()} $appCurrencySymbol',
                        style: AppTextStyle.style16W700.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showAddEditSavingDialog(context, saving: saving);
                    }
                    if (value == 'delete') {
                      context.read<FinancialGoalCubit>().deleteGoal(saving.id);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('عدّل الاسم')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('مسح', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            12.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSavingMovementDialog(
                      context,
                      saving: saving,
                      type: SavingMovementType.deposit,
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('إيداع'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(width: 0.5, color: Colors.green),
                      foregroundColor: Colors.green.shade700,
                    ),
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: saving.balance <= 0
                        ? null
                        : () => _showSavingMovementDialog(
                            context,
                            saving: saving,
                            type: SavingMovementType.withdrawal,
                          ),
                    icon: const Icon(Icons.remove, size: 18),
                    label: const Text('سحب'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(width: 0.5, color: Colors.orange),
                      foregroundColor: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            if (history.isNotEmpty) ...[
              12.verticalSpace,
              InkWell(
                onTap: () =>
                    setState(() => _historyExpanded = !_historyExpanded),
                child: Text(
                  'سجل الحركات (${history.length})',
                  style: AppTextStyle.style14W600.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              8.verticalSpace,
              ...(_historyExpanded ? history : preview).map(
                (entry) => _SavingHistoryTile(entry: entry),
              ),
              if (!_historyExpanded && history.length > 3)
                TextButton(
                  onPressed: () => setState(() => _historyExpanded = true),
                  child: Text('عرض ${history.length - 3} حركات أخرى'),
                ),
            ] else
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  'لا توجد حركات بعد — ابدأ بإيداع',
                  style: AppTextStyle.style12W400.copyWith(
                    color: AppColors.textGreyColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SavingHistoryTile extends StatelessWidget {
  const _SavingHistoryTile({required this.entry});
  final SavingEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDeposit = entry.isDeposit;
    final color = isDeposit ? Colors.green.shade700 : Colors.orange.shade800;
    final prefix = isDeposit ? '+' : '-';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
            size: 16.r,
            color: color,
          ),
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeposit ? 'إيداع' : 'سحب',
                  style: AppTextStyle.style12W600,
                ),
                if (entry.note != null)
                  Text(
                    entry.note!,
                    style: AppTextStyle.style12W400.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                  ),
                Text(
                  DateFormat('d MMM y – h:mm a', 'ar').format(entry.date),
                  style: AppTextStyle.style12W400.copyWith(
                    color: AppColors.textGreyColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$prefix${entry.amount.truncate()} $appCurrencySymbol',
            style: AppTextStyle.style14W600.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

void _showAddEditGoalDialog(BuildContext context, {FinancialGoal? goal}) {
  final isEditing = goal != null;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: goal?.name);
  final targetAmountController = TextEditingController(
    text: isEditing ? goal.targetAmount.truncate().toString() : '',
  );
  final savedAmountController = TextEditingController(
    text: isEditing ? goal.savedAmount.truncate().toString() : '0',
  );
  var targetDate =
      goal?.targetDate ?? DateTime.now().add(const Duration(days: 365));

  showModalBottomSheet<void>(
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    context: context,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'تعديل الهدف' : 'هدف مالي جديد',
              style: AppTextStyle.style16Bold.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
            20.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        spacing: 12.h,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomPrimaryTextfield(
                            controller: nameController,
                            text: 'اسم الهدف',
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                          CustomPrimaryTextfield(
                            controller: targetAmountController,
                            text: 'المبلغ المستهدف',
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                          if (isEditing)
                            CustomPrimaryTextfield(
                              controller: savedAmountController,
                              text: 'المبلغ المجمّع حالياً',
                              keyboardType: TextInputType.number,
                            ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('تاريخ تحقيق الهدف'),
                            subtitle: Text(
                              DateFormat.yMMMd('ar').format(targetDate),
                            ),
                            trailing: const Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryColor,
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: targetDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => targetDate = picked);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            20.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('إلغاء'),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final newGoal = FinancialGoal(
                            id: goal?.id ?? getIt<Uuid>().v4(),
                            name: nameController.text,
                            targetAmount: double.parse(
                              targetAmountController.text,
                            ),
                            savedAmount: double.parse(
                              savedAmountController.text,
                            ),
                            targetDate: targetDate,
                            type: GoalType.goal,
                          );
                          if (isEditing) {
                            context.read<FinancialGoalCubit>().updateGoal(
                              newGoal,
                            );
                          } else {
                            context.read<FinancialGoalCubit>().addGoal(
                              newGoal,
                            );
                          }
                          Navigator.of(ctx).pop();
                        }
                      },
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showAddEditSavingDialog(
  BuildContext context, {
  FinancialGoal? saving,
}) {
  final isEditing = saving != null;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: saving?.name);
  final initialBalanceController = TextEditingController(
    text: isEditing ? '' : '0',
  );
  final noteController = TextEditingController();

  showModalBottomSheet<void>(
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    context: context,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'تعديل المدخر' : 'مدخر جديد',
              style: AppTextStyle.style16Bold.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
            8.verticalSpace,
            if (!isEditing)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'المدخر حساب لرصيدك الفعلي — زِد أو اسحب لاحقاً مع تسجيل كل حركة',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.style12W400.copyWith(
                    color: AppColors.textGreyColor,
                  ),
                ),
              ),
            16.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Form(
                key: formKey,
                child: Column(
                  spacing: 12.h,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomPrimaryTextfield(
                      controller: nameController,
                      text: 'اسم المدخر (مثال: طوارئ، سفر)',
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                    if (!isEditing) ...[
                      CustomPrimaryTextfield(
                        controller: initialBalanceController,
                        text: 'رصيد افتتاحي (اختياري)',
                        keyboardType: TextInputType.number,
                      ),
                      CustomPrimaryTextfield(
                        controller: noteController,
                        text: 'ملاحظة على الإيداع الأول (اختياري)',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            20.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('إلغاء'),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        if (isEditing) {
                          context.read<FinancialGoalCubit>().updateGoal(
                            saving.copyWith(name: nameController.text.trim()),
                          );
                          Navigator.of(ctx).pop();
                          return;
                        }

                        final initialBalance =
                            double.tryParse(
                              initialBalanceController.text,
                            ) ??
                            0;
                        final now = DateTime.now();
                        final history = <SavingEntry>[];
                        if (initialBalance > 0) {
                          history.add(
                            SavingEntry(
                              id: getIt<Uuid>().v4(),
                              amount: initialBalance,
                              date: now,
                              type: SavingMovementType.deposit,
                              note: noteController.text.trim().isEmpty
                                  ? 'رصيد افتتاحي'
                                  : noteController.text.trim(),
                            ),
                          );
                        }

                        final newSaving = FinancialGoal(
                          id: getIt<Uuid>().v4(),
                          name: nameController.text.trim(),
                          targetAmount: 0,
                          savedAmount: initialBalance,
                          targetDate: now,
                          type: GoalType.saving,
                          history: history,
                        );
                        context.read<FinancialGoalCubit>().addGoal(newSaving);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showGoalFundsDialog(BuildContext context, FinancialGoal goal) {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('إضافة للهدف: ${goal.name}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'المبلغ'),
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.isEmpty || double.tryParse(v) == null
                ? 'أدخل مبلغاً صحيحاً'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<FinancialGoalCubit>().addFundsToGoal(
                  goal.id,
                  double.parse(amountController.text),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      );
    },
  );
}

void _showSavingMovementDialog(
  BuildContext context, {
  required FinancialGoal saving,
  required SavingMovementType type,
}) {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final isDeposit = type == SavingMovementType.deposit;

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
          isDeposit ? 'إيداع في ${saving.name}' : 'سحب من ${saving.name}',
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الرصيد الحالي: ${saving.balance.truncate()} $appCurrencySymbol',
                style: AppTextStyle.style12W400.copyWith(
                  color: AppColors.textGreyColor,
                ),
              ),
              12.verticalSpace,
              CustomPrimaryTextfield(
                controller: amountController,
                text: isDeposit ? 'مبلغ الإيداع' : 'مبلغ السحب',

                keyboardType: TextInputType.number,
                validator: (v) {
                  final amount = double.tryParse(v ?? '');
                  if (amount == null || amount <= 0) {
                    return 'أدخل مبلغاً صحيحاً';
                  }
                  if (!isDeposit && amount > saving.balance) {
                    return 'المبلغ أكبر من الرصيد';
                  }
                  return null;
                },
              ),
              12.verticalSpace,
              CustomPrimaryTextfield(
                controller: noteController,
                text: 'ملاحظة (اختياري)',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<FinancialGoalCubit>().recordSavingMovement(
                  goalId: saving.id,
                  amount: double.parse(amountController.text),
                  type: type,
                  note: noteController.text,
                );
                Navigator.of(ctx).pop();
              }
            },
            child: Text(isDeposit ? 'إيداع' : 'سحب'),
          ),
        ],
      );
    },
  );
}
