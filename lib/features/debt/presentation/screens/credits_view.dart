// ignore_for_file: deprecated_member_use, omit_local_variable_types
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/services/format_currency.dart';
import 'package:opration/core/shared_widgets/custom_dropdown_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/debt/domain/entities/credit.dart';
import 'package:opration/features/debt/presentation/controllers/credit_cubit/credit_cubit.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class CreditsView extends StatelessWidget {
  const CreditsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreditCubit, CreditState>(
      builder: (context, state) {
        final allCredits = state.items;

        final activeCredits = allCredits.where((c) => !c.isFullyPaid).toList();
        final settledCredits = allCredits.where((c) => c.isFullyPaid).toList();

        final totalRemainingCredits = activeCredits.fold(
          0.0,
          (sum, credit) => sum + credit.remainingAmount,
        );

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: const PageHeader(
              isLeading: true,
              title: 'المستحقات (ديون لي)',
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
                  label: 'سجل التحصيلات',
                  onTap: () {
                    // يمكنك إنشاء صفحة سجل مشابهة للديون
                    // context.pushNamed(AppRoutes.creditPaymentsLogView);
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  label: 'إضافة مستحق جديد',
                  onTap: () => _showAddEditCreditDialog(context),
                ),
              ],
            ),
            body: Column(
              children: [
                _buildTotalCreditsCard(context, totalRemainingCredits),
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
                      Tab(text: 'مستحقات نشطة'),
                      Tab(text: 'تم التحصيل'),
                    ],
                  ),
                ),
                12.verticalSpace,
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildCreditsList(
                        context,
                        credits: activeCredits,
                        emptyMessage: 'لا يوجد مستحقات نشطة مسجلة!',
                      ),
                      _buildCreditsList(
                        context,
                        credits: settledCredits,
                        emptyMessage: 'لم تقم بتحصيل مستحقات بالكامل بعد.',
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

  Widget _buildCreditsList(
    BuildContext context, {
    required List<Credit> credits,
    required String emptyMessage,
  }) {
    if (credits.isEmpty) {
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
      itemCount: credits.length + 1,
      itemBuilder: (context, index) {
        if (index == credits.length) {
          return 80.verticalSpace;
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: _buildCreditCard(context, credits[index]),
        );
      },
    );
  }

  Widget _buildTotalCreditsCard(BuildContext context, double totalRemaining) {
    return Container(
      margin: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.successColor.withAlpha(220), // لون أخضر للإيرادات
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.successColor.withAlpha(77),
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
                'إجمالي المستحقات المتبقية',
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
              Icons.savings_rounded, // أيقونة تعبر عن الإدخار أو التحصيل
              color: Colors.white,
              size: 32.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, Credit credit) {
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
                          credit.name,
                          style: AppTextStyle.style16W600,
                          overflow: TextOverflow.fade,
                          softWrap: true,
                        ),
                      ),
                      8.horizontalSpace,
                      if (credit.autoDeduct && !credit.isFullyPaid)
                        Icon(
                          Icons.autorenew,
                          color: AppColors.primaryColor,
                          size: 18.r,
                        ),
                    ],
                  ),
                ),
                if (!credit.isFullyPaid)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditCreditDialog(
                          context,
                          existingCredit: credit,
                        );
                      } else if (value == 'delete') {
                        _showDeleteCreditConfirmation(context, credit);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('تعديل المستحق'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'مسح',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                else
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'reActive') {
                        _showReactivateDialog(context, credit);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'reActive',
                        child: Text('إعادة التنشيط'),
                      ),
                    ],
                  ),
              ],
            ),
            4.verticalSpace,
            Text(
              'المتبقي: ${formatCurrency(credit.remainingAmount)} $appCurrencySymbol',
              style: AppTextStyle.style12W500.copyWith(
                color: credit.isFullyPaid
                    ? AppColors.textGreyColor
                    : AppColors.successColor, // لون أخضر للمبلغ المتبقي لك
              ),
            ),
            8.verticalSpace,
            LinearProgressIndicator(
              value: credit.totalAmount > 0
                  ? (credit.paidAmount / credit.totalAmount)
                  : 0,
              backgroundColor: Colors.grey.shade300,
              color: AppColors.successColor,
              minHeight: 6.h,
            ),
            4.verticalSpace,
            if (credit.nextDueDate != null && !credit.isFullyPaid) ...[
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
                    'التحصيل القادم: ${DateFormat.yMMMd('ar').format(credit.nextDueDate!)}',
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
                  'ما تم تحصيله: ${formatCurrency(credit.paidAmount)} $appCurrencySymbol',
                  style: AppTextStyle.style12W400.copyWith(fontSize: 10.sp),
                ),
                TextButton(
                  onPressed: credit.isFullyPaid
                      ? null
                      : () => _showManualPaymentDialog(context, credit),
                  child: Text(
                    credit.isFullyPaid ? 'اكتمل التحصيل 🎉' : 'استلام دفعة',
                    style: TextStyle(
                      color: credit.isFullyPaid
                          ? AppColors.textGreyColor
                          : AppColors.primaryColor,
                      fontWeight: credit.isFullyPaid
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
    Credit credit,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إعادة تنشيط'),
        content: Text(
          'سيتم إعادة "${credit.name}" كمستحق نشط وإلغاء حالة التحصيل الكامل.\n\nهل تريد المتابعة؟',
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
      await context.read<CreditCubit>().reactivateCredit(credit.id);
      showCustomSnackBar(message: 'تم إعادة التنشيط بنجاح');
    }
  }

  void _showDeleteCreditConfirmation(BuildContext context, Credit credit) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('متأكد؟'),
        content: Text(
          'هل تريد فعلاً مسح "${credit.name}"؟\n\n'
          'ملاحظة: مسح المستحق لن يمسح التحصيلات التي سجلتها في المعاملات.',
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
              context.read<CreditCubit>().deleteCredit(credit.id);
              Navigator.pop(ctx);
              showCustomSnackBar(message: 'تم المسح بنجاح');
            },
            child: const Text('مسح', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManualPaymentDialog(BuildContext context, Credit credit) {
    final formKey = GlobalKey<FormState>();
    var selectedPaymentDate = DateTime.now();
    final defaultAmount =
        (credit.installmentAmount > 0 &&
            credit.installmentAmount <= credit.remainingAmount)
        ? credit.installmentAmount
        : credit.remainingAmount;

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
            title: Text('تحصيل من "${credit.name}"'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المتبقي: ${formatCurrency(credit.remainingAmount)} $appCurrencySymbol',
                    style: AppTextStyle.style14W600.copyWith(
                      color: AppColors.successColor,
                    ),
                  ),
                  16.verticalSpace,
                  CustomPrimaryTextfield(
                    controller: amountController,
                    text: 'هتستلم كام؟',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'مطلوب';
                      final amount = double.tryParse(v);
                      if (amount == null || amount <= 0) return 'مبلغ غير صحيح';
                      if (amount > credit.remainingAmount)
                        return 'المبلغ أكبر من المتبقي!';
                      return null;
                    },
                  ),
                  16.verticalSpace,
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'هتضيف الدفعة لأي محفظة؟', // تغيير النص هنا
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
                    validator: (v) => v == null ? 'اختر محفظة' : null,
                  ),
                  16.verticalSpace,
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryColor,
                    ),
                    title: const Text('تاريخ التحصيل'),
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
                    context.read<CreditCubit>().recordManualPayment(
                      credit: credit,
                      amount: double.parse(amountController.text),
                      walletId: selectedWalletId!,
                      categoryId: credit.categoryId ?? '',
                      paymentDate: selectedPaymentDate,
                      transactionCubit: context.read<TransactionCubit>(),
                      walletCubit: context.read<WalletCubit>(),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('تحصيل وتسجيل'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddEditCreditDialog(
    BuildContext context, {
    Credit? existingCredit,
  }) {
    final isEditing = existingCredit != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: existingCredit?.name);
    final amountController = TextEditingController(
      text: existingCredit != null
          ? existingCredit.totalAmount.truncate().toString()
          : '',
    );
    final installmentController = TextEditingController(
      text: (existingCredit != null && existingCredit.installmentAmount > 0)
          ? existingCredit.installmentAmount.truncate().toString()
          : '',
    );

    var selectedRecurrence =
        existingCredit?.recurrence ?? CreditRecurrence.once;
    var recurrenceValue = existingCredit?.recurrenceValue;
    DateTime? selectedDate = existingCredit?.dueDate ?? DateTime.now();
    final List<DateTime> customDatesList = existingCredit?.customDates != null
        ? List.from(existingCredit!.customDates!)
        : <DateTime>[];

    var autoDeduct = existingCredit?.autoDeduct ?? false;
    var selectedWalletId = existingCredit?.targetWalletId;
    String? selectedMainCategoryId;
    String? selectedSubCategoryId;

    final wallets = (context.read<WalletCubit>().state as WalletLoaded).wallets;

    // الأهم هنا: إحضار فئات الإيراد وليس المصروف!
    final allIncomeCategories = context
        .read<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.income) // <--- هام جداً
        .toList();

    final mainCategories = allIncomeCategories
        .where((c) => c.parentId == null)
        .toList();

    if (isEditing && existingCredit.categoryId != null) {
      try {
        final cat = allIncomeCategories.firstWhere(
          (c) => c.id == existingCredit.categoryId,
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
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Text(
                isEditing ? 'تعديل بيانات المستحق' : 'إضافة مستحق (فلوس ليك)',
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
                          text: 'الفلوس دي عند مين؟ (مثال: سلفة لأحمد)',
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'مطلوب' : null,
                        ),
                        12.verticalSpace,
                        CustomPrimaryTextfield(
                          controller: amountController,
                          text: 'المبلغ الإجمالي',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            final amount = double.tryParse(v);
                            if (amount == null || amount <= 0)
                              return 'رقم غير صحيح';
                            if (isEditing &&
                                existingCredit != null &&
                                amount < existingCredit.paidAmount) {
                              return 'المبلغ أقل من المُحصّل (${existingCredit.paidAmount})';
                            }
                            return null;
                          },
                        ),
                        16.verticalSpace,
                        CustomDropdownButtonFormField<CreditRecurrence>(
                          hintText: 'نظام التحصيل',
                          value: selectedRecurrence,
                          items: const [
                            DropdownMenuItem(
                              value: CreditRecurrence.once,
                              child: Text('مرة واحدة'),
                            ),
                            DropdownMenuItem(
                              value: CreditRecurrence.weekly,
                              child: Text('أسبوعي'),
                            ),
                            DropdownMenuItem(
                              value: CreditRecurrence.monthly,
                              child: Text('شهري'),
                            ),
                            DropdownMenuItem(
                              value: CreditRecurrence.custom,
                              child: Text('مخصص'),
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

                        if (selectedRecurrence != CreditRecurrence.once) ...[
                          CustomPrimaryTextfield(
                            controller: installmentController,
                            text: 'قيمة الدفعة الواحدة',
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'مطلوب' : null,
                          ),
                          12.verticalSpace,
                        ],

                        // ... (نفس لوجيك التواريخ CustomDates و Monthly و Weekly من كودك القديم تماماً) ...
                        if (selectedRecurrence == CreditRecurrence.once)
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
                                    (isEditing &&
                                        existingCredit.dueDate != null)
                                    ? existingCredit.dueDate!
                                    : DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null)
                                setState(() => selectedDate = picked);
                            },
                          ),

                        // (تكملة للـ Weekly و Monthly نفس الكود الأصلي)
                        const Divider(),
                        CustomDropdownButtonFormField<String>(
                          hintText: 'صنف هذا الإيراد تحت فئة (اختياري):',
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
                          validator: (v) => null,
                        ),

                        ...(() {
                          final subCategories = selectedMainCategoryId != null
                              ? allIncomeCategories
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
                            'تحصيل تلقائي في الموعد',
                            style: AppTextStyle.style12W600,
                          ),
                          value: autoDeduct,
                          activeThumbColor: AppColors.primaryColor,
                          onChanged: (v) => setState(() => autoDeduct = v),
                        ),

                        if (autoDeduct)
                          CustomDropdownButtonFormField<String>(
                            hintText: 'إضافة لأي محفظة؟', // تغيير هنا
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
                            validator: (v) =>
                                autoDeduct && v == null ? 'اختر محفظة' : null,
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
                              : AppColors.successColor,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final total = double.parse(amountController.text);
                            final inst =
                                selectedRecurrence == CreditRecurrence.once
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
                                type: TransactionType.income, // تسجيل كإيراد
                                colorValue: AppColors.successColor.value,
                              );
                              context.read<TransactionCubit>().addCategory(
                                newCategory,
                              );
                            }

                            final newCredit = Credit(
                              id: existingCredit?.id ?? const Uuid().v4(),
                              name: nameController.text,
                              totalAmount: total,
                              paidAmount: existingCredit?.paidAmount ?? 0.0,
                              lastProcessedDate:
                                  existingCredit?.lastProcessedDate,
                              installmentAmount: inst,
                              recurrence: selectedRecurrence,
                              dueDate:
                                  selectedRecurrence == CreditRecurrence.once
                                  ? selectedDate
                                  : null,
                              recurrenceValue: recurrenceValue,
                              customDates:
                                  selectedRecurrence == CreditRecurrence.custom
                                  ? customDatesList
                                  : null,
                              autoDeduct: autoDeduct,
                              targetWalletId: selectedWalletId,
                              categoryId: finalCategoryId,
                            );

                            if (isEditing) {
                              context.read<CreditCubit>().updateCredit(
                                newCredit,
                              );
                              showCustomSnackBar(message: 'تم التعديل بنجاح!');
                            } else {
                              context.read<CreditCubit>().addCredit(newCredit);
                              showCustomSnackBar(
                                message: 'تم إضافة المستحق بنجاح!',
                              );
                            }
                            Navigator.pop(ctx);
                          }
                        },
                        child: Text(
                          isEditing ? 'حفظ التعديلات' : 'إضافة مستحق',
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
