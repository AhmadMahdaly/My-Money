import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(
        isLeading: true,
        title: 'الإشعارات',
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          final pending = state.pendingTransactions;

          if (pending.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80.r,
                    color: AppColors.textGreyColor.withAlpha(100),
                  ),
                  16.verticalSpace,
                  Text(
                    'مفيش أي إشعارات أو عمليات معلقة',
                    style: AppTextStyles.style16W500.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: pending.length,
            separatorBuilder: (_, _) => 12.verticalSpace,
            itemBuilder: (context, index) {
              final category = pending[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: AppColors.orangeColor.withAlpha(100),
                  ),
                ),
                color: AppColors.orangeColor.withAlpha(15),
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: category.color,
                            radius: 20.r,
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          12.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تأكيد تسجيل "${category.name}"',
                                  style: AppTextStyles.style14W600,
                                ),
                                4.verticalSpace,
                                Text(
                                  'المبلغ المتوقع: ${category.fixedAmount?.truncate() ?? 0} ج.م',
                                  style: AppTextStyles.style12W400.copyWith(
                                    color: AppColors.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      16.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              context
                                  .read<TransactionCubit>()
                                  .dismissPendingTransaction(category);
                              showCustomSnackBar(
                                context,
                                message: 'تم التجاهل',
                                backgroundColor: AppColors.textGreyColor,
                              );
                            },
                            child: Text(
                              'تجاهل اليوم',
                              style: TextStyle(
                                color: AppColors.textGreyColor,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          8.horizontalSpace,

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onPressed: () {
                              context
                                  .read<TransactionCubit>()
                                  .approvePendingTransaction(category);
                              showCustomSnackBar(
                                context,
                                message: 'تم تسجيل "${category.name}" بنجاح',
                              );
                            },
                            child: const Text(
                              'تأكيد وتسجيل',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
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
