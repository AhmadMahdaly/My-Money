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
                icon: cubit.currentIndex == 0
                    ? const Icon(Icons.wallet_rounded)
                    : const Icon(
                        IconlyBroken.wallet,
                      ), // Icon(Icons.credit_card),
                label: 'فلوسك',
              ),
              BottomNavigationBarItem(
                icon: cubit.currentIndex == 1
                    ? const Icon(Icons.analytics)
                    : const Icon(IconlyBroken.paper),
                label: 'خططك',
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
                icon: cubit.currentIndex == 3
                    ? const Icon(Icons.credit_card)
                    : const Icon(Icons.credit_card),
                //Icon(IconlyBroken.category),
                label: 'محافظك',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.track_changes_outlined),
                label: 'الأهداف',
              ),
            ],
          ),
        );
      },
    );
  }
}
