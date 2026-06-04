import 'package:flutter/material.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/wallets/data/datasources/wallet_local_data_source.dart';
import 'package:opration/features/wallets/data/models/transfer_record_model.dart';

class TransferHistoryScreen extends StatelessWidget {
  const TransferHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(
        isLeading: true,
        heightBar: 80.h,
        title: 'سجل العمليات',
      ),
      body: FutureBuilder<List<TransferRecordModel>>(
        future: getIt<WalletLocalDataSource>().getTransferHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data!;
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 36.r,
                    color: AppColors.textGreyColor,
                  ),
                  16.verticalSpace,
                  Text(
                    'لا توجد تحويلات أو إيداعات سابقة',
                    style: AppTextStyle.style14W500.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];

              final isDeposit = item.fromWalletName == 'إيداع خارجي';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: ListTile(
                  leading: Icon(
                    isDeposit ? Icons.arrow_downward_rounded : Icons.swap_horiz,
                    color: isDeposit ? Colors.green : Colors.blue,
                  ),
                  title: Text(
                    isDeposit
                        ? 'إيداع إلى ${item.toWalletName}'
                        : 'من ${item.fromWalletName} إلى ${item.toWalletName}',
                    style: AppTextStyle.style14W500,
                  ),
                  subtitle: Text(
                    '${item.date.day}/${item.date.month}/${item.date.year}',
                    style: AppTextStyle.style14W500,
                  ),
                  trailing: Text(
                    '+${item.amount.truncate()} $appCurrencySymbol',
                    style: AppTextStyle.style14Bold.copyWith(
                      color: Colors.green,
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
