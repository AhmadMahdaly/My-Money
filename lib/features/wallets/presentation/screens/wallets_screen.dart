import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_dropdown_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/debt/presentation/controllers/debt_cubit/debt_cubit.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/domain/entities/wallet.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(
        isLeading: false,
        heightBar: 80.h,
        height: 16.h,
        title: 'المحافظ',
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WalletError) {
            return Center(
              child: Text(
                'فيه غلطة: ${state.message}',
                style: AppTextStyle.style14W500,
              ),
            );
          }
          if (state is WalletLoaded) {
            final totalBalance = state.wallets.fold(
              0.0,
              (sum, wallet) => sum + wallet.balance,
            );

            return Column(
              children: [
                _buildTotalBalanceCard(context, totalBalance),

                Expanded(
                  child: state.wallets.isEmpty
                      ? Center(
                          child: Text(
                            'لسا مفيش محافظ، ضيف محفظة الأول!',
                            style: AppTextStyle.style14W500,
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 16.w,
                          ),
                          itemCount: state.wallets.length,
                          itemBuilder: (context, index) {
                            final wallets = [...state.wallets]
                              ..sort((a, b) {
                                if (a.isMain && !b.isMain) return -1;
                                if (!a.isMain && b.isMain) return 1;
                                return 0;
                              });
                            final wallet = wallets[index];

                            return SizedBox(
                              height: wallet.isMain ? 100.h : null,
                              child: Card(
                                elevation: wallet.isMain ? 6 : 2,
                                color: wallet.isMain
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withAlpha(15)
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: wallet.isMain
                                      ? BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.5,
                                        )
                                      : BorderSide.none,
                                ),
                                margin: EdgeInsets.symmetric(vertical: 4.h),
                                child: Center(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: wallet.isMain
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade300,
                                      radius: wallet.isMain ? 26 : 22,
                                      child: Icon(
                                        Icons.account_balance_wallet_outlined,
                                        color: wallet.isMain
                                            ? Colors.white
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          wallet.name,
                                          style: AppTextStyle.style14Bold,
                                        ),
                                        if (wallet.isMain) ...[
                                          8.horizontalSpace,
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                              vertical: 2.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                            ),
                                            child: Text(
                                              'رئيسية',
                                              style: AppTextStyle.style9W500
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    subtitle: Text(
                                      'الرصيد: ${wallet.balance.truncate()} ج.م',
                                      style: AppTextStyle.style14W500.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showAddEditWalletDialog(
                                            context,
                                            wallet: wallet,
                                          );
                                        } else if (value == 'delete') {
                                          _safeDeleteWallet(context, wallet);
                                        } else if (value == 'set_main') {
                                          context
                                              .read<WalletCubit>()
                                              .setMainWallet(wallet.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        if (!wallet.isMain)
                                          PopupMenuItem(
                                            value: 'set_main',
                                            child: Text(
                                              'خليها كـ محفظة رئيسية',
                                              style: AppTextStyle.style14W500,
                                            ),
                                          ),
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text(
                                            'عدّل',
                                            style: AppTextStyle.style14W500,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            'مسح',
                                            style: AppTextStyle.style14W500
                                                .copyWith(
                                                  color: Colors.red,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return Center(
            child: Text(
              'شاشة المحافظ',
              style: AppTextStyle.style14W500,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: SpeedDial(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(
          color: AppColors.scaffoldBackgroundLightColor,
        ),
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 4.h,
        spaceBetweenChildren: 4.h,
        overlayOpacity: 0.4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.history),
            label: 'سجل عمليات المحافظ',
            onTap: () {
              context.pushNamed(AppRoutes.transferHistoryScreen);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.swap_horiz),
            label: 'تحويل مبلغ',
            onTap: () {
              final state = context.read<WalletCubit>().state;
              if (state is WalletLoaded) {
                _showTransferDialog(context, state.wallets);
              }
            },
          ),

          SpeedDialChild(
            child: const Icon(Icons.account_balance_wallet_outlined),
            label: 'إضافة محفظة',
            onTap: () => _showAddEditWalletDialog(context),
          ),
        ],
      ),
    );
  }

  void _safeDeleteWallet(BuildContext context, Wallet wallet) {
    if (wallet.isMain) {
      _showWarningDialog(
        context,
        'محفظة رئيسية',
        'لا يمكنك حذف المحفظة الرئيسية. قم بتعيين محفظة أخرى كرئيسية أولاً.',
      );
      return;
    }

    final debtsState = context.read<DebtCubit>().state;
    final isLinkedToDebts = debtsState.items.any(
      (d) => d.targetWalletId == wallet.id,
    );

    final transactionsState = context.read<TransactionCubit>().state;
    final isLinkedToTransactions = transactionsState.allTransactions.any(
      (t) => t.walletId == wallet.id,
    );

    if (isLinkedToDebts || isLinkedToTransactions) {
      _showWarningDialog(
        context,
        'لا يمكن الحذف!',
        'هذه المحفظة مرتبطة بـ ${isLinkedToDebts ? 'ديون/أقساط' : ''} ${isLinkedToDebts && isLinkedToTransactions ? 'و' : ''} ${isLinkedToTransactions ? 'سجل معاملات' : ''}.\nلا يمكن حذفها للحفاظ على صحة حساباتك.',
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text(
            'هل أنت متأكد أنك تريد حذف محفظة "${wallet.name}" بشكل نهائي؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<WalletCubit>().deleteWallet(wallet.id);
                Navigator.pop(ctx);
              },
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _showWarningDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            8.horizontalSpace,
            Text(title, style: AppTextStyle.style18W600),
          ],
        ),
        content: Text(message, style: AppTextStyle.style14W500),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'حسناً',
              style: AppTextStyle.style16Bold.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, double totalBalance) {
    return Container(
      margin: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(245),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(77),
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
                'إجمالي الرصيد الحالي',
                style: AppTextStyle.style14W500.copyWith(
                  color: Colors.white.withAlpha(200),
                ),
              ),
              8.verticalSpace,
              Text(
                '${totalBalance.truncate()} ج.م',
                style: AppTextStyle.style18W800.copyWith(
                  color: Colors.white,
                  fontSize: 24.sp,
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
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 32.r,
            ),
          ),
        ],
      ),
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
            isEditing ? 'تعديل اسم المحفظة' : 'ضيف محفظة جديدة',
            style: AppTextStyle.style18W800.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              spacing: 12.h,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPrimaryTextfield(
                  controller: nameController,
                  text: 'اسم المحفظة',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'متنساش تسجل اسم المحفظة' : null,
                ),

                if (!isEditing)
                  CustomPrimaryTextfield(
                    controller: balanceController,
                    text: 'الرصيد الافتتاحي',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null ||
                          v.isEmpty ||
                          double.tryParse(v) == null) {
                        return 'سجّل مبلغ صح';
                      }
                      return null;
                    },
                  )
                else
                  Text(
                    'تعديل الرصيد يتم تلقائياً من خلال إضافة معاملات (مصروف أو دخل) ولا يمكن تعديله يدوياً.',
                    style: AppTextStyle.style12W500.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('إلغاء', style: AppTextStyle.style14W500),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newWallet = Wallet(
                    id: wallet?.id ?? getIt<Uuid>().v4(),
                    name: nameController.text,

                    balance: isEditing
                        ? wallet.balance
                        : double.parse(balanceController.text),
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
}

void _showTransferDialog(BuildContext context, List<Wallet> wallets) {
  String? fromWalletId;
  String? toWalletId;
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet<void>(
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    context: context,
    builder: (ctx) {
      return Column(
        children: [
          Text(
            'نقل مبلغ بين المحافظ',
            style: AppTextStyle.style18W700.copyWith(
              color: AppColors.primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          20.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12.h,
                children: [
                  CustomDropdownButtonFormField<String>(
                    hintText: 'من محفظة',
                    items: wallets
                        .map(
                          (w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(
                              '${w.name} (${w.balance.truncate()} ج.م)',
                              style: AppTextStyle.style12W500,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => fromWalletId = v,
                    validator: (v) => v == null ? 'حدد المحفظة' : null,
                  ),

                  CustomDropdownButtonFormField<String>(
                    hintText: 'إلى محفظة',
                    items: wallets
                        .map(
                          (w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(w.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => toWalletId = v,
                    validator: (v) => v == null ? 'حدد المحفظة' : null,
                  ),

                  CustomPrimaryTextfield(
                    controller: amountController,
                    text: 'المبلغ المراد تحويله',
                    style: AppTextStyle.style12W500.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || double.tryParse(v) == null) {
                        return 'أدخل رقم صحيح';
                      }
                      if (double.parse(v) <= 0) {
                        return 'المبلغ يجب أن يكون أكبر من صفر';
                      }
                      return null;
                    },
                  ),
                ],
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
                  child: Text(
                    'إلغاء',
                    style: AppTextStyle.style14W500,
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (fromWalletId == toWalletId) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'لا يمكن التحويل لنفس المحفظة!',
                                style: AppTextStyle.style14W500,
                              ),
                            ),
                          );
                          return;
                        }

                        context.read<WalletCubit>().transferBalance(
                          fromWalletId!,
                          toWalletId!,
                          double.parse(amountController.text),
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    child: Text(
                      'تأكيد التحويل',
                      style: AppTextStyle.style14W500.copyWith(
                        color: AppColors.scaffoldBackgroundLightColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
