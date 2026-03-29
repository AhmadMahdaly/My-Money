import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_dropdown_button.dart';
import 'package:opration/core/shared_widgets/custom_floating_action_buttom.dart';
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
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class DebtsView extends StatelessWidget {
  const DebtsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtCubit, DebtState>(
      builder: (context, state) {
        final debts = state.items;

        return Scaffold(
          appBar: const PageHeader(
            isLeading: true,
            subTitle: SubTitle(),
            title: 'الإلتزامات والديون',
            // bottom: Container(
            //   height: 50.h,
            //   decoration: BoxDecoration(
            //     border: Border.all(
            //       color: AppColors.scaffoldBackgroundLightColor,
            //       width: 0.5.w,
            //     ),
            //     borderRadius: BorderRadius.circular(kRadius),
            //   ),
            //   child: TabBar(
            //     indicatorPadding: EdgeInsets.all(3.r),
            //     indicator: BoxDecoration(
            //       borderRadius: BorderRadius.circular(kRadius),
            //       color: AppColors.scaffoldBackgroundLightColor,
            //     ),
            //     indicatorSize: TabBarIndicatorSize.tab,
            //     dividerHeight: 0,
            //     labelColor: AppColors.primaryColor,
            //     unselectedLabelColor: AppColors.scaffoldBackgroundLightColor,
            //     labelStyle: AppTextStyles.style14W600.copyWith(
            //       fontFamily: kPrimaryFont,
            //     ),
            //     unselectedLabelStyle: AppTextStyles.style14W600.copyWith(
            //       fontFamily: kPrimaryFont,
            //     ),
            //     tabs: const [
            //       Tab(text: 'الأهداف'),
            //       Tab(text: 'المشتريات'),
            //       Tab(text: 'الديون'),
            //     ],
            //   ),
            // ),
            // // heightBar: 170.h,
          ),
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: SizedBox(
                        height: SizeConfig.screenHeight / 1.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 36.r,
                              color: AppColors.textGreyColor,
                            ),
                            12.verticalSpace,
                            Center(
                              child: Text(
                                'الحمد لله، مفيش ديون أو أقساط متسجلة!',

                                style: AppTextStyles.style14W500.copyWith(
                                  color: AppColors.textGreyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                Expanded(
                  child: Row(
                    children: [
                      Text(debt.name, style: AppTextStyles.style16W600),
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
                        'مسح الدين',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
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

  void _showDeleteDebtConfirmation(BuildContext context, Debt debt) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('متأكد؟'),
        content: Text(
          'هل تريد فعلاً مسح "${debt.name}"؟\n\n'
          'ملاحظة: مسح الدين من هنا لن يمسح المدفوعات التي سجلتها مسبقاً في سجل المعاملات.',
          style: AppTextStyles.style14W400,
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
              showCustomSnackBar(context, message: 'تم مسح الدين بنجاح');
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

                    context.read<DebtCubit>().recordManualPayment(
                      debt: debt,
                      amount: amountToPay,
                      walletId: selectedWalletId!,
                      categoryId: debt.categoryId ?? '',
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

    String? selectedMainCategoryId;
    String? selectedSubCategoryId;

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
                              categoryId: finalCategoryId,
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
