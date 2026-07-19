// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/monthly_plan/presentation/controllers/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_widget.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/calculator_dialog.dart';
import 'package:opration/features/wallets/domain/entities/wallet.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PageHeader(
          isLeading: false,
          heightBar: 130.h,

          bottom: Container(
            height: 50.h,

            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.scaffoldBackgroundLightColor,
                width: 0.5.w,
              ),
              borderRadius: BorderRadius.circular(kRadius),
            ),
            child: TabBar(
              indicatorPadding: EdgeInsets.all(3.r),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(kRadius),
                color: AppColors.scaffoldBackgroundLightColor,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.scaffoldBackgroundLightColor,
              labelStyle: AppTextStyle.style14W600.copyWith(
                fontFamily: kPrimaryFont,
              ),
              unselectedLabelStyle: AppTextStyle.style14W600.copyWith(
                fontFamily: kPrimaryFont,
              ),
              tabs: const [
                Tab(text: 'مصاريف'),
                Tab(text: 'فلوس داخلة'),
              ],
            ),
          ),
          actions: [
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                final pendingCount = state.pendingTransactions.length;

                return SizedBox(
                  width: 45.w,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.bell,
                          color: AppColors.scaffoldBackgroundLightColor,
                          size: 24.r,
                        ),
                        onPressed: () {
                          context.pushNamed(
                            AppRoutes.notificationsScreen,
                          );
                        },
                      ),

                      if (pendingCount > 0)
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: IgnorePointer(
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: const BoxDecoration(
                                color: AppColors.errorColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$pendingCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _TransactionForm(type: TransactionType.expense),
            _TransactionForm(type: TransactionType.income),
          ],
        ),
      ),
    );
  }
}

void _showChangeMainWalletDialog(
  BuildContext context,
  List<Wallet> initialWallets,
  String currentMainWalletId,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      String? selectedWalletId = currentMainWalletId;
      return StatefulBuilder(
        builder: (context, setState) {
          return BlocBuilder<WalletCubit, WalletState>(
            builder: (context, state) {
              final wallets = (state is WalletLoaded)
                  ? state.wallets
                  : initialWallets;

              return AlertDialog(
                title: Text(
                  'تغيير المحفظة الرئيسية',
                  style: AppTextStyle.style16W600.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: wallets.length + 1,
                    itemBuilder: (context, index) {
                      if (index < wallets.length) {
                        final wallet = wallets[index];
                        return RadioListTile<String>(
                          title: Text(wallet.name),
                          subtitle: Text(
                            '${wallet.balance.truncate()} $appCurrencySymbol',
                          ),
                          value: wallet.id,
                          groupValue: selectedWalletId,
                          onChanged: (value) {
                            setState(() {
                              selectedWalletId = value;
                            });
                          },
                        );
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Divider(),
                            ListTile(
                              leading: const Icon(
                                Icons.add_circle_outline,
                                color: AppColors.primaryColor,
                              ),
                              title: Text(
                                'إضافة محفظة جديدة...',
                                style: AppTextStyle.style14W600.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              onTap: () {
                                _showAddEditWalletDialog(context);
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedWalletId != null &&
                          selectedWalletId != currentMainWalletId) {
                        context.read<WalletCubit>().setMainWallet(
                          selectedWalletId!,
                        );
                      }
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

void _showAddEditWalletDialog(BuildContext context, {Wallet? wallet}) {
  final isEditing = wallet != null;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: wallet?.name);
  final balanceController = TextEditingController(
    text: isEditing ? wallet.balance.toString() : '',
  );

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
          isEditing ? 'عدّل المحفظة' : 'ضيف محفظة جديدة',
          style: AppTextStyle.style18W800.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            spacing: 8.h,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPrimaryTextfield(
                controller: nameController,
                text: 'اسم المحفظة',
                validator: (v) =>
                    v == null || v.isEmpty ? 'متنساش تسجل اسم المحفظة' : null,
              ),
              CustomPrimaryTextfield(
                controller: balanceController,
                text: 'رصيد المحفظة',

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (!isEditing &&
                      (v == null || v.isEmpty || double.tryParse(v) == null)) {
                    return 'سجّل مبلغ صح';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'إلغاء',
              style: AppTextStyle.style14W500,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newWallet = Wallet(
                  id: wallet?.id ?? getIt<Uuid>().v4(),
                  name: nameController.text,
                  balance:
                      double.tryParse(balanceController.text) ??
                      wallet!.balance,
                  isMain: wallet?.isMain ?? false,
                );

                if (isEditing) {
                  context.read<WalletCubit>().updateWallet(newWallet);
                } else {
                  context.read<WalletCubit>().addWallet(newWallet);
                }
                Navigator.of(ctx).pop();
              }
            },
            child: Text(
              'حفظ',
              style: AppTextStyle.style14W500.copyWith(
                color: AppColors.scaffoldBackgroundLightColor,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _TransactionForm extends StatefulWidget {
  const _TransactionForm({
    required this.type,
  });

  final TransactionType type;

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedWalletId;
  String? _selectedMainCategoryId;
  String? _selectedSubCategoryId;
  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().checkScheduledTransactions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final finalCategoryId = _selectedSubCategoryId ?? _selectedMainCategoryId;

      if (finalCategoryId == null) {
        showCustomSnackBar(
          message: widget.type == TransactionType.expense
              ? 'متنساش تسجل صرفت على ايه'
              : 'متنساش تسجل الفلوس جاية منين',
        );
        return;
      }

      final walletState = context.read<WalletCubit>().state;
      if (walletState is! WalletLoaded || walletState.wallets.isEmpty) {
        showCustomSnackBar(
          isError: true,
          message: 'لا توجد محافظ. الرجاء إضافة محفظة أولاً.',
        );
        return;
      }

      final mainWallet = walletState.wallets.firstWhere(
        (w) => w.isMain,
        orElse: () => walletState.wallets.first,
      );

      final amount = double.parse(_amountController.text);

      final transaction = Transaction(
        id: getIt<Uuid>().v4(),
        amount: amount,
        categoryId: finalCategoryId,
        date: _selectedDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : '',
        type: widget.type,
        walletId: mainWallet.id,
      );

      context.read<TransactionCubit>().addTransaction(transaction);

      context.read<WalletCubit>().updateWalletBalance(
        mainWallet.id,
        widget.type == TransactionType.income ? amount : -amount,
      );

      playTimerSound();

      _amountController.clear();
      _noteController.clear();
      setState(() {
        _selectedMainCategoryId = null;
        _selectedSubCategoryId = null;
        _selectedDate = DateTime.now();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      barrierColor: Colors.black54,
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.scaffoldBackgroundLightColor,
              onSurface: AppColors.primaryTextColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final excludedCategoryNames = [
          'الرصيد الافتتاحي',
          'تحويل صادر',
          'تحويل وارد',
          // يمكنك إضافة أي مسميات أخرى تستخدمها لعمليات التحويل هنا
        ];

        final allCategories = state.allCategories
            .where(
              (c) =>
                  c.type == widget.type &&
                  !excludedCategoryNames.contains(c.name),
            )
            .toList();

        final mainCategories = allCategories
            .where((c) => c.parentId == null)
            .toList();

        final subCategories = _selectedMainCategoryId != null
            ? allCategories
                  .where((c) => c.parentId == _selectedMainCategoryId)
                  .toList()
            : <TransactionCategory>[];

        final selectedMainCategory = mainCategories
            .where((c) => c.id == _selectedMainCategoryId)
            .firstOrNull;

        final selectedSubCategory = subCategories
            .where((c) => c.id == _selectedSubCategoryId)
            .firstOrNull;

        return BlocBuilder<WalletCubit, WalletState>(
          builder: (context, walletState) {
            final wallets = (walletState is WalletLoaded)
                ? walletState.wallets
                : <Wallet>[];

            if (_selectedWalletId == null && wallets.isNotEmpty) {
              final mainWallet = wallets.firstWhere(
                (w) => w.isMain,
                orElse: () => wallets.first,
              );
              _selectedWalletId = mainWallet.id;
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  spacing: 12.h,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.pendingTransactions.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.orangeColor.withAlpha(55),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.orangeColor,
                            ),
                            8.horizontalSpace,
                            const Expanded(
                              child: Text(
                                'عندك مصاريف دورية النهاردة، سجلتها؟',
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showPendingDialog(
                                context,
                              ),
                              child: const Text('مراجعة الآن'),
                            ),
                          ],
                        ),
                      ),
                    BlocBuilder<WalletCubit, WalletState>(
                      builder: (context, walletState) {
                        var showMainWallet = true;
                        Wallet? mainWallet;

                        if (walletState is WalletLoaded) {
                          showMainWallet = walletState.showMainWallet;
                          if (walletState.wallets.isNotEmpty) {
                            mainWallet = walletState.wallets.firstWhere(
                              (w) => w.isMain,
                              orElse: () => walletState.wallets.first,
                            );
                          }
                        }

                        if (walletState is WalletLoaded && mainWallet != null) {
                          return InkWell(
                            onTap: () {
                              _showChangeMainWalletDialog(
                                context,
                                walletState.wallets,
                                mainWallet!.id,
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withAlpha(24),
                                border: Border.all(
                                  color: AppColors.primaryColor.withAlpha(36),
                                ),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  16.horizontalSpace,

                                  SvgImage(
                                    imagePath:
                                        'assets/image/svg/change_wallet.svg',
                                    height: 18.r,
                                    color: AppColors.primaryColor,
                                  ),
                                  const Spacer(),

                                  ImageFiltered(
                                    imageFilter: ui.ImageFilter.blur(
                                      sigmaX: showMainWallet ? 0 : 4.0,
                                      sigmaY: showMainWallet ? 0 : 4.0,
                                    ),
                                    child: Text.rich(
                                      showMainWallet
                                          ? TextSpan(
                                              text: '${mainWallet.name}: ',
                                              style: AppTextStyle.style12W300
                                                  .copyWith(
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${mainWallet.balance.truncate()} $appCurrencySymbol',
                                                  style: AppTextStyle
                                                      .style16W700
                                                      .copyWith(
                                                        color: AppColors
                                                            .primaryColor,
                                                      ),
                                                ),
                                              ],
                                            )
                                          : TextSpan(
                                              text:
                                                  '${mainWallet.name}: ***** $appCurrencySymbol',
                                              style: AppTextStyle.style16W700
                                                  .copyWith(
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                            ),
                                      style: AppTextStyle.style14W500.copyWith(
                                        color: AppColors.primaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      showMainWallet
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,

                                      color: AppColors.primaryColor,
                                      size: 20.r,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<WalletCubit>()
                                          .toggleShowMainWalletPref();
                                    },
                                    tooltip: 'إخفاء المحفظة',
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),

                    Text(
                      widget.type == TransactionType.income
                          ? 'معاك كام؟'
                          : 'صرفت كام؟',
                      style: AppTextStyle.style14W400.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    CustomPrimaryTextfield(
                      height: 12,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.style20W600.copyWith(
                        color: AppColors.primaryColor,
                      ),
                      prefix: IconButton(
                        icon: Icon(
                          Icons.calendar_month_outlined,
                          size: 22.r,
                          color: AppColors.primaryColor,
                        ),
                        onPressed: () => _selectDate(context),
                      ),
                      suffix: IconButton(
                        onPressed: () async {
                          final result = await showDialog<double>(
                            context: context,
                            builder: (_) => CalculatorDialog(
                              initialValue:
                                  double.tryParse(_amountController.text) ?? 0,
                            ),
                          );
                          if (result != null) {
                            _amountController.text = result
                                .truncate()
                                .toString();
                          }
                        },
                        icon: Icon(
                          Icons.calculate_outlined,
                          size: 22.r,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      text: 'المبلغ',
                      validator: (value) =>
                          value == null || value.isEmpty ? 'سجل المبلغ' : null,
                    ),
                    4.verticalSpace,

                    _buildCategorySelectionField(
                      hint: widget.type == TransactionType.income
                          ? 'الفلوس دي جاية منين (اختار الفئة الرئيسية)؟'
                          : 'صرفت على ايه (اختار الفئة الرئيسية)؟',
                      selectedCategory: selectedMainCategory,
                      onTap: () => _showCategorySelectionSheet(
                        context: context,
                        categories: mainCategories,
                        isMainCategory: true,
                      ),
                    ),

                    if (_selectedMainCategoryId != null) ...[
                      _buildCategorySelectionField(
                        hint: subCategories.isEmpty
                            ? 'لا توجد تفريعات، اضغط لإضافة واحدة'
                            : 'اختر فئة الفرعية',
                        selectedCategory: selectedSubCategory,
                        onTap: () => _showCategorySelectionSheet(
                          context: context,
                          categories: subCategories,
                          isMainCategory: false,
                        ),
                      ),
                    ],

                    Text(
                      'ملاحظات (اختياري)',
                      style: AppTextStyle.style14W400.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    CustomPrimaryTextfield(
                      controller: _noteController,
                      text: 'ملاحظات',
                    ),

                    10.verticalSpace,
                    CustomPrimaryButton(
                      onPressed: _submit,
                      width: SizeConfig.screenWidth,
                      text: 'إضافة',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategorySelectionField({
    required String hint,
    required TransactionCategory? selectedCategory,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor.withAlpha(36)),
          borderRadius: BorderRadius.circular(10.r),
          color:
              selectedCategory?.color.withAlpha(15) ??
              AppColors.primaryColor.withAlpha(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (selectedCategory != null) ...[
                  CircleAvatar(
                    backgroundColor: selectedCategory.color,
                    radius: 12.r,
                  ),
                  12.horizontalSpace,
                ],
                Text(
                  selectedCategory?.name ?? hint,
                  style: selectedCategory != null
                      ? AppTextStyle.style14W600.copyWith(
                          color: selectedCategory.color,
                        )
                      : AppTextStyle.style12W400.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySelectionSheet({
    required BuildContext context,
    required List<TransactionCategory> categories,
    required bool isMainCategory,
  }) {
    final transactionCubit = context.read<TransactionCubit>();
    final planCubit = context.read<MonthlyPlanCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.6,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    isMainCategory ? 'اختر فئة الرئيسية' : 'اختر الفئة الفرعية',
                    style: AppTextStyle.style18W600,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: categories.isEmpty
                      ? Center(
                          child: Text(
                            'مفيش فئات مسجلة هنا',
                            style: AppTextStyle.style14W400.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: EdgeInsets.all(16.r),
                          itemCount: categories.length,
                          separatorBuilder: (_, _) => 8.verticalSpace,
                          itemBuilder: (ctx, index) {
                            final category = categories[index];

                            final plan = planCubit.state.plan;
                            final allTxs =
                                transactionCubit.state.allTransactions;
                            final allCategories =
                                transactionCubit.state.allCategories;
                            final now = DateTime.now();

                            var budgeted = 0.0;
                            var spent = 0.0;

                            final subCategories = allCategories
                                .where((c) => c.parentId == category.id)
                                .toList();

                            final relevantIds = [
                              category.id,
                              ...subCategories.map((c) => c.id),
                            ];

                            final relevantNames = [
                              category.name,
                              ...subCategories.map((c) => c.name),
                            ];

                            if (widget.type == TransactionType.expense) {
                              for (final id in relevantIds) {
                                budgeted +=
                                    plan
                                        ?.getExpenseForCategory(id)
                                        ?.budgetedAmount ??
                                    0.0;
                              }

                              spent = allTxs
                                  .where(
                                    (t) =>
                                        relevantIds.contains(t.categoryId) &&
                                        t.type == TransactionType.expense &&
                                        t.date.month == now.month,
                                  )
                                  .fold(0.0, (s, t) => s + t.amount);
                            } else {
                              for (final name in relevantNames) {
                                budgeted +=
                                    plan?.incomes
                                        .where((i) => i.name == name)
                                        .fold(0.0, (s, i) => s! + (i.amount)) ??
                                    0.0;
                              }
                              spent = allTxs
                                  .where(
                                    (t) =>
                                        relevantIds.contains(t.categoryId) &&
                                        t.type == TransactionType.income &&
                                        t.date.month == now.month,
                                  )
                                  .fold(0.0, (s, t) => s + t.amount);
                            }

                            final remaining = budgeted - spent;

                            return ListTile(
                              tileColor: category.color.withAlpha(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                side: BorderSide(
                                  color: category.color.withAlpha(50),
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: category.color,
                                child: Icon(
                                  widget.type == TransactionType.income
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: Colors.white,
                                  size: 16.r,
                                ),
                              ),
                              title: Text(
                                category.name,
                                style: AppTextStyle.style14W600,
                                overflow: TextOverflow.fade,
                              ),
                              trailing: budgeted > 0
                                  ? Text(
                                      widget.type == TransactionType.expense
                                          ? 'صرفت ${spent.truncate()} وباقي ${remaining.truncate()} $appCurrencySymbol'
                                          : 'مخطط ${budgeted.truncate()} $appCurrencySymbol | فعلي: ${spent.truncate()} $appCurrencySymbol',
                                      style: AppTextStyle.style9W400.copyWith(
                                        color: category.color,
                                      ),
                                    )
                                  : Text(
                                      spent > 0
                                          ? 'صرفت ${spent.truncate()} $appCurrencySymbol'
                                          : '',
                                      style: AppTextStyle.style9W400.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                              onTap: () {
                                Navigator.pop(sheetContext);

                                setState(() {
                                  if (isMainCategory) {
                                    _selectedMainCategoryId = category.id;
                                    _selectedSubCategoryId = null;
                                  } else {
                                    _selectedSubCategoryId = category.id;
                                  }
                                });
                              },
                            );
                          },
                        ),
                ),

                ColoredBox(
                  color: AppColors.primaryColor.withAlpha(25),
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 16.w,
                      left: 16.w,
                      bottom: 8.h,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primaryTextColor,
                      ),
                      title: Text(
                        isMainCategory
                            ? 'إضافة فئة رئيسية جديدة'
                            : 'إضافة فئة فرعية جديدة',
                        style: AppTextStyle.style14W600.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (isMainCategory) {
                          _showAddCategoryModalBottomSheet(
                            context,
                            widget.type,
                          );
                        } else {
                          _addNewSubCategoryForSelectedMain();
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addNewSubCategoryForSelectedMain() {
    if (_selectedMainCategoryId == null) return;

    final allCategories = context.read<TransactionCubit>().state.allCategories;
    final mainCategory = allCategories.firstWhere(
      (c) => c.id == _selectedMainCategoryId,
    );

    final dummySubCategory = TransactionCategory(
      id: '',
      name: '',
      colorValue: mainCategory.colorValue,
      type: mainCategory.type,
      parentId: mainCategory.id,
    );

    showModalBottomSheet<TransactionCategory>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (_) => AddCategoryWidget(
        type: mainCategory.type,
        categoryToEdit: dummySubCategory,
      ),
    ).then((result) {
      if (result != null) {
        final newSubCategory = result.copyWith(id: const Uuid().v4());
        context.read<TransactionCubit>().addCategory(newSubCategory);

        setState(() {
          _selectedSubCategoryId = newSubCategory.id;
        });
      }
    });
  }

  void _showPendingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (ctx) {
        return BlocConsumer<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state.pendingTransactions.isEmpty) {
              if (context.canPop()) context.pop();
            }
          },
          builder: (context, state) {
            final pendingCategories = state.pendingTransactions;

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(
                    Icons.pending_actions,
                    color: AppColors.orangeColor,
                  ),
                  8.horizontalSpace,
                  const Text('عمليات بانتظار تأكيدك'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: pendingCategories.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final category = pendingCategories[index];
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: category.color,
                                  radius: 15.r,
                                ),
                                10.horizontalSpace,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: AppTextStyle.style16Bold,
                                      ),
                                      4.verticalSpace,
                                      Text(
                                        'المبلغ المتوقع: ${category.fixedAmount?.truncate() ?? 0} $appCurrencySymbol',
                                        style: AppTextStyle.style12W300
                                            .copyWith(fontSize: 10.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            8.verticalSpace,

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_note,
                                    color: AppColors.primaryColor,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showEditPendingTransactionSheet(
                                      context,
                                      category,
                                      category.targetWalletId!,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.errorColor,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<TransactionCubit>()
                                        .dismissPendingTransaction(category);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: AppColors.successColor,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<TransactionCubit>()
                                        .approvePendingTransaction(category);

                                    showCustomSnackBar(
                                      message:
                                          'تم تسجيل ${category.name} بنجاح',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('راجع لاحقاً'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void _showEditPendingTransactionSheet(
  BuildContext context,
  TransactionCategory category,
  String walletId,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      return _EditPendingForm(
        category: category,
        walletId: walletId,
      );
    },
  );
}

void _showAddCategoryModalBottomSheet(
  BuildContext context,
  TransactionType type,
) {
  showModalBottomSheet<TransactionCategory>(
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    context: context,
    builder: (_) => AddCategoryWidget(type: type),
  ).then((newCategory) {
    if (newCategory != null) {
      context.read<TransactionCubit>().addCategory(newCategory);
    }
  });
}

class _EditPendingForm extends StatefulWidget {
  const _EditPendingForm({
    required this.category,
    required this.walletId,
  });
  final TransactionCategory category;
  final String walletId;

  @override
  State<_EditPendingForm> createState() => _EditPendingFormState();
}

class _EditPendingFormState extends State<_EditPendingForm> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.category.fixedAmount?.truncate().toString() ?? '0',
    );
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.category.color,
                radius: 15.r,
              ),
              10.horizontalSpace,
              Text(
                'تأكيد وتعديل: ${widget.category.name}',
                style: AppTextStyle.style16W600,
              ),
            ],
          ),
          20.verticalSpace,

          Row(
            children: [
              Expanded(
                child: CustomPrimaryTextfield(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  text: 'المبلغ الفعلي',
                ),
              ),
              10.horizontalSpace,
              IconButton(
                onPressed: () async {
                  final result = await showDialog<double>(
                    context: context,
                    builder: (_) => CalculatorDialog(
                      initialValue:
                          double.tryParse(_amountController.text) ?? 0,
                    ),
                  );
                  if (result != null) {
                    _amountController.text = result.truncate().toString();
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

          15.verticalSpace,

          CustomPrimaryTextfield(
            controller: _noteController,
            text: 'ملاحظات (اختياري)',
          ),
          15.verticalSpace,

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'تاريخ المعاملة: ${DateFormat('yyyy/MM/dd').format(_selectedDate)}',
              style: AppTextStyle.style14W500,
            ),
            trailing: Icon(
              Icons.calendar_today,
              color: AppColors.primaryColor,
              size: 20.r,
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
          20.verticalSpace,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0.0;

                if (amount <= 0) {
                  return;
                }

                context
                    .read<TransactionCubit>()
                    .approvePendingWithCustomDetails(
                      category: widget.category,
                      amount: amount,
                      date: _selectedDate,
                      walletId: widget.walletId,
                      note: _noteController.text.isEmpty
                          ? null
                          : _noteController.text,
                    );

                Navigator.pop(context);
              },
              child: const Text(
                'حفظ وتأكيد المعاملة',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          20.verticalSpace,
        ],
      ),
    );
  }
}

void playTimerSound() {
  final player = AudioPlayer();
  const sound = appSound;
  player.play(AssetSource(sound));
}
