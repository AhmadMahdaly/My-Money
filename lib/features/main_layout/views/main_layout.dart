import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/features/main_layout/cubit/main_layout_cubit.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

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
                icon: Icon(
                  cubit.currentIndex == 0
                      ? Icons.wallet_rounded
                      : IconlyBroken.wallet,
                ), // Icon(Icons.credit_card),
                label: 'الفلوس',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  cubit.currentIndex == 1
                      ? Icons.analytics
                      : IconlyBroken.paper,
                ),
                label: 'بادجت الشهر',
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
                icon: Icon(
                  cubit.currentIndex == 3
                      ? Icons.account_balance_wallet_rounded
                      : Icons.credit_card,
                ),
                //Icon(IconlyBroken.category),
                label: 'محافظ',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.track_changes),
                label: 'الأهداف',
              ),
            ],
          ),
        );
      },
    );
  }
}
