import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/services/cache_helper/backup_service.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/features/auth/presentation/cubit/login_cubit.dart';
import 'package:opration/features/debt/presentation/controllers/debt_cubit/debt_cubit.dart';
import 'package:opration/features/goals/presentation/controllers/financial_goal_cubit/financial_goal_cubit.dart';
import 'package:opration/features/intro/my_app.dart';
import 'package:opration/features/monthly_plan/presentation/controllers/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool isLoading = false;

  void _setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void _showToast(String msg, {bool isError = false}) {
    GlobalVariable.showMessage(msg, isError: isError);
  }

  /// 🔹 Backup
  Future<void> handleBackup() async {
    try {
      _setLoading(true);

      await BackupService.shareBackup();

      _showToast('تم حفظ النسخة الاحتياطية');
    } catch (e) {
      _showToast('فشل حفظ النسخة الاحتياطية', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 Restore
  Future<void> handleRestore() async {
    try {
      _setLoading(true);

      await BackupService.restoreFromJson();
      if (!mounted) return;
      await _refreshAllCubits();
      _showToast('تم استعادة نسخة من البيانات بنجاح');
    } catch (e) {
      if (!mounted) return;
      _showToast('فشل استعادة النسخة', isError: true);
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  Future<void> _refreshAllCubits() async {
    await context.read<AuthCubit>().checkAuthStatus();
    await context.read<TransactionCubit>().loadInitialData();
    await context.read<MonthlyPlanCubit>().loadPlanForMonth(DateTime.now());
    await context.read<WalletCubit>().loadWallets();
    await context.read<FinancialGoalCubit>().loadGoals();
    await context.read<DebtCubit>().processDueDebts(
      context.read<TransactionCubit>(),
      context.read<WalletCubit>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageHeader(
        isLeading: true,
        height: 16.h,
        title: 'النسخ الاحتياطي والاستعادة',
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                /// Backup Button
                CustomPrimaryButton(
                  onPressed: () => isLoading ? null : handleBackup(),
                  text: 'إنشاء نسخة احتياطية من البيانات',
                ),

                20.verticalSpace,

                /// Restore Button
                CustomPrimaryButton(
                  onPressed: () => isLoading ? null : handleRestore(),
                  text: 'استعادة النسخة الاحتياطية',
                ),
              ],
            ),
          ),

          /// 🔹 Loading Overlay
          if (isLoading)
            ColoredBox(
              color: Colors.black.withAlpha(77),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
