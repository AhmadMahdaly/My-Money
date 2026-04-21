import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_dropdown_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/debt/domain/entities/debt.dart';
import 'package:opration/features/debt/presentation/controllers/debt_cubit/debt_cubit.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_widget.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class RecurringOperationsScreen extends StatelessWidget {
  const RecurringOperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(
        isLeading: true,
        title: 'العمليات المتكررة',
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, transactionState) {
          return BlocBuilder<DebtCubit, DebtState>(
            builder: (context, debtState) {
              final recurringCategories = transactionState.allCategories
                  .where((c) => c.isRecurring)
                  .toList();

              final recurringDebts = debtState.items
                  .where((d) => d.recurrence != DebtRecurrence.once)
                  .toList();

              if (recurringCategories.isEmpty && recurringDebts.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد أي عمليات متكررة مسجلة حالياً.',
                    style: AppTextStyle.style14W500.copyWith(
                      color: AppColors.primaryColor.withAlpha(150),
                    ),
                  ),
                );
              }

              return ListView(
                padding: EdgeInsets.all(16.r),
                children: [
                  if (recurringCategories.isNotEmpty) ...[
                    Text(
                      'المخصصات الثابتة (دخل / صرف)',
                      style: AppTextStyle.style16Bold,
                    ),
                    8.verticalSpace,
                    ...recurringCategories.map(
                      (category) => _RecurringCategoryCard(category: category),
                    ),
                    20.verticalSpace,
                  ],
                  if (recurringDebts.isNotEmpty) ...[
                    Text(
                      'الالتزامات والأقساط المتكررة',
                      style: AppTextStyle.style16Bold,
                    ),
                    8.verticalSpace,
                    ...recurringDebts.map(
                      (debt) => _RecurringDebtCard(debt: debt),
                    ),
                    60.verticalSpace,
                  ],
                ],
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor,
        onPressed: () => _showAddChoiceDialog(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        icon: const Icon(
          Icons.add,
          color: AppColors.scaffoldBackgroundLightColor,
        ),
        label: Text(
          'إضافة عملية',
          style: AppTextStyle.style14W500.copyWith(
            color: AppColors.scaffoldBackgroundLightColor,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // ديالوجات تحديد نوع الإضافة (جديد أم موجود)
  // ---------------------------------------------------------
  void _showAddChoiceDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'ما الذي تريد إضافته؟',
          textAlign: TextAlign.center,
          style: AppTextStyle.style16W700.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.category_outlined,
                color: AppColors.successColor,
              ),
              title: const Text('مخصص متكرر (راتب، إيجار...)'),
              onTap: () {
                Navigator.pop(ctx);
                _showExistingOrNewCategoryDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.orangeColor,
              ),
              title: const Text('التزام / قسط متكرر'),
              onTap: () {
                Navigator.pop(ctx);
                _showExistingOrNewDebtDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExistingOrNewCategoryDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مخصص موجود أم جديد؟', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showExistingCategoriesSheet(context);
              },
              child: const Text('تحويل مخصص حالي لمتكرر'),
            ),
            8.verticalSpace,
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showCategoryTypeSelection(context);
              },
              child: const Text('إنشاء مخصص جديد تماماً'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExistingOrNewDebtDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('التزام موجود أم جديد؟', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showExistingDebtsSheet(context);
              },
              child: const Text('تحويل دين حالي لقسط متكرر'),
            ),
            8.verticalSpace,
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showAddDebtDialog(context); // جديد
              },
              child: const Text('إضافة التزام جديد تماماً'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // Bottom Sheets لاختيار عناصر موجودة
  // ---------------------------------------------------------
  void _showExistingCategoriesSheet(BuildContext context) {
    final allCategories = context.read<TransactionCubit>().state.allCategories;
    // جلب الفئات العادية فقط (التي ليست متكررة بعد)
    final normalCategories = allCategories
        .where((c) => !c.isRecurring)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => normalCategories.isEmpty
          ? const Center(child: Text('لا توجد مخصصات عادية لتحويلها.'))
          : ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: normalCategories.length,
              itemBuilder: (context, index) {
                final cat = normalCategories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cat.color,
                    radius: 16.r,
                  ),
                  title: Text(cat.name),
                  subtitle: Text(
                    cat.type == TransactionType.income ? 'دخل' : 'صرف',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openCategoryDialog(context, cat.type, cat);
                  },
                );
              },
            ),
    );
  }

  void _showExistingDebtsSheet(BuildContext context) {
    final allDebts = context.read<DebtCubit>().state.items;
    // جلب الديون المخصصة لمرة واحدة فقط لتفعيل التكرار عليها
    final onceDebts = allDebts
        .where((d) => d.recurrence == DebtRecurrence.once)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => onceDebts.isEmpty
          ? const Center(
              child: Text('لا توجد ديون (لمرة واحدة) لتحويلها لأقساط.'),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: onceDebts.length,
              itemBuilder: (context, index) {
                final debt = onceDebts[index];
                return ListTile(
                  leading: const Icon(
                    Icons.receipt_long,
                    color: AppColors.orangeColor,
                  ),
                  title: Text(debt.name),
                  subtitle: Text(
                    'المتبقي: ${debt.remainingAmount.truncate()} ج.م',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddDebtDialog(context, debtToEdit: debt);
                  },
                );
              },
            ),
    );
  }

  // ---------------------------------------------------------
  // منطق الإنشاء والتعديل
  // ---------------------------------------------------------
  void _showCategoryTypeSelection(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('نوع المخصص المتكرر', textAlign: TextAlign.center),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: Icon(
                CupertinoIcons.add_circled,
                color: AppColors.successColor,
              ),
              label: Text(
                'دخل',
                style: TextStyle(color: AppColors.successColor),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _openCategoryDialog(context, TransactionType.income);
              },
            ),
            TextButton.icon(
              icon: const Icon(
                CupertinoIcons.minus_circle,
                color: AppColors.errorColor,
              ),
              label: const Text(
                'صرف',
                style: TextStyle(color: AppColors.errorColor),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _openCategoryDialog(context, TransactionType.expense);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openCategoryDialog(
    BuildContext context,
    TransactionType type, [
    TransactionCategory? categoryToEdit,
  ]) {
    showModalBottomSheet<TransactionCategory>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (_) => AddCategoryWidget(
        type: type,
        categoryToEdit: categoryToEdit,
      ),
    ).then((result) {
      if (result != null) {
        if (categoryToEdit == null) {
          context.read<TransactionCubit>().addCategory(result);
        } else {
          context.read<TransactionCubit>().updateCategory(result);
        }
      }
    });
  }

  void _showAddDebtDialog(BuildContext context, {Debt? debtToEdit}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: debtToEdit?.name ?? '');
    final amountController = TextEditingController(
      text: debtToEdit?.totalAmount.truncate().toString() ?? '',
    );
    final installmentController = TextEditingController(
      text: debtToEdit?.installmentAmount.truncate().toString() ?? '',
    );

    // جلب التواريخ المخصصة القديمة إذا كان تعديلاً، أو تهيئة قائمة فارغة
    final customDatesList = List<DateTime>.from(debtToEdit?.customDates ?? []);

    // اجعل الافتراضي شهرياً إذا كان جديداً أو لمرة واحدة، وإلا استخدم تكرار الدين
    var selectedRecurrence = debtToEdit?.recurrence == DebtRecurrence.once
        ? DebtRecurrence.monthly
        : (debtToEdit?.recurrence ?? DebtRecurrence.monthly);

    var recurrenceValue = debtToEdit?.recurrenceValue;
    DateTime? selectedDate = debtToEdit?.dueDate ?? DateTime.now();
    var autoDeduct = debtToEdit?.autoDeduct ?? false;
    var selectedWalletId = debtToEdit?.targetWalletId;

    String? selectedMainCategoryId;
    String? selectedSubCategoryId;

    if (debtToEdit?.categoryId != null) {
      selectedMainCategoryId = debtToEdit?.categoryId;
    }

    final wallets = (context.read<WalletCubit>().state as WalletLoaded).wallets;
    final allExpenseCategories = context
        .read<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.expense)
        .toList();
    final mainCategories = allExpenseCategories
        .where((c) => c.parentId == null)
        .toList();

    showModalBottomSheet<void>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      routeSettings: const RouteSettings(name: AppRoutes.addDebtsView),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Text(
                debtToEdit == null
                    ? 'إضافة دين أو قسط متكرر'
                    : 'تحويل "${debtToEdit.name}" لقسط',
                style: AppTextStyle.style14W600,
              ),
              20.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPrimaryTextfield(
                          controller: nameController,
                          text: 'لمن هذا الدين؟ (مثال: قسط العربية)',
                          validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                        ),
                        12.verticalSpace,
                        CustomPrimaryTextfield(
                          controller: amountController,
                          text: 'المبلغ الإجمالي للدين',
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                        ),
                        16.verticalSpace,

                        CustomDropdownButtonFormField<DebtRecurrence>(
                          hintText: 'نظام الدفع',
                          value: selectedRecurrence,
                          items: const [
                            DropdownMenuItem(
                              value: DebtRecurrence.once,
                              child: Text('يدفع مرة واحدة'),
                            ),
                            DropdownMenuItem(
                              value: DebtRecurrence.weekly,
                              child: Text('قسط أسبوعي'),
                            ),
                            DropdownMenuItem(
                              value: DebtRecurrence.monthly,
                              child: Text('قسط شهري'),
                            ),
                            DropdownMenuItem(
                              value: DebtRecurrence.custom,
                              child: Text('تواريخ مخصصة'),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              selectedRecurrence = v!;
                              recurrenceValue = null;
                            });
                          },
                        ),
                        12.verticalSpace,

                        if (selectedRecurrence != DebtRecurrence.once) ...[
                          CustomPrimaryTextfield(
                            controller: installmentController,
                            text: 'قيمة القسط الواحد',
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v!.isEmpty ? 'أدخل قيمة القسط' : null,
                          ),
                          12.verticalSpace,
                        ],

                        if (selectedRecurrence == DebtRecurrence.once)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('تاريخ الاستحقاق'),
                            subtitle: Text(
                              DateFormat.yMMMd('ar').format(selectedDate!),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                          )
                        else if (selectedRecurrence == DebtRecurrence.monthly)
                          CustomDropdownButtonFormField<int>(
                            hintText: 'يوم كام في الشهر؟',
                            value: recurrenceValue,
                            items: List.generate(
                              31,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('يوم ${i + 1}'),
                              ),
                            ),
                            onChanged: (v) =>
                                setState(() => recurrenceValue = v),
                            validator: (v) => v == null ? 'اختر اليوم' : null,
                          )
                        else if (selectedRecurrence == DebtRecurrence.custom)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'إضافة تواريخ معينة',
                                  style: AppTextStyle.style12W600,
                                ),
                                trailing: const Icon(Icons.add_circle_outline),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      // التأكد من عدم تكرار نفس اليوم
                                      if (!customDatesList.any(
                                        (d) =>
                                            d.year == picked.year &&
                                            d.month == picked.month &&
                                            d.day == picked.day,
                                      )) {
                                        customDatesList.add(picked);
                                      }
                                    });
                                  }
                                },
                              ),
                              if (customDatesList.isNotEmpty)
                                Wrap(
                                  spacing: 8.w,
                                  children: customDatesList.map((date) {
                                    return Chip(
                                      label: Text(
                                        DateFormat.MMMd('ar').format(date),
                                      ),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 16,
                                      ),
                                      onDeleted: () {
                                        setState(
                                          () => customDatesList.remove(date),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                            ],
                          )
                        else if (selectedRecurrence == DebtRecurrence.weekly)
                          CustomDropdownButtonFormField<int>(
                            hintText: 'أي يوم في الأسبوع؟',
                            value: recurrenceValue,
                            items: const [
                              DropdownMenuItem(value: 6, child: Text('السبت')),
                              DropdownMenuItem(value: 7, child: Text('الأحد')),
                              DropdownMenuItem(
                                value: 1,
                                child: Text('الإثنين'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('الثلاثاء'),
                              ),
                              DropdownMenuItem(
                                value: 3,
                                child: Text('الأربعاء'),
                              ),
                              DropdownMenuItem(value: 4, child: Text('الخميس')),
                              DropdownMenuItem(value: 5, child: Text('الجمعة')),
                            ],
                            onChanged: (v) =>
                                setState(() => recurrenceValue = v),
                            validator: (v) => v == null ? 'اختر اليوم' : null,
                          ),

                        const Divider(),

                        CustomDropdownButtonFormField<String>(
                          hintText: 'صنف هذا الدين تحت فئة:',
                          value:
                              mainCategories.any(
                                (c) => c.id == selectedMainCategoryId,
                              )
                              ? selectedMainCategoryId
                              : null,
                          items: mainCategories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              selectedMainCategoryId = v;
                              selectedSubCategoryId = null;
                            });
                          },
                          validator: (v) => v == null ? 'اختر الفئة' : null,
                        ),
                        ...(() {
                          final subCategories = selectedMainCategoryId != null
                              ? allExpenseCategories
                                    .where(
                                      (c) =>
                                          c.parentId == selectedMainCategoryId,
                                    )
                                    .toList()
                              : <TransactionCategory>[];

                          if (subCategories.isNotEmpty) {
                            return [
                              12.verticalSpace,
                              CustomDropdownButtonFormField<String>(
                                hintText: 'الفئة الفرعية (اختياري):',
                                value: selectedSubCategoryId,
                                items: subCategories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => selectedSubCategoryId = v),
                              ),
                            ];
                          }
                          return [const SizedBox.shrink()];
                        }()),
                        12.verticalSpace,

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'خصم تلقائي في موعد الاستحقاق',
                            style: AppTextStyle.style12W600,
                          ),
                          value: autoDeduct,
                          activeThumbColor: AppColors.primaryColor,
                          onChanged: (v) => setState(() => autoDeduct = v),
                        ),

                        if (autoDeduct)
                          CustomDropdownButtonFormField<String>(
                            hintText: 'خصم من أي محفظة؟',
                            value: selectedWalletId,
                            items: wallets
                                .map(
                                  (w) => DropdownMenuItem(
                                    value: w.id,
                                    child: Text(w.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedWalletId = v),
                            validator: (v) => autoDeduct && v == null
                                ? 'اختر محفظة للخصم'
                                : null,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              30.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء'),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorColor,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            // تحقق إضافي: إذا كان التكرار "مخصص"، يجب أن يختار تاريخاً واحداً على الأقل
                            if (selectedRecurrence == DebtRecurrence.custom &&
                                customDatesList.isEmpty) {
                              showCustomSnackBar(
                                context,
                                message:
                                    'برجاء إضافة تاريخ واحد على الأقل للاستحقاق.',
                              );
                              return;
                            }

                            final total = double.parse(amountController.text);
                            final inst =
                                selectedRecurrence == DebtRecurrence.once
                                ? total
                                : (double.tryParse(
                                        installmentController.text,
                                      ) ??
                                      0.0);

                            final finalCategoryId =
                                selectedSubCategoryId ?? selectedMainCategoryId;

                            final newDebt = Debt(
                              id: debtToEdit?.id ?? const Uuid().v4(),
                              name: nameController.text,
                              totalAmount: total,
                              installmentAmount: inst,
                              recurrenceValue: recurrenceValue,
                              autoDeduct: autoDeduct,
                              targetWalletId: selectedWalletId,
                              categoryId: finalCategoryId,
                              recurrence: selectedRecurrence,
                              customDates:
                                  selectedRecurrence == DebtRecurrence.custom
                                  ? customDatesList
                                  : null,
                              dueDate: selectedRecurrence == DebtRecurrence.once
                                  ? selectedDate
                                  : null,
                              // نحافظ على ما تم دفعه في حال كان تعديلاً
                              paidAmount: debtToEdit?.paidAmount ?? 0.0,
                            );

                            if (debtToEdit == null) {
                              context.read<DebtCubit>().addDebt(newDebt);
                            } else {
                              context.read<DebtCubit>().updateDebt(newDebt);
                            }

                            Navigator.pop(ctx);
                            showCustomSnackBar(
                              context,
                              message: debtToEdit == null
                                  ? 'تم إضافة الدين بنجاح!'
                                  : 'تم تحديث الالتزام بنجاح!',
                            );
                          }
                        },
                        child: Text(
                          debtToEdit == null ? 'إضافة الدين' : 'حفظ التعديل',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecurringCategoryCard extends StatelessWidget {
  const _RecurringCategoryCard({required this.category});
  final TransactionCategory category;

  @override
  Widget build(BuildContext context) {
    final isIncome = category.type == TransactionType.income;
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color.withAlpha(40),
          child: Icon(
            isIncome
                ? CupertinoIcons.arrow_down_left
                : CupertinoIcons.arrow_up_right,
            color: category.color,
          ),
        ),
        title: Text(category.name, style: AppTextStyle.style14W500),
        subtitle: Text(
          isIncome ? 'دخل متكرر' : 'صرف متكرر',
          style: AppTextStyle.style12W300.copyWith(
            color: AppColors.primaryColor.withAlpha(150),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${category.fixedAmount?.truncate() ?? 0} ج.م',
              style: AppTextStyle.style14Bold.copyWith(
                color: isIncome ? AppColors.successColor : AppColors.errorColor,
              ),
            ),
          ],
        ),
        onTap: () {
          showModalBottomSheet<TransactionCategory>(
            isScrollControlled: true,
            useSafeArea: true,
            showDragHandle: true,
            context: context,
            builder: (_) => AddCategoryWidget(
              type: category.type,
              categoryToEdit: category,
            ),
          ).then((updated) {
            if (updated != null) {
              context.read<TransactionCubit>().updateCategory(updated);
            }
          });
        },
      ),
    );
  }
}

class _RecurringDebtCard extends StatelessWidget {
  const _RecurringDebtCard({required this.debt});
  final Debt debt;

  @override
  Widget build(BuildContext context) {
    var recurrenceText = '';
    if (debt.recurrence == DebtRecurrence.monthly) {
      recurrenceText = 'قسط شهري (يوم ${debt.recurrenceValue})';
    } else if (debt.recurrence == DebtRecurrence.weekly) {
      recurrenceText = 'قسط أسبوعي';
    }

    return Card(
      color: AppColors.primaryTextColor.withAlpha(40),
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(debt.name, style: AppTextStyle.style16W600),
                      8.horizontalSpace,
                      if (debt.autoDeduct)
                        Icon(
                          Icons.autorenew,
                          color: AppColors.primaryColor,
                          size: 18.r,
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteDebtConfirmation(context, debt);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'مسح الالتزام',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            4.verticalSpace,

            Text(
              '$recurrenceText: ${debt.installmentAmount.truncate()} ج.م',
              style: AppTextStyle.style12W500.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
            8.verticalSpace,
            Text(
              'المتبقي: ${debt.remainingAmount.truncate()} ج.م',
              style: AppTextStyle.style14W700.copyWith(
                color: AppColors.errorColor,
              ),
            ),
            4.verticalSpace,
            LinearProgressIndicator(
              value: debt.totalAmount > 0
                  ? (debt.paidAmount / debt.totalAmount)
                  : 0,
              backgroundColor: Colors.red.shade100,
              color: AppColors.successColor,
              minHeight: 6.h,
            ),
            8.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المدفوع: ${debt.paidAmount.truncate()} ج.م',
                  style: AppTextStyle.style12W400,
                ),
                TextButton(
                  onPressed: debt.isFullyPaid
                      ? null
                      : () => _showManualPaymentDialog(context, debt),
                  child: Text(
                    debt.isFullyPaid ? 'تم السداد' : 'تسجيل دفعة',
                    style: TextStyle(
                      color: debt.isFullyPaid
                          ? Colors.grey
                          : AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDebtConfirmation(BuildContext context, Debt debt) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('متأكد؟'),
        content: Text(
          'هل تريد فعلاً مسح "${debt.name}"؟\n\n'
          'ملاحظة: مسح الدين من هنا لن يمسح المدفوعات التي سجلتها مسبقاً في سجل المعاملات.',
          style: AppTextStyle.style14W400,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            onPressed: () {
              context.read<DebtCubit>().deleteDebt(debt.id);
              Navigator.pop(ctx);
              showCustomSnackBar(context, message: 'تم مسح الالتزام بنجاح');
            },
            child: const Text('مسح', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManualPaymentDialog(BuildContext context, Debt debt) {
    final formKey = GlobalKey<FormState>();

    final defaultAmount =
        (debt.installmentAmount > 0 &&
            debt.installmentAmount <= debt.remainingAmount)
        ? debt.installmentAmount
        : debt.remainingAmount;

    final amountController = TextEditingController(
      text: defaultAmount.truncate().toString(),
    );
    String? selectedWalletId;

    final wallets = (context.read<WalletCubit>().state as WalletLoaded).wallets;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('سداد دفعة لـ "${debt.name}"'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المتبقي من الدين: ${debt.remainingAmount.truncate()} ج.م',
                    style: AppTextStyle.style14W600.copyWith(
                      color: AppColors.errorColor,
                    ),
                  ),
                  16.verticalSpace,
                  CustomPrimaryTextfield(
                    controller: amountController,
                    text: 'هتدفع كام؟',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'مطلوب';
                      final amount = double.tryParse(v);
                      if (amount == null || amount <= 0) return 'مبلغ غير صحيح';
                      if (amount > debt.remainingAmount) {
                        return 'المبلغ أكبر من المتبقي!';
                      }
                      return null;
                    },
                  ),
                  16.verticalSpace,
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'هتخصم الدفعة من أي محفظة؟',
                    ),
                    initialValue: selectedWalletId,
                    items: wallets
                        .map(
                          (w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(w.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedWalletId = v),
                    validator: (v) => v == null ? 'اختر محفظة للخصم' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successColor,
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final amountToPay = double.parse(amountController.text);

                    context.read<DebtCubit>().recordManualPayment(
                      debt: debt,
                      amount: amountToPay,
                      walletId: selectedWalletId!,
                      categoryId: debt.categoryId ?? '',
                      paymentDate: DateTime.now(),
                      transactionCubit: context.read<TransactionCubit>(),
                      walletCubit: context.read<WalletCubit>(),
                    );

                    Navigator.pop(ctx);
                    showCustomSnackBar(
                      context,
                      message: 'تم تسجيل الدفعة وخصمها من المحفظة بنجاح!',
                    );
                  }
                },
                child: const Text(
                  'دفع وتسجيل',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
