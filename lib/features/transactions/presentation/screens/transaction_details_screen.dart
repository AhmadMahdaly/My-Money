// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/domain/entities/wallet.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PageHeader(
          isLeading: false,
          heightBar: 180.h,
          title: 'مصاريفك وفلوسك',

          subTitle: BlocBuilder<WalletCubit, WalletState>(
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
                return Container(
                  alignment: Alignment.center,
                  color: Colors.white.withAlpha(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: SvgImage(
                          imagePath: 'assets/image/svg/change_wallet.svg',
                          height: 18.r,
                          color: AppColors.cardColor,
                        ),

                        onPressed: () {
                          _showChangeMainWalletDialog(
                            context,
                            walletState.wallets,
                            mainWallet!.id,
                          );
                        },
                        tooltip: 'تغيير المحفظة الرئيسية',
                      ),

                      ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: showMainWallet ? 0 : 4.0,
                          sigmaY: showMainWallet ? 0 : 4.0,
                        ),
                        child: Text(
                          showMainWallet
                              ? 'محفظتك: ${mainWallet.name} (${mainWallet.balance.truncate()} ج.م)'
                              : 'محفظتك: ${mainWallet.name} (****** ج.م)',
                          style: AppTextStyles.style14W500.copyWith(
                            color: Colors.white,
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

                          color: AppColors.cardColor,
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
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
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
              labelStyle: AppTextStyles.style14W600.copyWith(
                fontFamily: kPrimaryFont,
              ),
              unselectedLabelStyle: AppTextStyles.style14W600.copyWith(
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
                          Icons.notifications_outlined,
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
        body: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            if (state.isLoading && state.allTransactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                4.verticalSpace,
                _FilterControlBar(),
                // 4.verticalSpace,
                if (state.isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.r),
                    child: const LinearProgressIndicator(),
                  )
                else
                  Expanded(
                    child: TabBarView(
                      children: [
                        _TransactionDetailsPage(
                          type: TransactionType.expense,
                          state: state,
                        ),
                        _TransactionDetailsPage(
                          type: TransactionType.income,
                          state: state,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TransactionDetailsPage extends StatelessWidget {
  const _TransactionDetailsPage({
    required this.type,
    required this.state,
  });

  final TransactionType type;
  final TransactionState state;

  @override
  Widget build(BuildContext context) {
    final transactionsForType = state.filteredTransactions
        .where((t) => t.type == type)
        .toList();
    final totalAmount = transactionsForType.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    if (transactionsForType.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32.r),
        child: Center(
          child: Text(
            'مفيش ${type == TransactionType.expense ? 'مصروفات' : 'فلوس داخلة'} الفترة دي',
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        _SingleSummaryCard(
          title: type == TransactionType.income ? 'فلوسك' : 'مصاريفك',
          totalAmount: totalAmount,
          type: type,
        ),
        4.verticalSpace,

        _CategoryTransactionList(
          transactions: transactionsForType,
          categories: state.allCategories,
          type: type,
        ),
        if (type == TransactionType.expense) ...[
          16.verticalSpace,
          _PieChartCard(
            transactions: transactionsForType,
            categories: state.allCategories,
            totalExpense: totalAmount,
          ),
        ],
      ],
    );
  }
}

class _CategoryTransactionList extends StatelessWidget {
  const _CategoryTransactionList({
    required this.transactions,
    required this.categories,
    required this.type,
  });

  final TransactionType type;
  final List<Transaction> transactions;
  final List<TransactionCategory> categories;

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = <String, List<Transaction>>{};
    for (final transaction in transactions) {
      final category = categories.firstWhere(
        (c) => c.id == transaction.categoryId,
        orElse: () => TransactionCategory(
          id: '',
          name: 'في المجهول',
          colorValue: 0,
          type: type,
        ),
      );

      final mainCategoryId = category.parentId ?? category.id;
      (groupedTransactions[mainCategoryId] ??= []).add(transaction);
    }

    final sortedMainCategoryIds = groupedTransactions.keys.toList()
      ..sort((a, b) {
        final totalA = groupedTransactions[a]!.fold(
          0.0,
          (sum, item) => sum + item.amount,
        );
        final totalB = groupedTransactions[b]!.fold(
          0.0,
          (sum, item) => sum + item.amount,
        );
        return totalB.compareTo(totalA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            type == TransactionType.income
                ? 'فلوسك جت منين؟'
                : 'فلوسك راحت فين؟',
            style: AppTextStyles.style18W600.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedMainCategoryIds.length,
          separatorBuilder: (context, index) => 8.verticalSpace,
          itemBuilder: (context, index) {
            final mainCategoryId = sortedMainCategoryIds[index];
            final categoryTransactions = groupedTransactions[mainCategoryId]!;
            final categoryTotal = categoryTransactions.fold(
              0.0,
              (sum, item) => sum + item.amount,
            );

            final mainCategory = categories.firstWhere(
              (c) => c.id == mainCategoryId,
              orElse: () => TransactionCategory(
                id: '',
                name: 'في المجهول',
                colorValue: Colors.grey.value,
                type: type,
              ),
            );

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadius),
              ),
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.only(bottom: 10.h),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: mainCategory.color,
                    radius: 18.r,
                    child: Icon(
                      type == TransactionType.income
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: Colors.white,
                      size: 16.r,
                    ),
                  ),
                  title: Text(
                    mainCategory.name,
                    style: AppTextStyles.style14W600,
                  ),
                  trailing: Text(
                    '${categoryTotal.truncate()} ج.م',
                    style: AppTextStyles.style14W700.copyWith(
                      color: type == TransactionType.income
                          ? AppColors.greenLightColor
                          : AppColors.errorColor,
                    ),
                  ),
                  children: categoryTransactions.map((transaction) {
                    return _TransactionListItem(
                      transaction: transaction,
                      allCategories: categories,
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

void _showChangeMainWalletDialog(
  BuildContext context,
  List<Wallet> initialWallets, // تم تغيير الاسم لتجنب التعارض
  String currentMainWalletId,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      String? selectedWalletId = currentMainWalletId;
      return StatefulBuilder(
        builder: (context, setState) {
          // استخدمنا BlocBuilder هنا لكي تظهر المحفظة الجديدة فور إضافتها
          return BlocBuilder<WalletCubit, WalletState>(
            builder: (context, state) {
              final wallets = (state is WalletLoaded)
                  ? state.wallets
                  : initialWallets;

              return AlertDialog(
                title: Text(
                  'تغيير المحفظة الرئيسية',
                  style: AppTextStyles.style16W600.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: wallets.length + 1, // +1 لزر الإضافة
                    itemBuilder: (context, index) {
                      // 1. عرض المحافظ الحالية
                      if (index < wallets.length) {
                        final wallet = wallets[index];
                        return RadioListTile<String>(
                          title: Text(wallet.name),
                          subtitle: Text('${wallet.balance.truncate()} ج.م'),
                          value: wallet.id,
                          groupValue: selectedWalletId,
                          onChanged: (value) {
                            setState(() {
                              selectedWalletId = value;
                            });
                          },
                        );
                      }
                      // 2. زر إضافة محفظة جديدة في النهاية
                      else {
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
                                style: AppTextStyles.style14W600.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              onTap: () {
                                // الخيار الأول: إغلاق الديالوج والذهاب لشاشة المحافظ
                                // Navigator.pop(ctx);
                                // context.push(AppRoutes.walletsScreen);

                                // الخيار الثاني: فتح ديالوج صغير لإضافة المحفظة مباشرة (وهو الأفضل)
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
          style: AppTextStyles.style18W800.copyWith(
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
              style: AppTextStyles.style14W500,
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
              style: AppTextStyles.style14W500.copyWith(
                color: AppColors.scaffoldBackgroundLightColor,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _TransactionListItem extends StatelessWidget {
  const _TransactionListItem({
    required this.transaction,
    required this.allCategories,
  });

  final Transaction transaction;
  final List<TransactionCategory> allCategories;

  void _handleMenuSelection(BuildContext context, String value) {
    if (value == 'edit') {
      context.push(AppRoutes.editTransactionScreen, extra: transaction);
    } else if (value == 'delete') {
      _showDeleteConfirmation(context);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('متأكد؟'),
        content: const Text('أنت كدا هتمسح العملية دي كلها'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            child: Text(
              'مسح',
              style: AppTextStyles.style12W700.copyWith(
                color: AppColors.errorColor,
              ),
            ),
            onPressed: () {
              context.read<TransactionCubit>().deleteTransaction(
                transaction.id,
              );
              ctx.pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    final specificCategory = allCategories.firstWhere(
      (c) => c.id == transaction.categoryId,
      orElse: () => TransactionCategory(
        id: '',
        name: 'غير معروف',
        colorValue: Colors.grey.value,
        type: transaction.type,
      ),
    );

    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.subdirectory_arrow_left,
            size: 16.r,
            color: color,
          ),
          title: Row(
            children: [
              Text(
                '${transaction.amount.truncate()} ج.م',
                style: AppTextStyles.style16Bold.copyWith(
                  color: color,
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: Row(
                  children: [
                    Text(
                      specificCategory.name,
                      style: AppTextStyles.style12W300.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    6.horizontalSpace,
                    Expanded(
                      child: Text(
                        transaction.note != null && transaction.note!.isNotEmpty
                            ? '(${transaction.note})'
                            : '',
                        style: AppTextStyles.style12W300.copyWith(
                          color: AppColors.forthColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Text(DateFormat.yMMMd('ar').format(transaction.date)),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(context, value),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(
                    Icons.edit_outlined,
                    color: AppColors.orangeColor,
                  ),
                  title: Text(
                    'عدّل',
                    style: TextStyle(color: AppColors.orangeColor),
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: AppColors.errorColor,
                  ),
                  title: Text(
                    'مسح',
                    style: TextStyle(color: AppColors.errorColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          height: 0,
        ),
      ],
    );
  }
}

class _SingleSummaryCard extends StatelessWidget {
  const _SingleSummaryCard({
    required this.title,
    required this.totalAmount,
    required this.type,
  });

  final String title;
  final double totalAmount;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardColor,
      elevation: 4,
      shadowColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          8.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.style16W500.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    8.verticalSpace,
                    Text.rich(
                      TextSpan(
                        text: totalAmount.truncate().toString(),
                        style: AppTextStyles.style20W700.copyWith(
                          color: AppColors.primaryColor,
                          fontSize: 32.sp,
                        ),
                        children: [
                          TextSpan(
                            text: ' ج.م',
                            style: AppTextStyles.style16W700.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  type == TransactionType.income
                      ? 'assets/image/png/wallet-money.png'
                      : 'assets/image/png/flying-money.png',
                  height: 96.h,
                ),
              ],
            ),
          ),
          8.verticalSpace,
          const Divider(
            color: AppColors.primaryColor,
            thickness: 0.5,
            height: 0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: InkWell(
              onTap: () {
                context.pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type == TransactionType.expense
                        ? 'إضافة مصاريف جديدة'
                        : 'إضافة دخل جديد',
                    style: AppTextStyles.style12W500.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Icon(Icons.add, color: AppColors.primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterControlBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionCubit = context.watch<TransactionCubit>();
    final transactionState = transactionCubit.state;
    final walletState = context.watch<WalletCubit>().state;

    final filterText = _getFilterText(
      transactionState.activeFilter,
      transactionState.filterStartDate,
      transactionState.filterEndDate,
    );

    var wallets = <Wallet>[];
    if (walletState is WalletLoaded) {
      wallets = walletState.wallets;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (wallets.length > 1)
            DropdownButton<String>(
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.primaryTextColor,
              ),
              value: transactionState.selectedWalletId,
              hint: Text(
                'كل المحافظ',
                style: AppTextStyles.style12W600.copyWith(
                  color: AppColors.greenLightColor,
                ),
              ),
              underline: const SizedBox.shrink(),
              onChanged: transactionCubit.setWalletFilter,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'كل المحافظ',
                    style: AppTextStyles.style12W600.copyWith(
                      color: AppColors.greenLightColor,
                    ),
                  ),
                ),
                ...wallets.map<DropdownMenuItem<String>>((Wallet wallet) {
                  return DropdownMenuItem<String>(
                    value: wallet.id,
                    child: Text(
                      wallet.name,
                      style: AppTextStyles.style12W600.copyWith(
                        color: AppColors.greenLightColor,
                      ),
                    ),
                  );
                }),
              ],
            ),
          InkWell(
            onTap: () => _showFilterOptions(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  filterText,
                  style: AppTextStyles.style12W600.copyWith(
                    color: AppColors.greenLightColor,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primaryTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterText(
    PredefinedFilter filter,
    DateTime? start,
    DateTime? end,
  ) {
    final format = DateFormat('d MMM', 'ar');
    switch (filter) {
      case PredefinedFilter.today:
        return 'النهاردة';
      case PredefinedFilter.week:
        return 'من أول الأسبوع';
      case PredefinedFilter.month:
        return 'من أول الشهر';
      case PredefinedFilter.year:
        return 'السنادي كلها';
      case PredefinedFilter.singleDay:
        return start != null ? 'يوم ${format.format(start)}' : 'يوم محدد';
      case PredefinedFilter.since:
        return start != null ? 'من ${format.format(start)}' : 'من تاريخ معين';
      case PredefinedFilter.custom:
        if (start != null && end != null) {
          return '${format.format(start)} - ${format.format(end)}';
        }
        return 'فترة معينة';
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.today),
                title: const Text('النهاردة'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.today,
                  );
                  sheetContext.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_week_outlined),
                title: const Text('من أول الأسبوع'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.week,
                  );
                  sheetContext.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('من أول الشهر'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.month,
                  );
                  sheetContext.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('السنادي كلها'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.year,
                  );
                  sheetContext.pop();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.event_repeat_outlined),
                title: const Text('من تاريخ معين لحد النهاردة...'),
                onTap: () async {
                  sheetContext.pop();
                  if (!context.mounted) return;
                  final now = DateTime.now();
                  final cubit = context.read<TransactionCubit>();
                  final picked = await showDatePicker(
                    context: context,
                    helpText: 'اختار تاريخ البداية',
                    initialDate: cubit.state.filterStartDate ?? now,
                    firstDate: DateTime(now.year - 5),
                    lastDate: now,
                  );
                  if (picked != null && context.mounted) {
                    await cubit.setSinceFilter(picked);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('يوم واحد محدد'),
                onTap: () async {
                  sheetContext.pop();
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 5),
                    lastDate: now,
                  );
                  if (picked != null && context.mounted) {
                    await context.read<TransactionCubit>().setSingleDayFilter(
                      picked,
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('اختار فترة معينة...'),
                onTap: () async {
                  sheetContext.pop();

                  if (!context.mounted) return;

                  final cubit = context.read<TransactionCubit>();
                  final now = DateTime.now();

                  DateTimeRange? initialRange;
                  if (cubit.state.filterStartDate != null &&
                      cubit.state.filterEndDate != null) {
                    var initialEnd = cubit.state.filterEndDate!;
                    if (initialEnd.isAfter(now)) {
                      initialEnd = now;
                    }
                    var initialStart = cubit.state.filterStartDate!;
                    if (initialStart.isAfter(initialEnd)) {
                      initialStart = initialEnd;
                    }
                    initialRange = DateTimeRange(
                      start: initialStart,
                      end: initialEnd,
                    );
                  }

                  final picked = await showDateRangePicker(
                    helpText: 'اختار فترة معينة',
                    saveText: 'حفظ',
                    context: context,
                    firstDate: DateTime(now.year - 5),
                    lastDate: now,
                    initialDateRange: initialRange,
                  );

                  if (picked != null && context.mounted) {
                    await context.read<TransactionCubit>().setCustomDateFilter(
                      picked.start,
                      picked.end,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({
    required this.transactions,
    required this.categories,
    required this.totalExpense,
  });

  final List<Transaction> transactions;
  final List<TransactionCategory> categories;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final expenseByMainCategory = <String, double>{};

    for (final t in transactions) {
      final category = categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => TransactionCategory(
          id: '',
          name: 'في المجهول',
          colorValue: Colors.grey.value,
          type: TransactionType.expense,
        ),
      );

      final mainCategoryId = category.parentId ?? category.id;

      expenseByMainCategory.update(
        mainCategoryId,
        (value) => value + t.amount,
        ifAbsent: () => t.amount,
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Text(
              'فلوسك على الشارت',
              style: AppTextStyles.style18W600.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
            20.verticalSpace,
            SizedBox(
              height: 200.h,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40.r,
                  sections: expenseByMainCategory.entries.map((entry) {
                    final mainCategory = categories.firstWhere(
                      (c) => c.id == entry.key,
                      orElse: () => TransactionCategory(
                        id: '',
                        name: 'في المجهول',
                        colorValue: Colors.grey.value,
                        type: TransactionType.expense,
                      ),
                    );

                    final percentage = totalExpense > 0
                        ? (entry.value / totalExpense) * 100
                        : 0;

                    return PieChartSectionData(
                      color: mainCategory.color,
                      value: entry.value,
                      title: '${percentage.truncate()}%',
                      radius: 60.r,
                      titleStyle: AppTextStyles.style12Bold.copyWith(
                        color: AppColors.scaffoldBackgroundLightColor,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
