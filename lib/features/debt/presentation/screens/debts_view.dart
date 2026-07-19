// ignore_for_file: deprecated_member_use, omit_local_variable_types

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/services/format_currency.dart';
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
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class DebtsView extends StatelessWidget {
  const DebtsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtCubit, DebtState>(
      builder: (context, state) {
        final allDebts = state.items;

        final activeDebts = allDebts.where((d) => !d.isFullyPaid).toList();
        final settledDebts = allDebts.where((d) => d.isFullyPaid).toList();

        final totalRemainingDebts = activeDebts.fold(
          0.0,
          (sum, debt) => sum + debt.remainingAmount,
        );

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: const PageHeader(
              isLeading: true,
              title: 'الإلتزامات والديون',
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton: SpeedDial(
              backgroundColor: AppColors.primaryColor,
              iconTheme: const IconThemeData(
                color: AppColors.scaffoldBackgroundLightColor,
              ),
              icon: Icons.add,
              activeIcon: Icons.close,
              spacing: 4.h,
              spaceBetweenChildren: 4.h,
              overlayOpacity: 0.3,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.history),
                  label: 'سجل المدفوعات',
                  onTap: () {
                    context.pushNamed(AppRoutes.debtPaymentsLogView);
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  label: 'إضافة دين أو قسط',
                  onTap: () => _showAddEditDebtDialog(context),
                ),
              ],
            ),

            body: Column(
              children: [
                _buildTotalDebtsCard(context, totalRemainingDebts),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.primaryColor,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: AppColors.primaryColor,
                    ),
                    labelStyle: AppTextStyle.style14W600,
                    tabs: const [
                      Tab(text: 'ديون نشطة'),
                      Tab(text: 'تم السداد'),
                    ],
                  ),
                ),
                12.verticalSpace,

                Expanded(
                  child: TabBarView(
                    children: [
                      _buildDebtsList(
                        context,
                        debts: activeDebts,
                        emptyMessage: 'الحمد لله، مفيش ديون أو أقساط نشطة!',
                      ),

                      _buildDebtsList(
                        context,
                        debts: settledDebts,
                        emptyMessage: 'لسه مفيش ديون تم سدادها بالكامل.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebtsList(
    BuildContext context, {
    required List<Debt> debts,
    required String emptyMessage,
  }) {
    if (debts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.check_mark_circled_solid,
            size: 50.r,
            color: AppColors.textGreyColor.withAlpha(100),
          ),
          16.verticalSpace,
          Text(
            emptyMessage,
            style: AppTextStyle.style14W400.copyWith(
              color: AppColors.textGreyColor.withAlpha(150),
            ),
          ),
          80.verticalSpace,
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: debts.length + 1,
      itemBuilder: (context, index) {
        if (index == debts.length) {
          return 80.verticalSpace;
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: _buildDebtCard(context, debts[index]),
        );
      },
    );
  }

  Widget _buildTotalDebtsCard(BuildContext context, double totalRemaining) {
    return Container(
      margin: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withAlpha(220),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.errorColor.withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إجمالي الديون المتبقية',
                style: AppTextStyle.style14W600.copyWith(
                  color: Colors.white.withAlpha(220),
                ),
              ),
              8.verticalSpace,
              Text(
                '${formatCurrency(totalRemaining)} $appCurrencySymbol',
                style: AppTextStyle.style16W600.copyWith(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 32.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, Debt debt) {
    return Card(
      color: AppColors.primaryTextColor.withAlpha(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          debt.name,
                          style: AppTextStyle.style16W600,
                          overflow: TextOverflow.fade,
                          softWrap: true,
                        ),
                      ),
                      8.horizontalSpace,
                      if (debt.autoDeduct && !debt.isFullyPaid)
                        Icon(
                          Icons.autorenew,
                          color: AppColors.primaryColor,
                          size: 18.r,
                        ),
                    ],
                  ),
                ),
                if (!debt.isFullyPaid)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditDebtDialog(context, existingDebt: debt);
                      } else if (value == 'delete') {
                        _showDeleteDebtConfirmation(context, debt);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('تعديل الدين'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'مسح الدين',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                else
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'reActive') {
                        _showReactivateDialog(context, debt);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'reActive',
                        child: Text('إعادة الدين'),
                      ),
                    ],
                  ),
              ],
            ),
            4.verticalSpace,
            Text(
              'المتبقي: ${formatCurrency(debt.remainingAmount)} $appCurrencySymbol',
              style: AppTextStyle.style12W500.copyWith(
                color: debt.isFullyPaid
                    ? AppColors.successColor
                    : AppColors.errorColor,
              ),
            ),
            8.verticalSpace,
            LinearProgressIndicator(
              value: debt.totalAmount > 0
                  ? (debt.paidAmount / debt.totalAmount)
                  : 0,
              backgroundColor: Colors.red.shade100,
              color: AppColors.successColor,
              minHeight: 6.h,
            ),
            4.verticalSpace,
            if (debt.nextDueDate != null && !debt.isFullyPaid) ...[
              4.verticalSpace,
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 14.sp,
                    color: AppColors.textGreyColor,
                  ),
                  4.horizontalSpace,
                  Text(
                    'الاستحقاق القادم: ${DateFormat.yMMMd('ar').format(debt.nextDueDate!)}',
                    style: AppTextStyle.style12W400.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                  ),
                ],
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المدفوع: ${formatCurrency(debt.paidAmount)} $appCurrencySymbol',
                  style: AppTextStyle.style12W400.copyWith(fontSize: 10.sp),
                ),
                TextButton(
                  onPressed: debt.isFullyPaid
                      ? null
                      : () => _showManualPaymentDialog(context, debt),
                  child: Text(
                    debt.isFullyPaid ? 'اكتمل السداد 🎉' : 'تسجيل دفعة',
                    style: TextStyle(
                      color: debt.isFullyPaid
                          ? AppColors.successColor
                          : AppColors.primaryColor,
                      fontWeight: debt.isFullyPaid
                          ? FontWeight.bold
                          : FontWeight.normal,
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

  Future<void> _showReactivateDialog(
    BuildContext context,
    Debt debt,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إعادة تنشيط الدين'),
        content: Text(
          'سيتم إعادة "${debt.name}" كدين نشط وإلغاء حالة السداد الكامل.\n\nهل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إعادة التنشيط'),
          ),
        ],
      ),
    );

    if ((result ?? false) && context.mounted) {
      await context.read<DebtCubit>().reactivateDebt(debt.id);

      showCustomSnackBar(
        message: 'تم إعادة تنشيط الدين بنجاح',
      );
    }
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
              showCustomSnackBar(message: 'تم مسح الدين بنجاح');
            },
            child: const Text('مسح', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManualPaymentDialog(BuildContext context, Debt debt) {
    final formKey = GlobalKey<FormState>();
    var selectedPaymentDate = DateTime.now();
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
                    'المتبقي من الدين: ${formatCurrency(debt.remainingAmount)} $appCurrencySymbol',
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
                  16.verticalSpace,
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryColor,
                    ),
                    title: const Text('تاريخ الدفع'),
                    subtitle: Text(
                      DateFormat.yMMMd('ar').format(selectedPaymentDate),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedPaymentDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedPaymentDate = picked);
                      }
                    },
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
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.read<DebtCubit>().recordManualPayment(
                      debt: debt,
                      amount: double.parse(amountController.text),
                      walletId: selectedWalletId!,
                      categoryId: debt.categoryId ?? '',
                      paymentDate: selectedPaymentDate,
                      transactionCubit: context.read<TransactionCubit>(),
                      walletCubit: context.read<WalletCubit>(),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('دفع وتسجيل'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddEditDebtDialog(BuildContext context, {Debt? existingDebt}) {
    final isEditing = existingDebt != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: existingDebt?.name);
    final amountController = TextEditingController(
      text: existingDebt != null
          ? existingDebt.totalAmount.truncate().toString()
          : '',
    );

    final installmentController = TextEditingController(
      text: (existingDebt != null && existingDebt.installmentAmount > 0)
          ? existingDebt.installmentAmount.truncate().toString()
          : '',
    );

    var selectedRecurrence = existingDebt?.recurrence ?? DebtRecurrence.once;
    var recurrenceValue = existingDebt?.recurrenceValue;
    DateTime? selectedDate = existingDebt?.dueDate ?? DateTime.now();
    final List<DateTime> customDatesList = existingDebt?.customDates != null
        ? List.from(existingDebt!.customDates!)
        : <DateTime>[];

    var autoDeduct = existingDebt?.autoDeduct ?? false;
    var selectedWalletId = existingDebt?.targetWalletId;

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

    if (isEditing && existingDebt.categoryId != null) {
      try {
        final cat = allExpenseCategories.firstWhere(
          (c) => c.id == existingDebt.categoryId,
        );
        if (cat.parentId != null) {
          selectedMainCategoryId = cat.parentId;
          selectedSubCategoryId = cat.id;
        } else {
          selectedMainCategoryId = cat.id;
        }
      } catch (_) {}
    }

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
                isEditing ? 'تعديل بيانات الدين' : 'إضافة دين أو قسط',
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
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'مطلوب' : null,
                        ),
                        12.verticalSpace,
                        CustomPrimaryTextfield(
                          controller: amountController,
                          text: 'المبلغ الإجمالي للدين',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            final amount = double.tryParse(v);
                            if (amount == null || amount <= 0) {
                              return 'رقم غير صحيح';
                            }

                            if (isEditing &&
                                existingDebt != null &&
                                amount < existingDebt.paidAmount) {
                              return 'المبلغ أقل من المدفوع (${existingDebt.paidAmount})';
                            }
                            return null;
                          },
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
                            if (v != null) {
                              setState(() {
                                selectedRecurrence = v;
                                recurrenceValue = null;
                              });
                            }
                          },
                        ),
                        12.verticalSpace,

                        if (selectedRecurrence != DebtRecurrence.once) ...[
                          CustomPrimaryTextfield(
                            controller: installmentController,
                            text: 'قيمة القسط الواحد',
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'أدخل قيمة القسط'
                                : null,
                          ),
                          12.verticalSpace,
                        ],

                        if (selectedRecurrence == DebtRecurrence.once)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('تاريخ الاستحقاق'),
                            subtitle: Text(
                              selectedDate != null
                                  ? DateFormat.yMMMd('ar').format(selectedDate!)
                                  : '',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate:
                                    (isEditing && existingDebt.dueDate != null)
                                    ? existingDebt.dueDate!
                                    : DateTime.now(),
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
                          ),

                        const Divider(),
                        CustomDropdownButtonFormField<String>(
                          hintText: 'صنف هذا الدين تحت فئة (اختياري):',
                          value: selectedMainCategoryId,
                          items: mainCategories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              selectedMainCategoryId = v;
                              selectedSubCategoryId = null;
                            });
                          },
                          validator: (v) => null,
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
                            if (selectedSubCategoryId != null &&
                                !subCategories.any(
                                  (c) => c.id == selectedSubCategoryId,
                                )) {
                              selectedSubCategoryId = null;
                            }
                            return [
                              12.verticalSpace,
                              CustomDropdownButtonFormField<String>(
                                hintText: 'الفئة الفرعية (اختياري):',
                                value: selectedSubCategoryId,
                                items: subCategories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(
                                          c.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                                    child: Text(
                                      w.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                          backgroundColor: isEditing
                              ? AppColors.primaryColor
                              : AppColors.errorColor,
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

                            var finalCategoryId =
                                selectedSubCategoryId ??
                                selectedMainCategoryId ??
                                '';

                            if (finalCategoryId.isEmpty) {
                              finalCategoryId = const Uuid().v4();
                              final newCategory = TransactionCategory(
                                id: finalCategoryId,
                                name: nameController.text,
                                type: TransactionType.expense,
                                colorValue: AppColors.errorColor.value,
                              );

                              context.read<TransactionCubit>().addCategory(
                                newCategory,
                              );
                            }

                            final newDebt = Debt(
                              id: existingDebt?.id ?? const Uuid().v4(),
                              name: nameController.text,
                              totalAmount: total,
                              paidAmount: existingDebt?.paidAmount ?? 0.0,
                              lastProcessedDate:
                                  existingDebt?.lastProcessedDate,
                              installmentAmount: inst,
                              recurrence: selectedRecurrence,
                              dueDate: selectedRecurrence == DebtRecurrence.once
                                  ? selectedDate
                                  : null,
                              recurrenceValue: recurrenceValue,
                              customDates:
                                  selectedRecurrence == DebtRecurrence.custom
                                  ? customDatesList
                                  : null,
                              autoDeduct: autoDeduct,
                              targetWalletId: selectedWalletId,
                              categoryId: finalCategoryId,
                            );

                            if (isEditing) {
                              context.read<DebtCubit>().updateDebt(newDebt);
                              showCustomSnackBar(
                                message: 'تم تعديل الدين بنجاح!',
                              );
                            } else {
                              context.read<DebtCubit>().addDebt(newDebt);
                              showCustomSnackBar(
                                message: 'تم إضافة الدين بنجاح!',
                              );
                            }

                            Navigator.pop(ctx);
                          }
                        },
                        child: Text(
                          isEditing ? 'حفظ التعديلات' : 'إضافة الدين',
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
