import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_floating_action_buttom.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/welcome_user_widget.dart';
import 'package:opration/features/wallets/domain/entities/wallet.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WalletError) {
            return Center(child: Text('فيه غلطة: ${state.message}'));
          }
          if (state is WalletLoaded) {
            if (state.wallets.isEmpty) {
              return const Center(
                child: Text('لسا مفيش محافظ، ضيف محفظة الأول!'),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(8.r),
              itemCount: state.wallets.length,
              itemBuilder: (context, index) {
                final wallet = state.wallets[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: wallet.isMain
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: wallet.isMain
                            ? Colors.white
                            : Colors.grey.shade800,
                      ),
                    ),
                    title: Text(
                      wallet.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'الرصيد: ${wallet.balance.toStringAsFixed(2)} ج.م',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showAddEditWalletDialog(context, wallet: wallet);
                        } else if (value == 'delete') {
                          context.read<WalletCubit>().deleteWallet(wallet.id);
                        } else if (value == 'set_main') {
                          context.read<WalletCubit>().setMainWallet(wallet.id);
                        }
                      },
                      itemBuilder: (context) => [
                        if (!wallet.isMain)
                          const PopupMenuItem(
                            value: 'set_main',
                            child: Text('خليها كـ محفظة رئيسية'),
                          ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('عدّل'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'مسح',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('شاشة المحافظ'));
        },
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () => _showAddEditWalletDialog(context),
        tooltip: 'ضيف محفظة جديدة',
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
          title: Text(isEditing ? 'عدّل المحفظة' : 'ضيف محفظة جديدة'),
          content: Form(
            key: formKey,
            child: Column(
              spacing: 4.h,
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
                        (v == null ||
                            v.isEmpty ||
                            double.tryParse(v) == null)) {
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
              child: const Text('إلغاء'),
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
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PageHeader({super.key});

  @override
  Size get preferredSize => Size.fromHeight(90.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        right: 16.w,
        left: 16.w,
        bottom: 10.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, -0),
          end: Alignment(0.50, 1),
          colors: [AppColors.primaryColor, AppColors.secondaryTextColor],
        ),
      ),
      child: const WelcomeUserWidget(),
    );
  }
}
