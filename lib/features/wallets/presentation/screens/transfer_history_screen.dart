import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/wallets/data/datasources/wallet_local_data_source.dart';
import 'package:opration/features/wallets/data/models/transfer_record_model.dart';

class TransferHistoryScreen extends StatelessWidget {
  const TransferHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سجل التحويلات',
          style: AppTextStyles.style20W700.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            size: 18.r,
            Icons.arrow_back_ios_rounded,
            color: AppColors.primaryColor,
          ),
        ),
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
              child: Text(
                'لا توجد تحويلات سابقة',
                style: AppTextStyles.style14W500,
              ),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.blue),
                  title: Text(
                    'من ${item.fromWalletName} إلى ${item.toWalletName}',
                    style: AppTextStyles.style14W500,
                  ),
                  subtitle: Text(
                    '${item.date.day}/${item.date.month}/${item.date.year}',
                    style: AppTextStyles.style14W500,
                  ),
                  trailing: Text(
                    '${item.amount.truncate()} ج.م',
                    style: AppTextStyles.style14Bold.copyWith(
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
