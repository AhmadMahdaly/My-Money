// =========================================================================
// 3. التبويب الثالث: إدارة الديون والأقساط
// =========================================================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_dropdown_button.dart';
import 'package:opration/core/shared_widgets/custom_floating_action_buttom.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/financial_goals/domain/entities/debt.dart';
import 'package:opration/features/financial_goals/presentation/cubit/debt_cubit/debt_cubit.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class DebtsView extends StatelessWidget {
  const DebtsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtCubit, DebtState>(
      builder: (context, state) {
        final debts = state.items; // جلب الديون من الـ State

        return Scaffold(
          floatingActionButton: CustomFloatingActionButton(
            onPressed: () => _showAddDebtDialog(context),
            tooltip: 'إضافة دين أو قسط',
          ),
          body: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              Text('ديون وأقساط نشطة:', style: AppTextStyles.style16W600),
              8.verticalSpace,
              if (debts.isEmpty)
                Padding(
                  padding: EdgeInsets.all(24.r),
                  child: const Text(
                    'الحمد لله، مفيش ديون أو أقساط متسجلة!',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...debts.map((debt) => _buildDebtCard(context, debt)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebtCard(BuildContext context, Debt debt) {
    return Card(
      color: AppColors.primaryTextColor.withAlpha(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(debt.name, style: AppTextStyles.style16W600),
                if (debt.autoDeduct)
                  Icon(
                    Icons.autorenew,
                    color: AppColors.primaryColor,
                    size: 18.r,
                  ),
              ],
            ),
            8.verticalSpace,
            Text(
              'المتبقي: ${debt.remainingAmount.truncate()} ج.م',
              style: AppTextStyles.style14W700.copyWith(
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
                  style: AppTextStyles.style12W400,
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

  void _showManualPaymentDialog(BuildContext context, Debt debt) {
    final formKey = GlobalKey<FormState>();

    // اقتراح قيمة الدفعة: إذا كان القسط أكبر من 0 وأصغر من المتبقي، نقترحه. وإلا نقترح كل المتبقي.
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
                    style: AppTextStyles.style14W600.copyWith(
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

                    // استدعاء دالة الدفع اليدوي من الـ Cubit
                    context.read<DebtCubit>().recordManualPayment(
                      debt: debt,
                      amount: amountToPay,
                      walletId: selectedWalletId!,
                      categoryId:
                          debt.categoryId ??
                          '', // الفئة التي تم حفظها عند إنشاء الدين
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

  void _showAddDebtDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final installmentController = TextEditingController();

    var selectedRecurrence = DebtRecurrence.once;
    int? recurrenceValue;
    DateTime? selectedDate = DateTime.now();
    var autoDeduct = false;
    String? selectedWalletId;

    // --- متغيرات الفئات ---
    String? selectedMainCategoryId;
    String? selectedSubCategoryId;

    final wallets = (context.read<WalletCubit>().state as WalletLoaded).wallets;

    // جلب جميع فئات المصاريف
    final allExpenseCategories = context
        .read<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.expense)
        .toList();
    // الفئات الرئيسية فقط للدروب داون الأول
    final mainCategories = allExpenseCategories
        .where((c) => c.parentId == null)
        .toList();

    showModalBottomSheet<void>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Text(
                'إضافة دين أو قسط',
                style: AppTextStyles.style14W600,
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

                        // --- نوع الدفع ---
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
                          ],
                          onChanged: (v) {
                            setState(() {
                              selectedRecurrence = v!;
                              recurrenceValue = null;
                            });
                          },
                        ),
                        12.verticalSpace,

                        // --- إذا كان قسطاً (أسبوعي أو شهري)، نظهر حقل قيمة القسط ---
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

                        // --- الحقول المتغيرة بناءً على موعد الاستحقاق ---
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

                        // --- تصنيف الدين (CategoryId) ---
                        CustomDropdownButtonFormField<String>(
                          hintText: 'صنف هذا الدين تحت فئة:',

                          value: selectedMainCategoryId,
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
                              selectedSubCategoryId =
                                  null; // تصفير الفئة الفرعية عند التغيير
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

                        // --- الخصم التلقائي والمحفظة ---
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'خصم تلقائي في موعد الاستحقاق',
                            style: AppTextStyles.style12W600,
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
                            final total = double.parse(amountController.text);
                            final inst =
                                selectedRecurrence == DebtRecurrence.once
                                ? total
                                : (double.tryParse(
                                        installmentController.text,
                                      ) ??
                                      0.0);

                            // استخراج الـ ID النهائي (لو اختار فرعية ناخذها، وإلا ناخذ الرئيسية)
                            final finalCategoryId =
                                selectedSubCategoryId ?? selectedMainCategoryId;

                            final newDebt = Debt(
                              id: const Uuid().v4(),
                              name: nameController.text,
                              totalAmount: total,
                              installmentAmount: inst,
                              recurrence: selectedRecurrence,
                              dueDate: selectedRecurrence == DebtRecurrence.once
                                  ? selectedDate
                                  : null,
                              recurrenceValue: recurrenceValue,
                              autoDeduct: autoDeduct,
                              targetWalletId: selectedWalletId,
                              categoryId:
                                  finalCategoryId, // <-- الفئة النهائية الدقيقة
                            );

                            context.read<DebtCubit>().addDebt(newDebt);

                            Navigator.pop(ctx);
                            showCustomSnackBar(
                              context,
                              message: 'تم إضافة الدين بنجاح!',
                            );
                          }
                        },
                        child: const Text(
                          'إضافة الدين',
                          style: TextStyle(color: Colors.white),
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
