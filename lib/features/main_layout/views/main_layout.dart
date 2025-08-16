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
          body: IndexedStack(
            index: cubit.currentIndex,
            children: cubit.screens,
          ),
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
              const BottomNavigationBarItem(
                icon: Icon(IconlyBroken.wallet),
                label: 'فلوسك',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: cubit.currentIndex == 1
                        ? AppColors.primaryColor
                        : AppColors.textGreyColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.scaffoldBackgroundLightColor,
                  ),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(IconlyBroken.paper),
                // icon: Icon(Entypo.attachment),
                label: 'خططك',
              ),
            ],
          ),
        );
      },
    );
  }
}
