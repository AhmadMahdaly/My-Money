import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/services/format_currency.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/domain/entities/wallet.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';

class DebtPaymentsLogView extends StatelessWidget {
  const DebtPaymentsLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final walletsState = context.watch<WalletCubit>().state;
    final wallets = walletsState is WalletLoaded
        ? walletsState.wallets
        : <Wallet>[];

    return Scaffold(
      appBar: const PageHeader(
        isLeading: true,
        title: 'سجل مدفوعات الديون',
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          final debtTransactions = state.allTransactions.where((t) {
            return t.note != null &&
                (t.note!.startsWith('دفعة يدوية:') ||
                    t.note!.startsWith('سداد آلي:'));
          }).toList()..sort((a, b) => b.date.compareTo(a.date));

          if (debtTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.doc_text_search,
                    size: 50.r,
                    color: AppColors.textGreyColor.withAlpha(100),
                  ),
                  16.verticalSpace,
                  Text(
                    'لا يوجد سجل مدفوعات حتى الآن.',
                    style: AppTextStyle.style14W400.copyWith(
                      color: AppColors.textGreyColor.withAlpha(150),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemCount: debtTransactions.length,
            itemBuilder: (context, index) {
              final transaction = debtTransactions[index];
              final isAuto =
                  transaction.note != null &&
                  transaction.note!.startsWith('سداد آلي:');

              final debtName = transaction.note != null
                  ? transaction.note!
                        .replaceFirst('دفعة يدوية: ', '')
                        .replaceFirst('سداد آلي: ', '')
                  : 'اسم الدين غير متوفر';

              final walletName = wallets
                  .where((w) => w.id == transaction.walletId)
                  .map((w) => w.name)
                  .firstWhere((name) => true, orElse: () => 'محفظة محذوفة');

              return Card(
                margin: EdgeInsets.only(bottom: 12.h),

                elevation: 0,
                color: isAuto
                    ? AppColors.primaryColor.withAlpha(15)
                    : AppColors.scaffoldBackgroundLightColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: isAuto
                        ? AppColors.primaryColor.withAlpha(50)
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isAuto
                        ? AppColors.primaryColor.withAlpha(40)
                        : AppColors.successColor.withAlpha(40),
                    child: Icon(
                      isAuto
                          ? Icons.autorenew_rounded
                          : Icons.check_circle_outline_rounded,
                      color: isAuto
                          ? AppColors.primaryColor
                          : AppColors.successColor,
                    ),
                  ),
                  title: Text(
                    debtName,
                    style: AppTextStyle.style14W600,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      6.verticalSpace,
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12.sp,
                            color: AppColors.textGreyColor,
                          ),
                          4.horizontalSpace,
                          Text(
                            DateFormat(
                              'd MMM yyyy - hh:mm a',
                              'ar',
                            ).format(transaction.date),
                            style: AppTextStyle.style12W400.copyWith(
                              color: AppColors.textGreyColor,
                            ),
                          ),
                        ],
                      ),
                      4.verticalSpace,
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 12.sp,
                            color: AppColors.textGreyColor,
                          ),
                          4.horizontalSpace,
                          Text(
                            walletName,
                            style: AppTextStyle.style12W400.copyWith(
                              color: AppColors.textGreyColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${formatCurrency(transaction.amount)} $appCurrencySymbol',
                    style: AppTextStyle.style16W600.copyWith(
                      color: AppColors.errorColor,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
