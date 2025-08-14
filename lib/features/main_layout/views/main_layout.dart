import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
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
          appBar: AppBar(
            toolbarHeight: 90.h,
            backgroundColor: AppColors.primaryColor,
          ),

          body: IndexedStack(
            index: cubit.currentIndex,
            children: cubit.screens,
          ),
          bottomSheet: Container(
            height: 75.h,
            margin: EdgeInsets.only(right: 2.w, left: 2.w, bottom: 8.h),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(60.r)),
            ),
            child: BottomNavigationBar(
              selectedLabelStyle: const TextStyle(
                color: AppColors.primaryColor,
              ),
              selectedIconTheme: const IconThemeData(
                color: AppColors.primaryColor,
              ),
              useLegacyColorScheme: false,
              backgroundColor: AppColors.scaffoldBackgroundLightColor,
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: cubit.changeNavBarIndex,
              unselectedItemColor: AppColors.brownLightColor,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(IconlyBroken.home),
                  label: '1',
                ),
                BottomNavigationBarItem(
                  icon: Icon(IconlyBroken.category),
                  label: '2',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Entypo.lab_flask),
                  label: '3',
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(IconlyBroken.profile),
                //   label: 'Profile',
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
