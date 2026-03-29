import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/features/debt/presentation/controllers/debt_cubit/debt_cubit.dart';
import 'package:opration/features/main_layout/cubit/main_layout_cubit.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  void initState() {
    super.initState();
    // فحص الديون المستحقة وخصمها
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtCubit>().processDueDebts(
        context.read<TransactionCubit>(),
        context.read<WalletCubit>(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainLayoutCubit, MainLayoutState>(
      builder: (context, state) {
        final cubit = context.read<MainLayoutCubit>();
        return Scaffold(
          body: cubit.screens[cubit.currentIndex],

          bottomNavigationBar: BottomNavigationBar(
            selectedLabelStyle: const TextStyle(
              color: AppColors.primaryColor,
            ),

            selectedIconTheme: const IconThemeData(
              color: AppColors.primaryColor,
            ),
            backgroundColor: AppColors.scaffoldBackgroundLightColor,
            type: BottomNavigationBarType.fixed,
            currentIndex: cubit.currentIndex,
            onTap: cubit.changeNavBarIndex,
            unselectedItemColor: AppColors.textGreyColor,
            items: [
              BottomNavigationBarItem(
                icon: SvgImage(
                  imagePath: 'assets/image/svg/money-bag-outline.svg',
                  height: cubit.currentIndex == 0 ? 30.r : 24.r,
                  color: cubit.currentIndex == 0
                      ? AppColors.primaryColor
                      : AppColors.textGreyColor,
                ),

                label: 'الفلوس',
              ),
              BottomNavigationBarItem(
                icon: SvgImage(
                  imagePath: 'assets/image/svg/wallet-money (1).svg',
                  height: cubit.currentIndex == 1 ? 30.r : 24.r,
                  color: cubit.currentIndex == 1
                      ? AppColors.primaryColor
                      : AppColors.textGreyColor,
                ),
                label: 'المحافظ',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.scaffoldBackgroundLightColor,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SvgImage(
                  imagePath: 'assets/image/svg/big-data-analytics 1.svg',
                  height: cubit.currentIndex == 3 ? 28.r : 22.r,
                  color: cubit.currentIndex == 3
                      ? AppColors.primaryColor
                      : AppColors.textGreyColor,
                ),
                label: 'الميزانية',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/image/png/more.png',

                  height: cubit.currentIndex == 4 ? 30.r : 24.r,
                  color: cubit.currentIndex == 4
                      ? AppColors.primaryColor
                      : AppColors.textGreyColor,
                ),
                label: 'المزيد',
              ),
            ],
          ),
        );
      },
    );
  }
}
